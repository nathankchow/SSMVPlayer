import SwiftUI
import Photos

struct AlbumItem: Identifiable {
    let id: String
    let collection: PHAssetCollection
    let title: String
    let videoCount: Int
    let coverAsset: PHAsset?

    func fetchVideos() -> [VideoItem] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        let assets = PHAsset.fetchAssets(in: collection, options: options)
        var items: [VideoItem] = []
        assets.enumerateObjects { asset, _, _ in items.append(VideoItem(asset: asset)) }
        return items
    }
}

@Observable
class VideoLibraryViewModel {
    var albums: [AlbumItem] = []
    var isLoading = false

    init() {
        loadAlbums()
    }

    func loadAlbums() {
        isLoading = true
        albums = []

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard status == .authorized || status == .limited else {
                Task { @MainActor in self?.isLoading = false }
                return
            }

            var result: [AlbumItem] = []
            let videosPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)

            let collectionTypes: [(PHAssetCollectionType, PHAssetCollectionSubtype)] = [
                (.smartAlbum, .smartAlbumVideos),
                (.smartAlbum, .smartAlbumSlomoVideos),
                (.smartAlbum, .smartAlbumTimelapses),
                (.smartAlbum, .smartAlbumCinematic),
                (.smartAlbum, .smartAlbumUserLibrary),
                (.album, .albumRegular),
                (.album, .albumSyncedAlbum),
                (.album, .albumCloudShared),
            ]

            for (type, subtype) in collectionTypes {
                let collections = PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: nil)
                collections.enumerateObjects { collection, _, _ in
                    let countOptions = PHFetchOptions()
                    countOptions.predicate = videosPredicate
                    let count = PHAsset.fetchAssets(in: collection, options: countOptions).count
                    guard count > 0 else { return }

                    let coverOptions = PHFetchOptions()
                    coverOptions.predicate = videosPredicate
                    coverOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    coverOptions.fetchLimit = 1
                    let cover = PHAsset.fetchAssets(in: collection, options: coverOptions).firstObject

                    result.append(AlbumItem(
                        id: collection.localIdentifier,
                        collection: collection,
                        title: collection.localizedTitle ?? "Untitled",
                        videoCount: count,
                        coverAsset: cover
                    ))
                }
            }

            Task { @MainActor in
                self?.albums = result
                self?.isLoading = false
            }
        }
    }
}
