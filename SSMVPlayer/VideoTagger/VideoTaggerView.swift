import SwiftUI
import Photos
import AVFoundation
import AVKit

// MARK: - ContentView (Album List)

struct VideoTaggerView: View {
    @State private var viewModel = VideoLibraryViewModel()
    @State private var tagStore = TagStore()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading albums...")
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.albums.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Albums Found")
                            .font(.title2).bold()
                        Text("No albums containing videos were found.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List(viewModel.albums) { album in
                        NavigationLink(destination: AlbumVideosView(album: album, tagStore: tagStore)) {
                            AlbumRowView(album: album)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Video Albums")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.isLoading {
                        Text("\(viewModel.albums.count) albums")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - AlbumRowView

struct AlbumRowView: View {
    let album: AlbumItem
    @State private var thumbnail: UIImage?

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let thumb = thumbnail {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(Image(systemName: "film").foregroundColor(.secondary))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.headline)
                Text("\(album.videoCount) video\(album.videoCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .task { await loadThumbnail() }
    }

    private func loadThumbnail() async {
        guard let asset = album.coverAsset else { return }
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = true

        await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 128, height: 128),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                Task { @MainActor in self.thumbnail = image }
                continuation.resume()
            }
        }
    }
}

// MARK: - AlbumVideosView

struct AlbumVideosView: View {
    let album: AlbumItem
    let tagStore: TagStore
    @State private var videos: [VideoItem] = []
    @State private var showingCopiedConfirmation = false
    @State private var copiedMessage = ""

    var body: some View {
        Group {
            if videos.isEmpty {
                ProgressView()
            } else {
                List(videos) { video in
                    NavigationLink(destination: VideoDetailView(video: video, tagStore: tagStore)) {
                        VideoRowView(video: video, tagStore: tagStore)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(videos.count) video\(videos.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    exportJSON()
                } label: {
                    Label("Copy JSON", systemImage: "doc.on.clipboard")
                }
                .disabled(videos.isEmpty)
            }
        }
        .overlay(alignment: .bottom) {
            if showingCopiedConfirmation {
                Label(copiedMessage, systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .clipShape(Capsule())
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: showingCopiedConfirmation)
        .task {
            videos = album.fetchVideos()
        }
    }

    private func exportJSON() {
        struct ExportEntry: Encodable {
            let songPersistentID: String
            let songName: String
            let idols: [String]
        }

        let entries = videos.compactMap { video -> ExportEntry? in
            let tag = tagStore.tag(for: video.id)
            guard tag.isTagged else { return nil }
            let filledIdols = tag.idols.filter { !$0.isEmpty }
            return ExportEntry(
                songPersistentID: video.id,
                songName: tag.songName,
                idols: filledIdols
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]

        guard let data = try? encoder.encode(entries) else {
            copiedMessage = "Encoding failed"
            showingCopiedConfirmation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showingCopiedConfirmation = false }
            return
        }

        do {
            try data.write(to: Self.exportFileURL, options: .atomic)
            copiedMessage = "Saved \(entries.count) entr\(entries.count == 1 ? "y" : "ies")"
            showingCopiedConfirmation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showingCopiedConfirmation = false }
        } catch {
            copiedMessage = "Save failed: \(error.localizedDescription)"
            showingCopiedConfirmation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showingCopiedConfirmation = false }
        }
    }

    static let exportFileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("videos.json")
    }()
}

// MARK: - VideoRowView

struct VideoRowView: View {
    let video: VideoItem
    let tagStore: TagStore
    @State private var thumbnail: UIImage?

    private var tag: VideoTag { tagStore.tag(for: video.id) }

    var body: some View {
        HStack(spacing: 12) {
            // Tagged / untagged indicator strip
            RoundedRectangle(cornerRadius: 2)
                .fill(tag.isTagged ? Color.green : Color.orange)
                .frame(width: 4)
                .padding(.vertical, 6)

            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let thumb = thumbnail {
                        Image(uiImage: thumb)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(Image(systemName: "video.fill").foregroundColor(.secondary))
                    }
                }
                .frame(width: 90, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(video.formattedDuration)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.65))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(4)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Label(video.videoType, systemImage: videoTypeIcon)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(videoTypeColor)
                        .clipShape(Capsule())

