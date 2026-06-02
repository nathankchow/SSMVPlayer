//
//  Components.swift
//  SSMVPlayer
//
//  Created by natha on 3/9/26.
//

import SwiftUI

struct DynamicIdolRowView: View {
    @Binding var idols: [String]
    @State var selectedIndex: Int? = nil
    
    let idolCount: Int
    let hasPivotIdol: Bool
    let order = [4,2,1,3,5]
    
    var body: some View {
        HStack {
            ForEach(idols.indices, id: \.self) { index in
                IdolCellView(idol: idols[index])
                    .opacity(order[index] > idolCount ? 0.5 : 1)
                    .padding(3)
                    .overlay(
                        Rectangle()
                            .stroke(selectedIndex == index ? Color.red : Color.clear, lineWidth: 3)
                    )
                    .overlay(
                        Group {
                            if hasPivotIdol && showLock(index: index) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white)
                            }
                        }
                    )
                    .onTapGesture {
                        tapGestureCallback(index)
                    }
            }
        }
    }
    
    func showLock(index: Int) -> Bool {
        guard let selected = selectedIndex else { return false }
        
        let koharuIndex = idols.firstIndex(of: "koharu")!
        
        if idols[selected] == "koharu" {
            return order[index] > idolCount
        } else if order[selected] > idolCount {
            return index == koharuIndex
        } else {
            return false
        }
    }
    
    func tapGestureCallback(_ index: Int) {
        guard let selected = selectedIndex else {
            selectedIndex = index
            return
        }
        
        if hasPivotIdol {
            let outerPosition = max(order[index], order[selected])
            if outerPosition > idolCount && (idols[index] == "koharu" || idols[selected]  == "koharu") {
                selectedIndex = nil
                return
            }
        }
        
        var idolsCopy = idols
        let temp = idolsCopy[index]
        idolsCopy[index] = idolsCopy[selected]
        idolsCopy[selected] = temp
        
        self.idols = idolsCopy
        selectedIndex = nil
    }
    
    init(_ idols: Binding<[String]>, hasPivotIdol: Bool, idolCount: Int = 1) {
        self._idols = idols
        self.idolCount = idolCount
        self.hasPivotIdol = hasPivotIdol
    }
}

struct StaticIdolRowView: View {
    var idols: [String] = ["","","","",""]
    let idolCellSize: CGFloat
    
    var body: some View {
        HStack {
            ForEach(idols.indices, id: \.self) { index in
                IdolCellView(idol: idols[index], size: idolCellSize)
            }
        }
    }
    
    init(_ inputIdols: [String], idolCellSize: CGFloat = 70) {
        let idolCount = inputIdols.count
        self.idolCellSize = idolCellSize
        var currentIndex = 2 - (idolCount / 2) //2, 1, 1, 0, 0
        for idol in inputIdols {
            idols[currentIndex] = idol
            currentIndex += 1
        }
    }
    
    init(_ video: Video?, idolCellSize: CGFloat = 70) {
        self.init(video?.idols ?? [], idolCellSize: idolCellSize)
    }
}

// #TODO: probably want to name the images differently
struct IdolCellView: View {
    let idol: String
    let size: CGFloat
    
    var body: some View {
        if idol == "" {
            Image(systemName: "sparkles")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundStyle(Color.gray.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 2) 
                )
        } else {
            Image("\(idol)-default")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
    
    init(idol: String, size: CGFloat = 70) {
        self.idol = idol
        self.size = size
    }
}

#Preview {
    StaticIdolRowView(["arisu", "koharu"])
}
