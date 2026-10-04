//
//  ContentView.swift
//  SSMVPlayer
//
//  Created by natha on 3/8/26.
// #TODO: why do we need a songmetadatadict? can't we just put all that information onto the song object directly?
// #TODO: try using a color set + dark mode colors
// #TODO: coding style - get rid of force optional unwraps
// #TODO: song preview artifacts: orgel, orange sapphire, + one more(?)
// #TODO: tsubomi song badly cut
// #TODO: consider using a tabview to navigate to playlists + tagger


import SwiftUI

struct SongSelectView: View {
    @Environment(ViewModel.self) private var viewModel
    @State var focusedSong: Song? = nil
    @State var filterIdolCount = -1
    @State var didSetInitialSong = false
    @State var didOpenPicker = false
    
    var filterIdolCountChoices = [-1,5,4,3,2,1]
        
    var availableSongs: [Song] {
        let available = viewModel.songs
        if filterIdolCount == -1 { return available }
        return available.filter {
            viewModel.songMetadataDict[$0]?.canonicalIdolCount ?? -1 == filterIdolCount
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
            topButtonRow
            
            songPicker
            
            idolCountPicker
            
            bottomSection
        }
        .onAppear {
            onAppearCallback()
        }
        .onChange(of: focusedSong) { oldSong, newSong in
            if newSong == nil { return }
            guard let newSong = newSong else { return }
            viewModel.soundEngine.changeSong(newSong)
        }
    }
    
    var topButtonRow: some View {
        HStack {
            NavigationLink(destination:
                VideoTaggerView()
                    .onAppear{
                        viewModel.soundEngine.previewPauseAndRewind()
                        didOpenPicker = true
                    }
            ) {
                HStack {
                    Image(systemName: "tag.fill")
                    Text("Tagger")
                }
                .foregroundStyle(Color.customBlack)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            
            Divider()
                .frame(height: 26)
            
            NavigationLink(destination:
                PlaylistCreateView()
                    .onAppear{
                        viewModel.soundEngine.previewPauseAndRewind()
                    }
            ) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Playlists")
                }
                .foregroundStyle(Color.customBlack)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            
            Divider()
                .frame(height: 26)
            
            NavigationLink(destination:
                SettingsView()
                    .onAppear{
                        viewModel.soundEngine.previewPauseAndRewind()
                    }
            ) {
                HStack {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .foregroundStyle(Color.customBlack)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }

        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.customPink)
    }
    
    var idolCountPicker: some View {
        Menu {
            Button {
                filterIdolCount = -1
            } label: {
                HStack {
                    Text("Any")
                    Image(systemName: "person.fill")
                }
            }

            ForEach((1...5).reversed(), id: \.self) { i in
                Button {
                    filterIdolCount = i
                } label: {
                    HStack {
                        Text("\(i)")
                        Image(systemName: "person.fill")
                    }
                }
            }
        } label: {
            HStack {
                Text(filterIdolCount == -1 ? "Any" : "\(filterIdolCount)")
                Image(systemName: "person.fill")
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity)
        .background(Color.customSkyBlue)
        .tint(Color.customWhite)
    }
    
    var songPicker: some View {
        ScrollView {
            VStack(spacing: 3) {
                ForEach(availableSongs, id: \.id) { song in
                    songRow(song: song, isFocused: focusedSong == song)
                    .onTapGesture {
                        if focusedSong != song {
                            focusedSong = song
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(Color.customGray)
    }
    
    func songRow(song: Song, isFocused: Bool) -> some View {
        HStack{
            Text("\(getSongQuotaString(song))\(song.name)")
                .lineLimit(1)
                .foregroundStyle(foregroundColor(for: song))
//                .fontWeight(focusedSong?.id == song.id ? .bold : .regular)
                .fontWeight(.bold)
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
    
    var bottomSection: some View {
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
            VStack(spacing: 0) {
                Button {
                    focusedSong = getRandomSong()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 36))
                        Text("Random")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                NavigationLink(destination: VideoSelectView(song: focusedSong ?? viewModel.songs.first!, metadata: viewModel.songMetadataDict[focusedSong ?? viewModel.songs.first!]!)) {
                    VStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 36))
                        Text("Play")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(focusedSong == nil)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.customDarkGray)
    }
    
    func getRandomSong() -> Song? {
        //never return current focused song if > 1 songs available
        if availableSongs.count == 0 { return focusedSong }
        if availableSongs.count == 1 { return availableSongs.first }
        guard let currentSong = focusedSong else { return focusedSong } //focusedSong should never be nil
        return availableSongs
            .filter{$0 != currentSong}
            .randomElement()
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
    
    func onAppearCallback() {
        if !didSetInitialSong {
            focusedSong = availableSongs.first
            didSetInitialSong = true
        }
        viewModel.soundEngine.previewStart()
        
        if didOpenPicker {
            didOpenPicker = false
            viewModel.setup()
        }
    }

}




#Preview {
    SongSelectView()
        .environment(ViewModel())
}
