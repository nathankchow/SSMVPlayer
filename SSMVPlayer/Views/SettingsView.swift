//
//  SettingsView.swift
//  SSMVPlayer
//
//  Created by natha on 10/4/26.
//

import SwiftUI

    
struct SettingsView: View {
    @Environment(ViewModel.self) private var viewModel
    
    let idolNames = [
        "arisu",
        "koharu",
        "yoshino",
        "yukimi",
        "yumi"
    ]
    
    var body: some View {
        List {
            Section("Change icon") {
                ForEach(idolNames, id: \.self) { idol in
                    NavigationLink {
                        IdolIconSelectView(idol: idol)
                    } label: {
                        HStack {
                            Spacer()
                            Image(viewModel.customIdolIcons[idol] ?? "\(idol)-default")
                            Spacer()
                        }
                    }
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
    }
}


#Preview {
    SettingsView()
        .environment(ViewModel())
}
