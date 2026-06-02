//
//  PlaylistsView+SongSelect.swift
//  SSMVPlayer
//
//  Created by natha on 6/1/26.
//

import SwiftUI

struct PlaylistSongSelectView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss
    
    @State var songsToAdd: [Song] = []
    @State private var horizontalPosition: ScrollPosition = .init(idType: Int.self)

    let playlist: Playlist
    
    var availableSongs: [Song] {
        // #TODO: is songmetadatadict all songs or only songs with non-zero vid count?
        viewModel.songs.filter {
            viewModel.songMetadataDict.keys.contains($0)
        }
    }
    
    // #TODO: look into how grid columns work exactly
    let gridColumns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(availableSongs, id: \.self) { song in
                        VStack {
                            Button {
                                songsToAdd.append(song)
                                horizontalPosition.scrollTo(edge: .trailing)
                            } label: {
                                Image(song.name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            }
                            
                            Text(song.name)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            Divider()
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Array(zip(songsToAdd.indices, songsToAdd)), id: \.0) { index, item in
                        
                        Image(songsToAdd[index].name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    songsToAdd.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .foregroundStyle(.red)
                                        .background(.white)
                                }
                            }
                    }
                }
                .scrollTargetLayout()
                .padding()
            }
            .scrollPosition($horizontalPosition)
            
            Button {
                for song in songsToAdd {
                    playlist.entries.append(PlaylistEntry(song: song))
                }
                dismiss()
            } label: {
                Text("Confirm")
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 40)
                    .background(.blue)
                    .clipShape(.capsule)
            }
        }
    }
}

#Preview {
    PlaylistSongSelectView(playlist: Playlist.samplePlaylist())
        .environment(ViewModel())
}
