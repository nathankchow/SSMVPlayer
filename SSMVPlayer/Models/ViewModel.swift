//
//  ViewModel.swift
//  SSMVPlayer
//
//  Created by natha on 3/8/26.
//
// #TODO: Find a way to generate videos dynamically instead of bundled json file
// #TODO: double check that youtube songs all match, or implement string similarity in case it doesnt
        // Brand new doesnt work.
        // lets sail away doesnt work either - might have to do with exclamation marks
// #TODO: refactor globals into AppConstants enum

let ALL_EXISTING_SONGS: [String] =  [
    "つぼみ",
    "恋が咲く季節",
    "夢をのぞいたら（for BEST3 VERSION）",
    "Brand new!",
    "Never ends",
    "Let’s Sail Away!!!",
    "VOY@GER",
    "ダンス・ダンス・ダンス",
    "Orange Sapphire",
    "オルゴールの小箱",
    "認めてくれなくたっていいよ",
    "ツインテールの風",
    "とんでいっちゃいたいの",
    "躍るFLAGSHIP",
    "Athanasia",
    "印象",
    "イケナイGO AHEAD",
    "生存本能ヴァルキュリア",
    "Love∞Destiny",
    "クレイジークレイジー",
    "Pretty Liar",
    "Starry-Go-Round",
    "O-Ku-Ri-Mo-No Sunday!",
    "無重力シャトル",
    "バベル",
    "TRUE COLORS",
    "Gossip Club",
    "幸せの法則 ～ルール～",
    "オレンジタイム",
    "Secret Mirage",
    "レッド・ソール",
    "Drastic Melody",
    "UNIQU3 VOICES!!!",
    "ジュビリー",
    "We wish your smile",
    "Never say never",
    "ヴィーナスシンドローム",
    "TOKIMEKIエスカレート",
    "エヴリデイドリーム",
    "Bright Blue",
    "お散歩カメラ",
    "2nd SIDE",
    "薄荷 -ハッカ-",
    "青の一番星",
    "こいかぜ -花葉-",
    "One Life",
    "Last Kiss",
    "もりのくにから",
    "Claw My Heart",
    "14平米にスーベニア",
    "トキメキは赤くて甘い",
    "ステップ！",
    "Frozen Tears",
    "薄紅",
    "夕映えプレゼント",
    "Memories",
    "この空の下",
    "Trancing Pulse",
    "心もよう",
    "M@GIC☆",
    "shabon song",
    "ささのはに、うたかたに。",
    "サマーサイダー"
]

let SONG_QUOTAS: [String: Int] = [
    "つぼみ": 8,
    "恋が咲く季節": 1,
    "夢をのぞいたら（for BEST3 VERSION）": 36,
    "Brand new!": 3,
    "Let’s Sail Away!!!": 3,
    "ダンス・ダンス・ダンス": 2,
    "Orange Sapphire": 1,
    "オルゴールの小箱": 1,
    "認めてくれなくたっていいよ": 1,
    "ツインテールの風": 3,
    "躍るFLAGSHIP": 3,
    "Athanasia": 3,
    "生存本能ヴァルキュリア": 1,
    "Love∞Destiny": 1,
    "クレイジークレイジー": 2,
    "Pretty Liar": 8,
    "Starry-Go-Round": 1,
    "O-Ku-Ri-Mo-No Sunday!": 1,
    "バベル": 2,
    "TRUE COLORS": 1,
    "Gossip Club": 3,
    "オレンジタイム": 3,
    "レッド・ソール": 1,
    "Drastic Melody": 3,
    "UNIQU3 VOICES!!!": 3,
    "ジュビリー": 8,
    "We wish your smile": 8,
    "Never say never": 2,
    "ヴィーナスシンドローム": 2,
    "TOKIMEKIエスカレート": 1,
    "エヴリデイドリーム": 1,
    "Bright Blue": 1,
    "お散歩カメラ": 1,
    "2nd SIDE": 1,
    "薄荷 -ハッカ-": 1,
    "青の一番星": 3,
    "こいかぜ -花葉-": 5,
    "One Life": 5,
    "Last Kiss": 5,
    "もりのくにから": 1,
    "Claw My Heart": 1,
    "14平米にスーベニア": 1,
    "トキメキは赤くて甘い": 1,
    "ステップ！": 1,
    "Frozen Tears": 1,
    "薄紅": 1,
    "夕映えプレゼント": 1,
    "この空の下": 2,
    "Trancing Pulse": 3,
    "心もよう": 3,
    "M@GIC☆": 1,
    "shabon song": 1
]

