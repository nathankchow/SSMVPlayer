//
//  SoundEngine.swift
//  SSMVPlayer
//
//  Created by natha on 7/4/26.
//

import AVKit

final class SoundEngine {
    var currentSong: String = ""
    var previewPlayer: AVAudioPlayer? = nil
    var sfxPlayer: AVAudioPlayer? = nil
    
    static let sampleFileName = "夢をのぞいたら（for BEST3 VERSION）"
    
    func previewStart() {
        previewPlayer?.numberOfLoops = -1
        previewPlayer?.play()
    }
    
    func previewPauseAndRewind() {
        previewPlayer?.pause()
        previewPlayer?.currentTime = 0.0
        previewPlayer?.pause()
    }
    
    func previewStop() {
        previewPlayer?.stop()
    }
    
    
    func changeSong(_ song: Song) {
        previewStop()
        let name = song.name
        let url = Bundle.main.url(forResource: name, withExtension: "m4a")
        if let url = url {
            previewPlayer = try? AVAudioPlayer(contentsOf: url)
            previewStart()
        } else {
            previewPlayer = nil
        }
    }
    
//    func debugChangeSong() {
//        let url = Bundle.main.url(forResource: SoundEngine.sampleFileName, withExtension: "m4a")
//        if let url = url {
//            print("Successful - \(url)")
//            previewPlayer = try? AVAudioPlayer(contentsOf: url)
//            previewStart()
//        } else { print("load failed") }
//    }
//    
//    init() {
//        print("Creating sound engine.")
//        debugChangeSong()
//    }
}