                    if video.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .font(.caption2)
                    }
                }

                Text(video.formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if tag.isTagged {
                    Text(tag.songName)
                        .font(.caption)
                        .foregroundColor(.green)
                        .lineLimit(1)
                } else {
                    Text("Untagged")
                        .font(.caption)
                        .foregroundColor(.orange)
                }

                Text(video.resolution)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .task { await loadThumbnail() }
    }

    private var videoTypeIcon: String {
        switch video.videoType {
        case "Cinematic": return "camera.aperture"
        case "Slow-Mo": return "gauge.with.dots.needle.33percent"
        case "Time-lapse": return "timer"
        default: return "video.fill"
        }
    }

    private var videoTypeColor: Color {
        switch video.videoType {
        case "Cinematic": return .purple
        case "Slow-Mo": return .blue
        case "Time-lapse": return .orange
        default: return .gray
        }
    }

    private func loadThumbnail() async {
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = true

        await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: video.asset,
                targetSize: CGSize(width: 180, height: 120),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                Task { @MainActor in self.thumbnail = image }
                continuation.resume()
            }
        }
    }
}

// MARK: - FullscreenPlayerView
// Presented via .fullScreenCover — AVPlayerViewController's native "Done" button
// dismisses the cover automatically, no delegate needed.

struct FullscreenPlayerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        controller.showsPlaybackControls = true
        controller.videoGravity = .resizeAspect
        player.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

// MARK: - VideoDetailView

struct VideoDetailView: View {
    let video: VideoItem
    let tagStore: TagStore

    @State private var fileSize: String = "Loading..."
    @State private var fileName: String = "Loading..."
    @State private var isCopied = false
    @State private var playerURL: URL?
    @State private var isLoadingPlayer = true
    @State private var showingFullscreen = false
    @State private var previewThumbnail: UIImage?

