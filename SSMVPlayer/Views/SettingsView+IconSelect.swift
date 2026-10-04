//
//  SettingsView+IconSelect.swift
//  SSMVPlayer
//
//  Created by natha on 10/4/26.
//

import SwiftUI

struct IdolIconSelectView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var selectedIcon: String?

    let idol: String

    private let columns = [GridItem(.adaptive(minimum: 80), spacing: 10)]
    private var icons: [String] {
        IDOL_ICONS[idol] ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(selectedIcon ?? "\(idol)-default")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    Button {
                        reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    
                    ForEach(icons, id: \.self) { code in
                        Button {
                            select(code)
                        } label: {
                            Image(code)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay {
                                    if selectedIcon == code {
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(Color.red, lineWidth: 3)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }

        .onAppear {
            selectedIcon = viewModel.customIdolIcons[idol]
        }
    }

    private func select(_ code: String) {
        selectedIcon = code
        viewModel.customIdolIcons[idol] = code
        viewModel.saveIdolIcons()
    }
    
    private func reset() {
        selectedIcon = nil
        viewModel.customIdolIcons[idol] = nil
        viewModel.saveIdolIcons()
    }
}

#Preview {
    IdolIconSelectView(idol: "arisu")
        .environment(ViewModel())
}
