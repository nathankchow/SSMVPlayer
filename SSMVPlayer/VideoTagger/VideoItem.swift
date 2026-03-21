import SwiftUI
import Photos

struct VideoItem: Identifiable {
    let id: String          // Persistent local identifier (stable across app launches)
    let asset: PHAsset

    // Metadata
    let creationDate: Date?
    let modificationDate: Date?
    let duration: TimeInterval
    let width: Int
    let height: Int
    let isFavorite: Bool
    let mediaSubtypes: PHAssetMediaSubtype
    let sourceType: PHAssetSourceType

    init(asset: PHAsset) {
        self.id = asset.localIdentifier   // Persistent unique ID
        self.asset = asset
        self.creationDate = asset.creationDate
        self.modificationDate = asset.modificationDate
        self.duration = asset.duration
        self.width = asset.pixelWidth
        self.height = asset.pixelHeight
        self.isFavorite = asset.isFavorite
        self.mediaSubtypes = asset.mediaSubtypes
        self.sourceType = asset.sourceType
    }

    // MARK: - Computed helpers

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var resolution: String {
        "\(width) × \(height)"
    }

    var formattedDate: String {
        guard let date = creationDate else { return "Unknown date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var isSlowMotion: Bool {
        mediaSubtypes.contains(.videoHighFrameRate)
    }

    var isTimelapse: Bool {
        mediaSubtypes.contains(.videoTimelapse)
    }

    var isCinematic: Bool {
        if #available(iOS 15.0, *) {
            return mediaSubtypes.contains(.videoCinematic)
        }
        return false
    }

    var videoType: String {
        if isCinematic { return "Cinematic" }
        if isSlowMotion { return "Slow-Mo" }
        if isTimelapse { return "Time-lapse" }
        return "Video"
    }

    var shortID: String {
        let parts = id.split(separator: "/")
        return parts.first.map(String.init) ?? id
    }

    var sourceTypeLabel: String {
        switch sourceType {
        case .typeUserLibrary: return "Camera / User Library"
        case .typeCloudShared: return "iCloud Shared"
        case .typeiTunesSynced: return "iTunes Synced"
        default: return "Unknown"
        }
    }
}
