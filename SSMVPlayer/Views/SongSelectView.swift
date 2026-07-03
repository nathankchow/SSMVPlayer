//
//  ContentView.swift
//  SSMVPlayer
//
//  Created by natha on 3/8/26.
// #TODO: why do we need a songmetadatadict? can't we just put all that information onto the song object directly?
extension Color {
    static let customWhite  = Color(red: 254/255, green: 254/255, blue: 254/255)
    static let customRed    = Color(red: 254/255, green: 48/255,  blue: 129/255)
    static let customBlue   = Color(red: 13/255,  green: 114/255, blue: 254/255)
    static let customOrange = Color(red: 254/255, green: 170/255, blue: 17/255)
    static let customBlack  = Color(red: 65/255,  green: 65/255,  blue: 65/255)
    static let customGray = Color(red: 220/255,  green: 220/255,  blue: 220/255)
    static let customPink = Color(red: 254/255,  green: 178/255,  blue: 233/255)
    }

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
    
    func songRow(song: Song, isFocused: Bool) -> some View {
        HStack{
            Text("\(getSongQuotaString(song))\(song.name)")
                .lineLimit(1)
                .foregroundStyle(foregroundColor(for: song))
                .fontWeight(focusedSong?.id == song.id ? .bold : .regular)
                .padding(4)

            
            Spacer()
            
            if viewModel.songMetadataDict[song]?.localIdolCount ?? 0 > 0 {
                Text("Local")
                    .font(.caption)
                    .padding(.horizontal, 4)
                    .foregroundStyle(Color.customWhite)
                    .background(.blue)
                    .clipShape(Capsule())
            }
            
            if viewModel.songMetadataDict[song]?.youtubeIdolCount ?? 0 > 0 {
                Text("YouTube")
                    .font(.caption)
                    .padding(.horizontal, 4)
                    .foregroundStyle(Color.customWhite)
                    .background(.red)
                    .clipShape(Capsule())
                
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, minHeight: 35, alignment: .leading)
        .background(Color.customWhite)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .contentShape(Rectangle())
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(focusedSong?.id == song.id ? Color.red : Color.clear, lineWidth: 3)
        )
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            taggerButtonRow
                .frame(maxWidth: .infinity)
                .background(Color.customPink)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 3) {
                    ForEach(viewModel.songs, id: \.id) { song in
                        songRow(song: song, isFocused: focusedSong == song)
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
        .background(Color.customGray)
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
    
    func getSongQuotaString(_ song: Song) -> String {
        if DEBUG_MODE { return "(\(String(songCounts[song, default: 0]))) " }
        else { return "" }
    }
    
    func foregroundColor(for song: Song) -> Color {
        guard let song = viewModel.songs.first(where: { $0 == song }),
              let _ = songCounts[song] else {
            return .gray
        }
        
        guard let attribute = viewModel.songMetadataDict[song]?.attribute else {
            return .primary
        }
        
        if attribute == "cute" {
            return .customRed
        } else if attribute == "cool" {
            return .customBlue
        } else if attribute == "passion" {
            return .customOrange
        } else {
            return .customBlack
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
