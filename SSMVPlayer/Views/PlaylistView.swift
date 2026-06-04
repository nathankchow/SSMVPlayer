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
                    let playlist = Playlist(name: "Untitled Playlist")
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
                ForEach(viewModel.playlists, id: \.id) { playlist in
                    NavigationLink(destination: PlaylistEditView(playlist: playlist)) {
                        Text(playlist.name)
                    }
                }
            }
        }
        .navigationDestination(item: $newPlaylist) { playlist in
            PlaylistEditView(playlist: playlist)
        }
    }
}

#Preview {
    PlaylistCreateView()
}
