//
//  ViewModel.swift
//  SSMVPlayer
//
//  Created by natha on 3/8/26.
//
// #TODO: Find a way to generate videos dynamically instead of bundled json file

import SwiftUI
import Photos

@Observable
final class ViewModel {
    var videos: [Video] = []
    var songs: [Song] = []
    
    
    private func getAvailableSongs() {
        do {
            let url = Bundle.main.url(forResource: "songs", withExtension: "json")
            // #TODO: dont force unwrap
            let data = try Data(contentsOf: url!)
            songs = try JSONDecoder().decode([Song].self, from: data)
        } catch {
            print("something bad happened)")
        }
    }
    
    func getVideoAssets() {
        let identifiers = videos.map { $0.identifier }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        assets.enumerateObjects { asset, _, _ in
            if let index = self.videos.firstIndex(where: { $0.identifier == asset.localIdentifier }) {
                self.videos[index].asset = asset
            }
        }
    }
    
    private func loadVideoURLs() async {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true

        await withTaskGroup(of: (String, AVAsset?).self) { group in
            for video in videos {
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
                if let index = self.videos.firstIndex(where: { $0.identifier == identifier }) {
                    self.videos[index].avAsset = avAsset
                    self.videos[index].didSuccessfullyLoad = avAsset != nil
                }
            }
        }
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
            videos = videosData.map { $0.toVideo() }
        } catch {
            print("Failed to load videos.json: \(error)")
        }
    }
    
    func setup() {
        getAvailableSongs()
        loadVideosFromJSON()
        Task {
            getVideoAssets()
            await loadVideoURLs()
        }
    }
    
    init() {
        setup()
    }
}


struct Video {
    let id: UUID = UUID()
    var asset: PHAsset? = nil
    var avAsset: AVAsset? = nil
    let identifier: String
    let songName: String
    let idols: [String]
    var isFavorite: Bool = false
    var didSuccessfullyLoad = false
    var isLocalFile = true
}

struct Song: Codable {
    let name: String
    let id: UUID = UUID()

    enum CodingKeys: String, CodingKey {
        case name
    }
}
