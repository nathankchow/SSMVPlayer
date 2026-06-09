//
//  ContentView.swift
//  SSMVPlayer
//
//  Created by natha on 3/8/26.
// #TODO: view is ugly

import SwiftUI

struct SongSelectView: View {
    @Environment(ViewModel.self) private var viewModel
    @State var focusedSong: Song? = nil
    @State var showTaggerSheet = false
        
    var availableSongs: [Song] {
        viewModel.songs.filter { song in
            viewModel.localVideos.map { $0.songName }.contains(song.name)
        }
    }
    
    var songCounts: [Song: Int] {
        viewModel.songs.reduce(into: [:]) { container, song in
            let count = viewModel.localVideos.count(where: { $0.songName == song.name })
            container[song] = count
        }
    }
    
    var availableSongSet: Set<Song> {
        Set(availableSongs)
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            taggerButtonRow
                .frame(maxWidth: .infinity)
                .background(.mint)
            
            Divider()
            
            ScrollView {
                VStack() {
                    ForEach(viewModel.songs, id: \.id) { song in
                        HStack{
                            Text("\(song.name)  (\(SONG_QUOTAS[song.name, default: 0]))")
                                .lineLimit(1)
                                .foregroundStyle(foregroundColor(for: song.name))
                                .fontWeight(focusedSong?.id == song.id ? .bold : .regular)
                                .padding(4)

                            
                            Spacer()
                            
                            if viewModel.songMetadataDict[song]?.localIdolCount ?? 0 > 0 {
                                Text("Local")
                                    .font(.caption)
                                    .padding(.horizontal, 4)
                                    .foregroundStyle(.white)
                                    .background(.blue)
                                    .clipShape(Capsule())
                            }
                            
                            if viewModel.songMetadataDict[song]?.youtubeIdolCount ?? 0 > 0 {
                                Text("YouTube")
                                    .font(.caption)
                                    .padding(.horizontal, 4)
                                    .foregroundStyle(.white)
                                    .background(.red)
                                    .clipShape(Capsule())
                                
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 20, alignment: .leading)
                        .contentShape(Rectangle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(focusedSong?.id == song.id ? Color.red : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            focusedSong = song
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 16) {
                if let song = focusedSong {
                    Image(song.name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "house")
                        .frame(width: 200, height: 200)
                }

                NavigationLink(destination: VideoSelectView(song: focusedSong ?? viewModel.songs.first!, metadata: viewModel.songMetadataDict[focusedSong ?? viewModel.songs.first!]!)) {
                    VStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 36))
                        Text("Play")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(focusedSong == nil)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .onAppear {
            focusedSong = viewModel.songs.first
        }
    }
    
    var taggerButtonRow: some View {
        HStack{
            Button {
                showTaggerSheet = true
            } label: {
                HStack {
                    Image(systemName: "tag.fill")
                    Text("Tagger")
                }
                .contentShape(Rectangle())
            }
            .sheet(isPresented: $showTaggerSheet) {
                VideoTaggerView()
            }
            
            Button {
                viewModel.setup()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
            }
            
            NavigationLink(destination: PlaylistCreateView()) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Playlists")
                }
            }
        }
        .padding()
    }
    
    func foregroundColor(for songName: String) -> Color {
        guard let quota = SONG_QUOTAS[songName] else {
            return .primary
        }
        
        guard let song = viewModel.songs.first(where: { $0.name == songName }),
              let count = songCounts[song] else {
            return .gray
        }
        
        if count == 0 {
            return .gray
        } else if count < quota {
            return .yellow
        } else if count > quota {
            return .orange
        } else {
            return .primary
        }
    }
}



//#Preview {
//    SongSelectView()
//        .environment(ViewModel())
//}

#Preview {
    SongSelectView()
        .environment(ViewModel())
}
