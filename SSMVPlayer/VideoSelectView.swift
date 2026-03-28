//
//  VideoSelectView.swift
//  SSMVPlayer
//
//  Created by natha on 3/9/26.
//
// #TODO: force lock horizontal in video
// #TODO: heavy temporary logic to test youtube videos - need to undo/revise
// #TODO: logic for idolCount for youtube videos not right

import AVKit
import SwiftUI
import YouTubePlayerKit

struct VideoSelectView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var showVideoOverlay: Bool = false
    @State private var showYoutubeOverlay: Bool = false
    @State var selectedIdols: [String] = ["yumi", "arisu", "koharu", "yukimi", "yoshino"] //only applies to full/pivot row selector
    @State var focusedVideo: Video? //only applies to static row selector
    
    var videoToPlay: Video? {
        if canUsePivotSelector {
            return songVideos.first { $0.idols == selectedActiveIdols }
        } else if canUseFullSelector && !forceDisableFullSelector{
            return viewModel.youtubeVideos.first{ $0.idols == selectedActiveIdols && $0.songName == song.name}
        } else {
            return focusedVideo
        }
    }
    
    let song: Song
    
    var songVideos: [Video] {
        viewModel.videos.filter{
            $0.songName == song.name
        }
        .sorted(by: { $0.idols.joined(separator: "") < $1.idols.joined(separator: "") })
    }
    
//    var canUseFullSelector: Bool {
//        return viewModel.checkFullPickerAvailability(song)
//    }
    
    var canUseFullSelector: Bool {
        return viewModel.youtubeVideos.map{ $0.songName }.contains(song.name)
    }
    
    var canUsePivotSelector: Bool {
        return viewModel.checkPivotPickerAvailability(song)
    }
    
    @State var forceDisableFullSelector = true
    
    var selectedActiveIdols: [String] {
        let idolCount: Int
        if canUsePivotSelector || !canUseFullSelector || forceDisableFullSelector{
            idolCount = songVideos.first?.idols.count ?? 1
        } else {
            idolCount = viewModel.youtubeVideos.filter({$0.songName == song.name}).first?.idols.count ?? 1
        }
        let order = [4,2,1,3,5]
        return selectedIdols.indices
            .filter { order[$0] <= idolCount }
            .map { selectedIdols[$0] }
    }
    
    var body: some View {
        Group {
            VStack {
                Toggle("Disable Full Selector", isOn: $forceDisableFullSelector)
                    .padding(.horizontal)
                if canUsePivotSelector {
                    DynamicIdolRowView($selectedIdols, hasPivotIdol: true, idolCount: songVideos.first?.idols.count ?? 1)
                } else if canUseFullSelector && !forceDisableFullSelector {
                    DynamicIdolRowView($selectedIdols, hasPivotIdol: false, idolCount: songVideos.first?.idols.count ?? 1)
                } else {
                    listIdolSelector
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) {
            Button {
                if canUsePivotSelector || !canUseFullSelector || forceDisableFullSelector
                { showVideoOverlay = true }
                else { showYoutubeOverlay = true }
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
            if let avAsset = videoToPlay?.avAsset {
                let playerItem = AVPlayerItem(asset: avAsset)
                let player = AVPlayer(playerItem: playerItem)
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                    }
            }
        }
        .sheet(isPresented: $showYoutubeOverlay) {
            YouTubePlayerView(YouTubePlayer(stringLiteral: videoToPlay?.youtubeURL ?? ""))
                .ignoresSafeArea()
        }
    }
    
    var listIdolSelector: some View {
        ScrollView{
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
    }
}

#Preview {
    VideoSelectView(song: Song(name: "Pretty Liar"))
        .environment(ViewModel())
}
