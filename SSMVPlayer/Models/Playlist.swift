//
//  Playlist.swift
//  SSMVPlayer
//
//  Created by natha on 5/21/26.
//

import Foundation



@Observable
class Playlist: Hashable, Equatable, Identifiable {
    let id = UUID()
    var entries: [PlaylistEntry] = []
    var name: String
    let dateCreated: Date = Date()
    
    static func samplePlaylist() -> Playlist {
        let playlist = Playlist(name: "Sample Playlist")
        let sampleVideos = [
            Video(
                identifier: "sasanohani",
                songName: "ささのはに、うたかたに。",
                idols: ["yoshino", "yumi", "koharu", "yukimi", "arisu"],
                isLocalFile: false,
                youtubeURL: "https://www.youtube.com/watch?v=TszKK8_qnYM"
            ),
            Video(
                identifier: "voyager",
                songName: "VOY@GER",
                idols: ["yukimi", "koharu", "arisu"],
                isLocalFile: false,
                youtubeURL: "https://www.youtube.com/watch?v=tqlBS6CZf7g"
            ),
            Video(
                identifier: "babel",
                songName: "バベル",
                idols: ["arisu", "koharu"],
                isLocalFile: false,
                youtubeURL: "https://www.youtube.com/watch?v=_9cVssxXFV4"
            )
        ]
        playlist.entries = sampleVideos.map { PlaylistEntry(song: Song(name: $0.songName), video: $0) }
        return playlist
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(name: String) {
        self.name = name
    }
}

struct PlaylistEntry {
    var id = UUID()
    var song: Song
    var video: Video?
}

@Observable
class PlaybackQueue {
    var playlist: Playlist
    var videos: [Video]
    var index: Int

    var currentVideo: Video? {
        guard self.videos.indices.contains(index) else { return nil }
        return self.videos[index]
    }
    
    var nextVideo: Video? {
        guard self.videos.indices.contains(index+1) else { return nil }
        return self.videos[index+1]
    }
    
    func increaseIndex() {
        if let _ = nextVideo {
            index += 1
        }
    }
    
    init(_ playlist: Playlist, index: Int) {
        self.playlist = playlist
        self.videos = playlist.entries.compactMap{ $0.video }
        self.index = index
    }
}
