import SwiftUI

struct UserHomeView: View {
  @Bindable var user: User

  func ctypes(_ stype: SubjectType) -> [CollectionType: Int] {
    var result: [CollectionType: Int] = [:]
    for ct in CollectionType.allTypes() {
      guard let count = user.stats?.subject.stats[stype]?[ct] else { continue }
      if count > 0 {
        result[ct] = count
      }
    }
    return result
  }

  var body: some View {
    VStack {
      ForEach(user.homepage.left, id: \.self) { section in
        VStack {
          switch section {
          case .none:
            EmptyView()

          case .anime:
            UserSubjectCollectionView(user: user, stype: .anime, ctypes: ctypes(.anime))

          case .blog:
            if let count = user.stats?.blog, count > 0 {
              UserBlogsView(user: user)
            }

          case .book:
            UserSubjectCollectionView(user: user, stype: .book, ctypes: ctypes(.book))

          case .friend:
            if let count = user.stats?.friend, count > 0 {
              UserFriendsView(user: user)
            }

          case .game:
            UserSubjectCollectionView(user: user, stype: .game, ctypes: ctypes(.game))

          case .group:
            if let count = user.stats?.group, count > 0 {
              UserGroupsView(user: user)
            }

          case .index:
            if let count = user.stats?.index.create, count > 0 {
              UserIndexesView(user: user)
            }

          case .mono:
            if let count = user.stats?.mono.character, count > 0 {
              UserCharacterCollectionView(user: user)
            }
            if let count = user.stats?.mono.person, count > 0 {
              UserPersonCollectionView(user: user)
            }

          case .music:
            UserSubjectCollectionView(user: user, stype: .music, ctypes: ctypes(.music))

          case .real:
            UserSubjectCollectionView(user: user, stype: .real, ctypes: ctypes(.real))
          }
        }
      }
    }
  }
}
