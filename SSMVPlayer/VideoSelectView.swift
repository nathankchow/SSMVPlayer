//
//  VideoSelectView.swift
//  SSMVPlayer
//
//  Created by natha on 3/9/26.
//

import SwiftUI
import AVKit

struct VideoSelectView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var showVideoOverlay: Bool = false
    
    let song: Song
    @State var focusedVideo: Video?
    var songVideos: [Video] {
        viewModel.videos.filter{ $0.songName == song.name }
    }
    
    var body: some View {
        ScrollView {
            ForEach(songVideos, id: \.id) { video in
                StaticIdolRowView(video.idols)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(focusedVideo?.id == video.id ? Color.red : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        focusedVideo = video
                    }
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) {
            Button {
                print("Hello world!")
                showVideoOverlay = true
            } label: {
                Text("Play")
                    .foregroundStyle(.white)
                    .frame(width: 160, height: 40)
                    .background(.pink)
                    .clipShape(Capsule())
                    .padding()
            }
        }
        .navigationTitle(song.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            focusedVideo = songVideos.first ?? nil
        }
        .sheet(isPresented: $showVideoOverlay) {
            if let avAsset = focusedVideo?.avAsset {
                let playerItem = AVPlayerItem(asset: avAsset)
                let player = AVPlayer(playerItem: playerItem)
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                    }
            }
        }
    }
}

#Preview {
    VideoSelectView(song: Song(name: "Pretty Liar"))
        .environment(ViewModel())
}
