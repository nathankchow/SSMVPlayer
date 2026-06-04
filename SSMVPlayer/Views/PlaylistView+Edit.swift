//
//  PlaylistEditView.swift
//  SSMVPlayer
//
//  Created by natha on 5/21/26.
//
// #TODO: how to get rid of rounded corners for a list?
// #TODO: enum/index based foreach is making reorder laggy/slow?

import SwiftUI

struct PlaylistEditView: View {
    @Environment(ViewModel.self) private var viewModel
    let playlist: Playlist
    @State var showAlert = false
    @State private var playlistToPlay: Playlist? = nil
    
    var videos: [Video] {
        playlist.entries.compactMap(\.video)
    }
    
    var body: some View {
            List {
                Section {
                    NavigationLink(destination: PlaylistSongSelectView(playlist: playlist)){
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Song")
                        }
                        .contentShape(Rectangle())
                    }
                }
                
                Section {
                    ForEach(Array(zip(playlist.entries.indices, playlist.entries)), id: \.0) { index, entry in
                        HStack {
                            Button {
                                playPlaylist(from: index)
                            } label: {
                                Image(entry.song.name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75, height: 75)
                            }
                            .disabled(entry.video == nil)
                            
                            VStack(alignment: .leading) {
                                Text(entry.song.name)
                                
                                NavigationLink(destination: VideoSelectView(song: entry.song, metadata: viewModel.songMetadataDict[entry.song]!, playlist: playlist, playlistEntryIndex: index))
                                {
                                    StaticIdolRowView(entry.video, idolCellSize: 50)
                                        .contentShape(Rectangle())
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)
                }
            }
            .toolbar {
                EditButton()
            }
            .sheet(item: $playlistToPlay) { p in
                PlaylistPlayerView(playlist: p)
            }

        .overlay(alignment: .bottomTrailing) {
            Button {
                playPlaylist(from: 0)
            } label: {
                    Text("Play")
                        .foregroundStyle(.white)
                        .frame(width: 160, height: 40)
                        .background(.pink)
                        .clipShape(Capsule())
                        .padding()
            }
            .disabled(playlist.entries.isEmpty || playlist.entries.filter{ $0.video == nil }.count > 0)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        playlist.entries.move(fromOffsets: source, toOffset: destination)
    }
        
    func delete(at offsets: IndexSet) {
        playlist.entries.remove(atOffsets: offsets)
    }
    
    func playPlaylist(from index: Int) {
        playlistToPlay = playlist
    }
}

#Preview {
    PlaylistEditView(playlist: Playlist.samplePlaylist())
        .environment(ViewModel())
}
