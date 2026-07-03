//
//  PlaylistCreateView.swift
//  SSMVPlayer
//
//  Created by natha on 5/21/26.
//

import SwiftUI

struct PlaylistCreateView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var newPlaylist: Playlist? = nil
    
    var body: some View {
        List {
            Section {
                Button {
                    // #TODO: make name unique/dynamic
                    let dupeString = " (\(String(viewModel.playlists.count)))"
                    let playlist = Playlist(name: "Untitled Playlist\(viewModel.playlists.count == 0 ? "" : dupeString)")
                    viewModel.playlists.append(playlist)
                    newPlaylist = playlist
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("New Playlist")
                    }
                    .contentShape(Rectangle())
                }
            }
            
            Section {
                ForEach(viewModel.playlists.reversed(), id: \.id) { playlist in
                    NavigationLink(destination: PlaylistEditView(playlist: playlist)) {
                        Text(playlist.name)
                    }
                }
            }
        }
        .navigationTitle("Playlists")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $newPlaylist) { playlist in
            PlaylistEditView(playlist: playlist)
        }
    }
}

#Preview {
    PlaylistCreateView()
}