import Algorithms
import SwiftUI
import Photos

enum VideoGroupType {
    case none
    case full
    case pivot
    case select
}

enum VideoType {
    case local
    case youtube
}

struct SongMetadata {
    let song: Song
    let localGroupType: VideoGroupType
    let youtubeGroupType: VideoGroupType
    let localIdolCount: Int
    let youtubeIdolCount: Int
}

@Observable
final class ViewModel {
    var localVideos: [Video] = []
    var songs: [Song] = []
    var songMetadataDict: [Song: SongMetadata] = [:]
    var youtubeVideos: [Video] = []
    var pivotIdol = "koharu"
    var playlists: [Playlist] = []
    
    private func getAvailableSongs() {
        songs = ALL_EXISTING_SONGS.map { Song(name: $0) }
    }
    
    private func loadVideoURLs() async {
        let options = PHVideoRequestOptions()
// #TODO: what does this do?
        options.deliveryMode = .automatic
// #TODO:  why would network access be allowed?
        options.isNetworkAccessAllowed = true
        
        await withTaskGroup(of: (String, AVAsset?).self) { group in
            for video in localVideos {
                guard let asset = video.asset else { continue }
                let identifier = video.identifier
                
                group.addTask {
                    await withCheckedContinuation { continuation in
                        PHImageManager.default().requestAVAsset(
                            forVideo: asset,
                            options: options
                        ) { avAsset, _, _ in
                            continuation.resume(returning: (identifier, avAsset))
                        }
                    }
                }
            }
            
            for await (identifier, avAsset) in group {
                if let index = self.localVideos.firstIndex(where: { $0.identifier == identifier }) {
                    self.localVideos[index].avAsset = avAsset
                    self.localVideos[index].didSuccessfullyLoad = avAsset != nil
                }
            }
        }
    }
    
    private func getLocalVideoAssets() {
        let identifiers = localVideos.map { $0.identifier }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        assets.enumerateObjects { asset, _, _ in
            if let index = self.localVideos.firstIndex(where: { $0.identifier == asset.localIdentifier }) {
                self.localVideos[index].asset = asset
            }
        }
    }
    
