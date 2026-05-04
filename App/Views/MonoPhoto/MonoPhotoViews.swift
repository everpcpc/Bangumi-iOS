import BBCode
import SwiftUI

enum MonoPhotoOwner: Hashable {
  case character(Int)
  case person(Int)

  var title: String {
    switch self {
    case .character:
      return "角色相册"
    case .person:
      return "人物相册"
    }
  }

  func photoCommentType(photoId: Int) -> CommentParentType {
    switch self {
    case .character(let id):
      return .characterPhoto(id, photoId)
    case .person(let id):
      return .personPhoto(id, photoId)
    }
  }

  func loadPhotos(limit: Int, offset: Int) async throws -> PagedDTO<MonoPhotoDTO> {
    switch self {
    case .character(let id):
      return try await Chii.shared.getCharacterPhotos(id, limit: limit, offset: offset)
    case .person(let id):
      return try await Chii.shared.getPersonPhotos(id, limit: limit, offset: offset)
    }
  }

  func loadPhoto(photoId: Int) async throws -> MonoPhotoDTO {
    switch self {
    case .character(let id):
      return try await Chii.shared.getCharacterPhoto(id, photoID: photoId)
    case .person(let id):
      return try await Chii.shared.getPersonPhoto(id, photoID: photoId)
    }
  }

  func loadPhotoComments(photoId: Int) async throws -> [CommentDTO] {
    switch self {
    case .character(let id):
      return try await Chii.shared.getCharacterPhotoComments(id, photoID: photoId)
    case .person(let id):
      return try await Chii.shared.getPersonPhotoComments(id, photoID: photoId)
    }
  }
}

struct MonoPhotosSectionView: View {
  let owner: MonoPhotoOwner
  let photos: [MonoPhotoDTO]

  private let columns = [
    GridItem(.adaptive(minimum: 92, maximum: 140), spacing: 8)
  ]

  var body: some View {
    VStack(spacing: 2) {
      HStack(alignment: .bottom) {
        Text("相册")
          .foregroundStyle(photos.isEmpty ? .secondary : .primary)
          .font(.title3)
        Spacer()
        if !photos.isEmpty {
          NavigationLink(value: NavDestination.monoPhotoList(owner)) {
            Text("更多图片 »").font(.caption)
          }.buttonStyle(.navigation)
        }
      }
      Divider()
    }.padding(.top, 5)
    if photos.isEmpty {
      HStack {
        Spacer()
        Text("暂无图片")
          .font(.caption)
          .foregroundStyle(.secondary)
        Spacer()
      }.padding(.bottom, 5)
    } else {
      LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
        ForEach(photos) { photo in
          MonoPhotoGridItemView(owner: owner, photo: photo)
        }
      }
      .padding(.bottom, 8)
      .animation(.default, value: photos)
    }
  }
}

struct MonoPhotoListView: View {
  let owner: MonoPhotoOwner

  private let columns = [
    GridItem(.adaptive(minimum: 112, maximum: 180), spacing: 10)
  ]

  @State private var items: [MonoPhotoDTO] = []
  @State private var loading = false
  @State private var offset = 0
  @State private var exhausted = false

  private let limit = 24

  private func shouldLoadMore(after item: MonoPhotoDTO, threshold: Int = 8) -> Bool {
    items.suffix(threshold).contains(item)
  }

  func reload() {
    loading = true
    exhausted = false
    offset = 0
    Task {
      defer { loading = false }
      await loadPage(currentOffset: 0, replacing: true)
    }
  }

  func loadNextPage() async {
    if loading || exhausted { return }
    loading = true
    defer { loading = false }
    await loadPage(currentOffset: offset, replacing: false)
  }

