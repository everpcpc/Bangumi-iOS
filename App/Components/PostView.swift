import SwiftUI

struct PostStateView: View {
  let state: PostState

  init(_ state: PostState) {
    self.state = state
  }

  var body: some View {
    Text(state.description)
      .padding(.leading, 16)
      .overlay {
        Rectangle()
          .fill(state.color)
          .frame(width: 2)
      }
  }
}

struct PostUserDeleteStateView: View {
  let topicId: Int
  let creatorID: Int
  let creator: SlimUserDTO?
  let createdAt: Int
  let author: SlimUserDTO?

  @AppStorage("friendlist") var friendlist: [Int] = []
  @AppStorage("anonymizeTopicUsers") var anonymizeTopicUsers: Bool = false

  init(
    _ topicId: Int = 0, _ creatorID: Int, _ creator: SlimUserDTO?, _ createdAt: Int,
    _ author: SlimUserDTO? = nil
  ) {
    self.topicId = topicId
    self.creatorID = creatorID
    self.creator = creator
    self.createdAt = createdAt
    self.author = author
  }

  var anonymizedHash: String {
    AnonymizationHelper.generateHash(topicId: topicId, userId: creatorID)
  }

  var body: some View {
    HStack(spacing: 4) {
      PosterLabel(uid: creatorID, poster: author?.id)
      FriendLabel(uid: creatorID)
      if anonymizeTopicUsers && topicId != 0 {
        if let creator = creator {
          Text(anonymizedHash.withLink(creator.link)).lineLimit(1)
        } else {
          Text(anonymizedHash).lineLimit(1)
        }
      } else if let creator = creator {
        Text(creator.nickname.withLink(creator.link)).lineLimit(1)
      } else {
        Text("用户 \(creatorID)")
          .lineLimit(1)
      }
      Text("删除了回复")
        .font(.footnote)
        .foregroundStyle(.secondary)
      Spacer()
      Text(createdAt.datetimeDisplay)
        .lineLimit(1)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }
}

struct PostAdminOffTopicStateView: View {
  let topicId: Int
  let creatorID: Int
  let creator: SlimUserDTO?
  let createdAt: Int
  let author: SlimUserDTO?

  @AppStorage("friendlist") var friendlist: [Int] = []
  @AppStorage("anonymizeTopicUsers") var anonymizeTopicUsers: Bool = false

  init(
    _ topicId: Int = 0, _ creatorID: Int, _ creator: SlimUserDTO?, _ createdAt: Int,
    _ author: SlimUserDTO? = nil
  ) {
    self.topicId = topicId
    self.creatorID = creatorID
    self.creator = creator
    self.createdAt = createdAt
    self.author = author
  }

  var anonymizedHash: String {
    AnonymizationHelper.generateHash(topicId: topicId, userId: creatorID)
  }

  var body: some View {
    HStack(spacing: 4) {
      PosterLabel(uid: creatorID, poster: author?.id)
      FriendLabel(uid: creatorID)
      if anonymizeTopicUsers && topicId != 0 {
        if let creator = creator {
          Text(anonymizedHash.withLink(creator.link)).lineLimit(1)
        } else {
          Text(anonymizedHash).lineLimit(1)
        }
      } else if let creator = creator {
        Text(creator.nickname.withLink(creator.link)).lineLimit(1)
      } else {
        Text("用户 \(creatorID)")
          .lineLimit(1)
      }
      Text("回复被折叠")
        .font(.footnote)
        .foregroundStyle(.secondary)
      Spacer()
      Text(createdAt.datetimeDisplay)
        .lineLimit(1)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }
}
