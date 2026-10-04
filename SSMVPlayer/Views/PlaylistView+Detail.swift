//
//  PlaylistEditView.swift
//  SSMVPlayer
//
//  Created by natha on 5/21/26.
//
// #TODO: how to get rid of rounded corners for a list?
// #TODO: implement positional playing
// #TODO: think about nuance of multiple buttons in an list element

import SwiftUI

struct PlaylistLaunchParameters: Identifiable {
    let id = UUID()
    let playlist: Playlist
    let index: Int
}

struct PlaylistDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let playlist: Playlist
    @State var showAlert = false
    @State private var playlistLaunchParameters: PlaylistLaunchParameters? = nil
    
    var videos: [Video] {
        playlist.entries.compactMap(\.video)
    }
    
    var isPlayable: Bool {
        !(playlist.entries.isEmpty || playlist.entries.filter{ $0.video == nil }.count > 0)
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
                    ForEach(playlist.entries, id: \.id) { entry in
                        let index = playlist.entries.firstIndex(where: { $0.id == entry.id })!
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
                                    // #TODO: dont force unwrap here
                                    StaticIdolRowView(entry.video, idolCellSize: 50, songMetadata: viewModel.songMetadataDict[entry.song]!, disableOriginalSingers: true)
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
            .navigationTitle(playlist.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
            .sheet(item: $playlistLaunchParameters) { p in
                PlaylistPlayerView(playlist: p.playlist, index: p.index )
            }

        .overlay(alignment: .bottomTrailing) {
            Button {
                playPlaylist(from: 0)
            } label: {
                    Text("Play")
                        .foregroundStyle(.white)
                        .frame(width: 160, height: 40)
                        .background(isPlayable ? .pink : .gray)
                        .clipShape(Capsule())
                        .padding()
            }
            .disabled(!isPlayable)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        playlist.entries.move(fromOffsets: source, toOffset: destination)
    }
        
    func delete(at offsets: IndexSet) {
        playlist.entries.remove(atOffsets: offsets)
    }
    
    func playPlaylist(from index: Int) {
        playlistLaunchParameters = PlaylistLaunchParameters(playlist: playlist, index: index)
    }
}

#Preview {
    PlaylistDetailView(playlist: Playlist.samplePlaylist())
        .environment(ViewModel())
}