  private func loadPage(currentOffset: Int, replacing: Bool) async {
    do {
      let resp = try await owner.loadPhotos(limit: limit, offset: currentOffset)
      if resp.data.isEmpty {
        exhausted = true
        if replacing {
          items = []
        }
        return
      }
      offset = currentOffset + limit
      exhausted = offset >= resp.total
      let updatedItems =
        replacing ? [MonoPhotoDTO]().mergedById(with: resp.data) : items.mergedById(with: resp.data)
      if items != updatedItems {
        withAnimation {
          items = updatedItems
        }
      }
    } catch {
      Notifier.shared.alert(error: error)
    }
  }

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
        ForEach(items) { photo in
          MonoPhotoGridItemView(owner: owner, photo: photo)
            .onAppear {
              if shouldLoadMore(after: photo) {
                Task { await loadNextPage() }
              }
            }
        }
      }
      .padding(8)

      if loading {
        ProgressView()
          .padding()
      }
      if exhausted {
        Text("没有更多了")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .padding(.bottom, 12)
      }
    }
    .onAppear {
      if items.isEmpty {
        reload()
      }
    }
    .refreshable {
      reload()
    }
    .navigationTitle(owner.title)
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct MonoPhotoView: View {
  let owner: MonoPhotoOwner
  let photoId: Int

  @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
  @AppStorage("isolationMode") var isolationMode: Bool = false

  @State private var photo: MonoPhotoDTO?
  @State private var comments: [CommentDTO] = []
  @State private var loadingComments = false
  @State private var showCommentBox = false

  var title: String {
    guard let photo, !photo.title.isEmpty else {
      return "图片"
    }
    return photo.title
  }

  func load() async {
    do {
      photo = try await owner.loadPhoto(photoId: photoId)
      if !isolationMode {
        loadingComments = true
        defer { loadingComments = false }
        comments = try await owner.loadPhotoComments(photoId: photoId)
      }
    } catch {
      Notifier.shared.alert(error: error)
    }
  }

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 10) {
        if let photo {
          MonoPhotoDetailContentView(photo: photo)
          if !isolationMode {
            MonoPhotoCommentsView(
              type: owner.photoCommentType(photoId: photoId),
              comments: comments,
              loading: loadingComments
            )
          }
        } else {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }.padding()
        }
      }
      .padding(.horizontal, 8)
      .padding(.bottom, 12)
    }
    .refreshable {
      Task { await load() }
    }
    .task(load)
    .sheet(isPresented: $showCommentBox) {
      CreateCommentBoxSheet(type: owner.photoCommentType(photoId: photoId)) {
        Task { await load() }
      }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          showCommentBox = true
        } label: {
          Label("吐槽", systemImage: "plus.bubble")
        }
        .disabled(!isAuthenticated)
      }
    }
  }
}

private struct MonoPhotoGridItemView: View {
  let owner: MonoPhotoOwner
  let photo: MonoPhotoDTO

  var body: some View {
    NavigationLink(value: NavDestination.monoPhoto(owner, photo.id)) {
      VStack(alignment: .leading, spacing: 4) {
        ImageView(img: photo.images.resize(.r400))
          .imageStyle(aspectRatio: 1, cornerRadius: 6, alignment: .center)
          .imageType(.photo)
          .imageNSFW(photo.spoiler)
        if !photo.title.isEmpty {
          Text(photo.title)
            .font(.caption)
            .lineLimit(1)
            .truncationMode(.tail)
        }
      }
    }
    .buttonStyle(.plain)
  }
}

private struct MonoPhotoDetailContentView: View {
  let photo: MonoPhotoDTO

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ImageView(img: photo.images.large)
        .imageStyle(cornerRadius: 6, alignment: .center)
        .imageType(.photo)
        .imageNSFW(photo.spoiler)
        .enableSave(photo.images.large)
        .frame(maxWidth: .infinity)
      if !photo.title.isEmpty {
        Text(photo.title)
          .font(.title3.bold())
          .textSelection(.enabled)
      }
      HStack(spacing: 8) {
        if let user = photo.user {
          Text(user.nickname.withLink(user.link))
        } else {
          Text("用户 \(photo.creatorID)")
        }
        Text(photo.createdAt.datetimeDisplay)
          .foregroundStyle(.secondary)
      }
      .font(.caption)
      if !photo.comment.isEmpty {
        BBCodeView(photo.comment)
          .tint(.linkText)
          .textSelection(.enabled)
      }
      if !photo.tags.isEmpty {
        Text(photo.tags.map { "#\($0)" }.joined(separator: " "))
          .font(.caption)
          .foregroundStyle(.secondary)
          .textSelection(.enabled)
      }
    }
  }
}

private struct MonoPhotoCommentsView: View {
  let type: CommentParentType
  let comments: [CommentDTO]
  let loading: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack {
        Text("吐槽箱").font(.title3)
        if loading {
          ProgressView()
            .controlSize(.small)
        }
      }
      Divider()
    }
    LazyVStack(alignment: .leading, spacing: 8) {
      ForEach(Array(zip(comments.indices, comments)), id: \.1) { idx, comment in
        CommentItemView(type: type, comment: comment, idx: idx)
        if comment.id != comments.last?.id {
          Divider()
        }
      }
    }
  }
}
