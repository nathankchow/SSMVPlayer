//
//  ContentView.swift
//  SSMVPlayer
//
//  Created by natha on 3/8/26.
//
// todo

import SwiftUI

struct SongSelectView: View {
    @Environment(ViewModel.self) private var viewModel
    @State var focusedSong: Song? = nil
    @State var showTaggerSheet = false
    
    var availableSongs: [Song] {
        viewModel.songs.filter { song in
            viewModel.videos.map { $0.songName }.contains(song.name)
        }
    }
    
    var songCounts: [Song: Int] {
        viewModel.songs.reduce(into: [:]) { container, song in
            let count = viewModel.videos.count(where: { $0.songName == song.name })
            container[song] = count
        }
    }
    
    var availableSongSet: Set<Song> {
        Set(availableSongs)
    }
    
    
    var body: some View {
        NavigationStack{
            VStack {
                taggerButtonRow
                
                Divider()
                
                ScrollView {
                    VStack {
                        ForEach(viewModel.songs, id: \.id) { song in
                            Text("\(song.name)  \(songQuotas[song.name, default: 0])")
                                .foregroundStyle(foregroundColor(for: song.name))
                                .fontWeight(focusedSong?.id == song.id ? .bold : .regular)
                                .padding(4)
                                .frame(maxWidth: .infinity)
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
                
                VStack {
                    if let song = focusedSong {
                        Image(song.name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                    } else {
                        Image(systemName: "house")
                            .frame(width: 250, height: 250)
                    }
                    
                    NavigationLink(destination: VideoSelectView(song: focusedSong ?? viewModel.songs.first!)) {
                        Text("Play")
                            .foregroundStyle(.white)
                            .frame(width: 250, height: 50)
                            .background(.pink)
                            .clipShape(Capsule())
                    }
                    .disabled(focusedSong == nil)
                }
                .padding(.leading)
            }
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
                .padding()
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
        }
    }
    
    func foregroundColor(for songName: String) -> Color {
        guard let quota = songQuotas[songName] else {
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
