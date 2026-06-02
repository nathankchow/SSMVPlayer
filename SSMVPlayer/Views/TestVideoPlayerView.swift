//
//  TestVideoPlayer.swift
//  SSMVPlayer
//
//  Created by natha on 4/1/26.
//

import Combine
import SwiftUI
import YouTubePlayerKit

struct TestYoutubePlayerView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var youtubePlayer: YouTubePlayer
    @State private var playbackQueue: PlaybackQueue
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        YouTubePlayerView(youtubePlayer)
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                Task {
                    let state = try? await youtubePlayer.getPlaybackState()
                    if state == .ended {
                        if let vid = playbackQueue.nextEntry?.video {
                            let videoID = vid.youtubeURL!.components(separatedBy: "v=").last!
                            try? await youtubePlayer.load(source: .video(id: videoID))
                            playbackQueue.increaseIndex()
                        } else {
                            dismiss()
                        }
                    }
                }
            }
    }
    
//    init(_ urlString: String) {
//        self._youtubePlayer = State(initialValue: YouTubePlayer(urlString: urlString))
//    }
    
    init(_ playlist: Playlist) {
        let queue = PlaybackQueue(playlist)
        self._playbackQueue = State(initialValue: queue)
        self._youtubePlayer = State(initialValue: YouTubePlayer(urlString: queue.currentEntry!.video!.youtubeURL!))
    }
}
