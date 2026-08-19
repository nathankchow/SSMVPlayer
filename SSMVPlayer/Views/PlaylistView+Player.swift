import AVKit
import Combine
import SwiftUI
import YouTubePlayerKit

// #TODO: see if can find a way to proactively guarantee 1080p

@Observable
class DualPlayerManager {
    var youtubePlayer: YouTubePlayer?
    var localPlayer: AVPlayer?
    var playbackQueue: PlaybackQueue
    var isFinished = false

    private var localObserver: NSObjectProtocol?

    init(_ playlist: Playlist, index: Int) {
        self.playbackQueue = PlaybackQueue(playlist, index: index)
    }

    func loadCurrentVideo() {
        guard let video = playbackQueue.currentVideo else {
            isFinished = true
            return
        }
        
        cleanPlayerState()
        
        if video.isLocalFile {
            if let avAsset = video.avAsset {
                let playerItem = AVPlayerItem(asset: avAsset)
                let player = AVPlayer(playerItem: playerItem)
                self.localPlayer = player
                addLocalObserver(for: player)
                Task { [weak self] in
                    try? await Task.sleep(for: .seconds(1))
                    self?.localPlayer?.play()
                }
            }
        } else if let url = video.youtubeURL {
            self.youtubePlayer = YouTubePlayer(urlString: url)
            playCurrentYoutubeVideo()
        }
    }

    func playNextVideo() {
        guard let _ = playbackQueue.nextVideo else {
            isFinished = true
            return
        }
        
        playbackQueue.increaseIndex()
        loadCurrentVideo()
    }

    func cleanPlayerState() {
        removeLocalObserver()
        localPlayer = nil
        youtubePlayer = nil
    }

    private func addLocalObserver(for player: AVPlayer) {
        localObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.playNextVideo()
        }
    }

    private func removeLocalObserver() {
        if let observer = localObserver {
            NotificationCenter.default.removeObserver(observer)
            localObserver = nil
        }
    }
    
    func playCurrentYoutubeVideo() {
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            try? await self?.youtubePlayer?.play()
        }
    }


    deinit {
        removeLocalObserver()
    }
}

struct PlaylistPlayerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var manager: DualPlayerManager?
    @State private var hasAppeared = false

    let youtubeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let playlist: Playlist
    let index: Int

    var body: some View {
        Group {
            if manager?.youtubePlayer != nil {
                YouTubePlayerView(manager!.youtubePlayer!)
                    .ignoresSafeArea()
                    .id(manager?.youtubePlayer?.source?.id)
                    .onReceive(youtubeTimer) { _ in
                        Task {
                            let state = try? await manager?.youtubePlayer?.getPlaybackState()
                            if state == .ended {
                                manager?.playNextVideo()
                            }
                        }
                    }
            } else if let player = manager?.localPlayer {
                VideoPlayer(player: player)
                    .id(player.currentItem)
                    .ignoresSafeArea()
            } else {
                Text("Playback finished. Slide down to exit.")
                    .font(.title)
            }
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            manager = DualPlayerManager(playlist, index: index)
            manager?.loadCurrentVideo()
        }
        .onChange(of: manager?.isFinished) { _, finished in
            if finished == true { dismiss() }
        }
    }
    
    
}