    // Local editable copy of the tag, written back on every change
    @State private var tag: VideoTag = VideoTag(id: "")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Thumbnail preview — tap to play fullscreen
                ZStack {
                    Color.black

                    if let thumb = previewThumbnail {
                        Image(uiImage: thumb)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    }

                    if isLoadingPlayer {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.white, .black.opacity(0.45))
                            .shadow(radius: 6)
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(CGSize(width: video.width, height: video.height), contentMode: .fit)
                .onTapGesture {
                    if playerURL != nil { showingFullscreen = true }
                }
                .fullScreenCover(isPresented: $showingFullscreen) {
                    if let url = playerURL {
                        FullscreenPlayerView(url: url)
                            .ignoresSafeArea()
                    }
                }

                VStack(alignment: .leading, spacing: 20) {

                    // Type / favourite row
                    HStack {
                        Label(video.videoType, systemImage: "video.fill")
                            .font(.headline)
                        Spacer()
                        if video.isFavorite {
                            Label("Favorite", systemImage: "heart.fill")
                                .foregroundColor(.pink)
                                .font(.subheadline)
                        }
                    }

                    Divider()

                    // MARK: Tagging
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tagging", systemImage: "music.note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        // Song Name → navigates to picker
                        NavigationLink(destination: SongNameDetailView(tag: $tag, onChange: save)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Song Name")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(tag.songName.isEmpty ? "None selected" : tag.songName)
                                        .foregroundColor(tag.songName.isEmpty ? .secondary : .primary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)

                        // Idol dropdowns
                        ForEach(0..<5, id: \.self) { i in
                            IdolPickerRow(
                                label: "Idol \(i + 1)",
                                selection: Binding(
                                    get: { tag.idols[i] },
                                    set: { tag.idols[i] = $0; save() }
                                )
                            )
                        }
                    }

                    Divider()

                    // File Name
                    VStack(alignment: .leading, spacing: 8) {
                        Label("File Name", systemImage: "doc.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(fileName)
                            .font(.system(.footnote, design: .monospaced))
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Divider()

                    // Persistent ID
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Persistent Local Identifier", systemImage: "tag.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack {
                            Text(video.id)
                                .font(.system(.footnote, design: .monospaced))
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 8)
                            Button {
                                UIPasteboard.general.string = video.id
                                isCopied = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isCopied = false }
                            } label: {
                                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                    .foregroundColor(isCopied ? .green : .accentColor)
                            }
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text("Stable across app launches. Re-fetch with PHAsset.fetchAssets(withLocalIdentifiers:).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Metadata
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Metadata", systemImage: "info.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        MetadataGrid(rows: [
                            ("calendar",    "Created",    video.formattedDate),
                            ("clock",       "Duration",   video.formattedDuration),
                            ("aspectratio", "Resolution", video.resolution),
                            ("doc.fill",    "File Size",  fileSize),
                            ("camera.fill", "Source",     video.sourceTypeLabel),
                        ])
                    }

                    if let modDate = video.modificationDate {
                        Text("Last modified: \(modDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Video Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            tag = tagStore.tag(for: video.id)
        }
        .task {
            await loadFileInfo()
            await loadPlayerURL()
            await loadPreviewThumbnail()
        }
    }

    private func save() {
        tagStore.update(tag)
    }

    private func loadPlayerURL() async {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true

        await withCheckedContinuation { continuation in
            PHImageManager.default().requestAVAsset(
                forVideo: video.asset,
                options: options
            ) { avAsset, _, _ in
                Task { @MainActor in
                    self.playerURL = (avAsset as? AVURLAsset)?.url
                    self.isLoadingPlayer = false
                }
                continuation.resume()
            }
        }
    }

    private func loadPreviewThumbnail() async {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: video.asset,
                targetSize: CGSize(width: 1280, height: 720),
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                Task { @MainActor in self.previewThumbnail = image }
                continuation.resume()
            }
        }
    }

    private func loadFileInfo() async {
        let resources = PHAssetResource.assetResources(for: video.asset)
        guard let resource = resources.first(where: { $0.type == .video }) else {
            await MainActor.run { fileSize = "N/A"; fileName = "N/A" }
            return
        }
        let name = resource.originalFilename
        let size = resource.value(forKey: "fileSize") as? Int64
        let formatted = size.map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) } ?? "N/A"
        await MainActor.run {
            self.fileName = name
            self.fileSize = formatted
        }
    }
}

// MARK: - SongNameDetailView

struct SongNameDetailView: View {
    @Binding var tag: VideoTag
    let onChange: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            // "None" option
            Button {
                tag.songName = ""
                onChange()
                dismiss()
            } label: {
                HStack {
                    Text("None")
                        .foregroundColor(.secondary)
                        .italic()
                    Spacer()
                    if tag.songName.isEmpty {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .buttonStyle(.plain)

            ForEach(SongNameList.names, id: \.self) { name in
                Button {
                    tag.songName = name
                    onChange()
                    dismiss()
                } label: {
                    HStack {
                        Text(name)
                        Spacer()
                        if tag.songName == name {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Song Name")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - IdolPickerRow

struct IdolPickerRow: View {
    let label: String
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Menu {
                Button("None") { selection = "" }
                ForEach(IdolList.names, id: \.self) { name in
                    Button(name.capitalized) { selection = name }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? "Select idol" : selection.capitalized)
                        .foregroundColor(selection.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

// MARK: - MetadataGrid

struct MetadataGrid: View {
    let rows: [(String, String, String)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack {
                    Label(row.1, systemImage: row.0)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 140, alignment: .leading)
                    Text(row.2)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(index % 2 == 0 ? Color(.systemGray6) : Color(.systemBackground))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 0.5))
    }
}