    private func loadYoutubeVideos() -> [Video] {
        guard let url = Bundle.main.url(forResource: "youtube_videos", withExtension: "csv") else {
            return []
        }
        
        let idolNames: Set<String> = ["yukimi", "yoshino", "koharu", "arisu", "yumi"]
        
        let s = try! String(contentsOf: url)
        let lines = s.components(separatedBy: "\n")
            .dropFirst()          // remove header
            .filter { !$0.isEmpty }
        
        return lines.compactMap { line -> Video? in
            // Split on last comma to get title portion and YouTube ID
            guard let commaRange = line.lastIndex(of: ",") else { return nil }
            let titlePart = String(line[line.startIndex..<commaRange])
            let youtubeID = String(line[line.index(after: commaRange)...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Remove the leading Japanese prefix ("デレステ ")
            let tokens = titlePart.components(separatedBy: " ")
            guard tokens.count >= 2 else { return nil }
            let withoutPrefix = tokens.dropFirst()  // drop "デレステ"
            
            // Split withoutPrefix into songName tokens vs idol tokens
            // Idol tokens come at the end; song name is everything before them
            var idols: [String] = []
            var songTokens: [String] = []
            var reachedIdols = false
            
            for token in withoutPrefix.reversed() {
                if !reachedIdols && idolNames.contains(token) {
                    idols.insert(token, at: 0)
                } else {
                    reachedIdols = true
                    songTokens.insert(token, at: 0)
                }
            }
            
            var songName = songTokens.joined(separator: " ")
            songName = getExistingSongName(songName)
            let youtubeURL = "https://www.youtube.com/watch?v=\(youtubeID)"
            
            return Video(
                identifier: youtubeURL,
                songName: songName,
                idols: idols,
                isLocalFile: false,
                youtubeURL: youtubeURL
            )
        }
    }
    
    ///Checks ALL_EXISTING_SONGS for this song name. If it doesn't exist, use string distance to get the closest thing.
    private func getExistingSongName(_ songName: String) -> String {
        if ALL_EXISTING_SONGS.contains(songName) { return songName }

        func levenshteinDistance(_ a: String, _ b: String) -> Int {
            let a = Array(a), b = Array(b)
            var dp = Array(0...b.count)

            for i in 1...max(a.count, 1) {
                guard i <= a.count else { break }
                var prev = dp[0]
                dp[0] = i
                for j in 1...max(b.count, 1) {
                    guard j <= b.count else { break }
                    let temp = dp[j]
                    dp[j] = a[i-1] == b[j-1] ? prev : min(prev, min(dp[j], dp[j-1])) + 1
                    prev = temp
                }
            }

            return dp[b.count]
        }

        var bestDistance: Int = Int.max
        var bestMatch: String = ALL_EXISTING_SONGS.first ?? songName

        for nameCandidate in ALL_EXISTING_SONGS {
            let distance = levenshteinDistance(songName.lowercased(), nameCandidate.lowercased())
            if distance < bestDistance {
                bestDistance = distance
                bestMatch = nameCandidate
            }
        }

        return bestMatch
    }
    
    private func computeSongMetadata() {
        for song in songs {
            let (localGroupType, localIdolCount) = getGroupTypeAndSongCount(song, .local)
            let (youtubeGroupType, youtubeIdolCount) = getGroupTypeAndSongCount(song, .youtube)
            songMetadataDict[song] = SongMetadata(song: song, localGroupType: localGroupType, youtubeGroupType: youtubeGroupType, localIdolCount: localIdolCount, youtubeIdolCount: youtubeIdolCount)
        }
    }
    
    private func getGroupTypeAndSongCount(_ song: Song, _ videoType: VideoType) -> (VideoGroupType, Int){
        let relevantVideos: [Video]
        if videoType == .local {
            relevantVideos = self.localVideos.filter { $0.songName == song.name }
        } else {
            relevantVideos = self.youtubeVideos.filter { $0.songName == song.name }
        }
        guard let firstVideo = relevantVideos.first else { return (.none, 1) }
        let idolCount = firstVideo.idols.count
        if checkFullPickerAvailability(song, relevantVideos, idolCount) { return (.full, idolCount) }
        else if checkPivotPickerAvailability(song, relevantVideos, idolCount) {
            return (.pivot, idolCount)
        } else {
            return (.select, idolCount)
        }
    }
    

    
    func checkFullPickerAvailability(_ song: Song, _ videos: [Video], _ idolCount: Int) -> Bool {
        return checkPickerAvailability(song, videos, idolCount)
    }
    
    func checkPivotPickerAvailability(_ song: Song, _ videos: [Video], _ idolCount: Int) -> Bool {
        return checkPickerAvailability(song, videos, idolCount, usePivotIdolOnly: true)
    }
    
    func checkPickerAvailability(_ song: Song, _ videos: [Video], _ idolCount: Int,  usePivotIdolOnly: Bool = false) -> Bool {
        let relevantVideos = videos
        
        if relevantVideos.filter({ video in video.idols.count != idolCount }).count > 0 { return false }
        
        let idolSet = Set(relevantVideos.map { $0.idols })
        let idols = ["arisu", "koharu", "yoshino", "yumi", "yukimi"] // #TODO: need to un-hard code if generalizing 
        let allPermutations = idols.permutations(ofCount: idolCount).filter { !usePivotIdolOnly || $0.contains(pivotIdol) }
        for perm in allPermutations {
            if !idolSet.contains(perm) { return false }
        }
        
        return true
    }
    

    
    private func loadVideosFromJSON() {
        struct VideoData: Codable {
            let songPersistentID: String
            let songName: String
            let idols: [String]
            
            func toVideo() -> Video {
                Video(identifier: songPersistentID, songName: songName, idols: idols)
            }
        }
        
        do {
            let data = try Data(contentsOf: AlbumVideosView.exportFileURL)
            let videosData = try JSONDecoder().decode([VideoData].self, from: data)
            localVideos = videosData.map { $0.toVideo() }
        } catch {
            print("Failed to load videos.json: \(error)")
        }
    }
    
    func setup() {
        getAvailableSongs()
        loadVideosFromJSON()
        youtubeVideos = loadYoutubeVideos()
        computeSongMetadata()
        Task {
            getLocalVideoAssets()
            await loadVideoURLs()
        }
    }
    
    init() {
        setup()
    }
}


struct Video: Identifiable {
    let id: UUID = UUID()
    var asset: PHAsset? = nil
    var avAsset: AVAsset? = nil
    let identifier: String
    let songName: String
    //let song: Song? = nil
    let idols: [String]
    var isFavorite: Bool = false
    var didSuccessfullyLoad = false
    var isLocalFile = true
    var youtubeURL: String? = nil
}

struct Song: Codable, Hashable {
    let name: String
    let id: UUID = UUID()

    enum CodingKeys: String, CodingKey {
        case name
    }
}


