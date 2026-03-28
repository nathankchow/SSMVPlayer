//
//  SSMVPlayerApp.swift
//  SSMVPlayer
//
//  Created by natha on 3/8/26.
//

import SwiftUI

@main
struct SSMVPlayerApp: App {
    @State private var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            SongSelectView()
                .environment(viewModel)
        }
    }
}
