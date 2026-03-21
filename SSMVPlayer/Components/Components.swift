//
//  Components.swift
//  SSMVPlayer
//
//  Created by natha on 3/9/26.
//
// #TODO: arisu default bad

import SwiftUI

struct StaticIdolRowView: View {
    var idols: [String] = ["","","","",""]
    
    var body: some View {
        HStack {
            ForEach(idols.indices, id: \.self) { index in
                IdolCellView(idol: idols[index])
            }
        }
    }
    
    init(_ inputIdols: [String]) {
        let idolCount = inputIdols.count
        var currentIndex = 2 - (idolCount / 2) //2, 1, 1, 0, 0
        for idol in inputIdols {
            idols[currentIndex] = idol
            currentIndex += 1
        }
    }
}

// #TODO: probably want to name the images differently
struct IdolCellView: View {
    let idol: String
    
    var body: some View {
        if idol == "" {
            Image(systemName: "sparkles")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
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
                .frame(width: 70, height: 70)
        }
    }
}

#Preview {
    StaticIdolRowView(["arisu", "koharu"])
}
