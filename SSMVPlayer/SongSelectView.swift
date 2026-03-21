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
    
    var body: some View {
        NavigationStack{
            HStack {
                
                VStack{
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
                
                
                
                ScrollView {
                    VStack {
                        ForEach(availableSongs, id: \.id) { song in
                            Text(song.name)
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
}



//#Preview {
//    SongSelectView()
//        .environment(ViewModel())
//}

#Preview {
    SongSelectView()
        .environment(ViewModel())
}
