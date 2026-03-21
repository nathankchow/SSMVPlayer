//
//  TagStore.swift
//  VIdeoLibrary
//
//  Created by natha on 3/8/26.
//

import Foundation

// MARK: - VideoTag

struct VideoTag: Codable, Identifiable {
    var id: String          // PHAsset.localIdentifier
    var songName: String
    var idols: [String]     // always 5 elements

    init(id: String, songName: String = "", idols: [String] = Array(repeating: "", count: 5)) {
        self.id = id
        self.songName = songName
        // Ensure always exactly 5 slots
        var padded = idols
        while padded.count < 5 { padded.append("") }
        self.idols = Array(padded.prefix(5))
    }

    var isTagged: Bool { !songName.isEmpty }
}

// MARK: - TagStore

@Observable
class TagStore {
    private static let key = "videoTags"

    private(set) var tags: [String: VideoTag] = [:]   // keyed by localIdentifier

    init() {
        load()
    }

    // Returns tag for a given video ID, creating an empty one if needed
    func tag(for id: String) -> VideoTag {
        tags[id] ?? VideoTag(id: id)
    }

    func update(_ tag: VideoTag) {
        tags[tag.id] = tag
        save()
    }
    
    //conversion from migrating tagger to player app
    func hydrateFromVideos(_ videos: [Video]) {
        for video in videos {
            // Don't overwrite existing tags
            guard tags[video.identifier] == nil else { continue }
            
            let tag = VideoTag(
                id: video.identifier,
                songName: video.songName,
                idols: video.idols
            )
            tags[tag.id] = tag
        }
        save()
    }

    // MARK: - Persistence

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: Self.key),
            let decoded = try? JSONDecoder().decode([VideoTag].self, from: data)
        else { return }
        tags = Dictionary(uniqueKeysWithValues: decoded.map { ($0.id, $0) })
    }

    private func save() {
        let array = Array(tags.values)
        if let data = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }
}

// MARK: - Song list

struct SongName: Decodable {
    let name: String
    let `extension`: String
}

enum SongNameList {
    static let songs: [SongName] = {
        guard
            let url = Bundle.main.url(forResource: "songs", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([SongName].self, from: data)
        else { return [] }
        return decoded
    }()

    static let names: [String] = songs.map(\.name)
}

// MARK: - Idol choices

enum IdolList {
    static let names = ["arisu", "koharu", "yukimi", "yumi", "yoshino"]
}
