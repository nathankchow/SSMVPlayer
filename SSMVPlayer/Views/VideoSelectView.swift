//
//  VideoSelectView.swift
//  SSMVPlayer
//
//  Created by natha on 3/9/26.
//
// #TODO: logic for idolCount for youtube videos not right
// #TODO: only need one state var for video to play
// #TODO: bring the selector up to the top of the screen for selector grouping

import AVKit
import SwiftUI
import YouTubePlayerKit

struct VideoSelectView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var localVideoToPlay: Video? = nil
    @State private var youtubeVideoToPlay: Video? = nil
    @State var selectedIdols: [String] = ["yumi", "arisu", "koharu", "yukimi", "yoshino"] //only applies to full/pivot row selector
    @State var focusedVideo: Video? //only applies to static row selector
    @State var useYoutubeVideos = false

    
    let song: Song
    let songMetadata: SongMetadata
    let playlist: Playlist?
    let playlistEntryIndex: Int
    
    var isPlaylistContext: Bool {
        playlist != nil
    }
    
    var confirmButtonLabel: String {
        isPlaylistContext ? "Set idols" : "Play"
    }
    

    
    var songVideos: [Video] {
        if !useYoutubeVideos {
            viewModel.localVideos.filter{
                $0.songName == song.name
            }
            .sorted(by: { $0.idols.joined(separator: "") < $1.idols.joined(separator: "") })
        } else {
            viewModel.youtubeVideos.filter{
                $0.songName == song.name
            }
            .sorted(by: { $0.idols.joined(separator: "") < $1.idols.joined(separator: "") })
        }
    }
    
    var groupType: VideoGroupType {
        useYoutubeVideos ? songMetadata.youtubeGroupType : songMetadata.localGroupType
    }
    
    var idolCount: Int {
        useYoutubeVideos ? songMetadata.youtubeIdolCount : songMetadata.localIdolCount
    }
    
    var selectedActiveIdols: [String] {
        let order = [4,2,1,3,5]
        return selectedIdols.indices
            .filter { order[$0] <= idolCount }
            .map { selectedIdols[$0] }
    }

    
    var body: some View {
        Group {
            VStack {
                Toggle("Use youtube videos", isOn: $useYoutubeVideos)
                    .padding(.horizontal)
                
                Group {
                    if groupType == .none {
                        Text("No videos available")
                            .fontWeight(.bold)
                    } else if groupType == .select {
                        listIdolSelector
                    } else {
                        DynamicIdolRowView($selectedIdols, hasPivotIdol: groupType == .pivot, idolCount: idolCount)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) {
            Button {
                if isPlaylistContext {
                    let video = useYoutubeVideos ? getYoutubeVideoToPlay() : getLocalVideoToPlay()
                    guard let video = video else {
                        dismiss()
                        return
                    }
                    playlist?.entries[playlistEntryIndex].video = video
                    dismiss()
                } else {
                    if groupType == .none { return }
                    viewModel.soundEngine.previewPauseAndRewind()
                    if !useYoutubeVideos { localVideoToPlay = getLocalVideoToPlay() }
                    else { youtubeVideoToPlay = getYoutubeVideoToPlay() }
                }
            } label: {
                Text(confirmButtonLabel)
                    .foregroundStyle(.white)
                    .frame(width: 160, height: 40)
                    .background(.pink)
                    .clipShape(Capsule())
                    .padding()
            }
            .disabled(groupType == .none)
        }
        .navigationTitle(song.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            focusedVideo = songVideos.first ?? nil
            if songMetadata.youtubeGroupType == .none {
                useYoutubeVideos = false
            } else if songMetadata.localGroupType == .none {
                useYoutubeVideos = true
            }
        }
        .sheet(item: $localVideoToPlay, onDismiss: {
            viewModel.soundEngine.previewStart()
        }) { video in
            if let avAsset = video.avAsset {
                let playerItem = AVPlayerItem(asset: avAsset)
                let player = AVPlayer(playerItem: playerItem)
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                    }
            }
        }
        .sheet(item: $youtubeVideoToPlay, onDismiss: {
            viewModel.soundEngine.previewStart()
        }) { video in
            YouTubePlayerView(YouTubePlayer(stringLiteral: video.youtubeURL ?? ""))
                .ignoresSafeArea()
//            TestYoutubePlayerView(video.youtubeURL ?? "")
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
    
    
    
    func getLocalVideoToPlay() -> Video? {
        switch groupType {
        case .none:
            return nil
        case .select:
            return focusedVideo
        default:
            return viewModel.localVideos.first{ $0.idols == selectedActiveIdols && $0.songName == song.name}
        }
    }
        
    func getYoutubeVideoToPlay() -> Video? {
        switch groupType {
        case .none:
            return nil
        case .select:
            return focusedVideo
        default:
            return viewModel.youtubeVideos.first{ $0.idols == selectedActiveIdols && $0.songName == song.name}
        }
    }
    
    
    init(song: Song, metadata: SongMetadata, playlist: Playlist? = nil, playlistEntryIndex: Int = 0) {
        self.song = song
        self.songMetadata = metadata
        self.playlist = playlist
        self.playlistEntryIndex = playlistEntryIndex
    }
}
        

//#Preview {
//    VideoSelectView(song: Song(name: "Pretty Liar"))
//        .environment(ViewModel())
//}
