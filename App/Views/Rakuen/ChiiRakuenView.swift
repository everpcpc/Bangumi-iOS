import SwiftUI

enum RakuenListMode: String, CaseIterable {
  case trendingSubjectTopics = "trending_subject_topics"
  case groupTopics = "group_topics"

  var description: String {
    switch self {
    case .trendingSubjectTopics:
      return "热门条目讨论"
    case .groupTopics:
      return "小组话题"
    }
  }
}

struct ChiiRakuenView: View {
  @AppStorage("rakuenListMode") var rakuenListMode: RakuenListMode = .trendingSubjectTopics

  @State private var reloader = false

  var body: some View {
    ScrollView {
      VStack {
        HotGroupsView()
        VStack(alignment: .leading, spacing: 5) {
          HStack {
            HStack(spacing: 2) {
              Picker("", selection: $rakuenListMode) {
                ForEach(RakuenListMode.allCases, id: \.self) { mode in
                  Text(mode.description).tag(mode)
                }
              }
              .pickerStyle(.segmented)
            }
            Spacer()
          }.padding(.top, 8)
          ZStack(alignment: .topLeading) {
            RakuenSubjectTopicListView(mode: .trending, reloader: $reloader)
              .opacity(rakuenListMode == .trendingSubjectTopics ? 1 : 0)
              .allowsHitTesting(rakuenListMode == .trendingSubjectTopics)
              .frame(maxWidth: .infinity, alignment: .leading)
            RakuenGroupTopicListView(mode: .joined, reloader: $reloader)
              .opacity(rakuenListMode == .groupTopics ? 1 : 0)
              .allowsHitTesting(rakuenListMode == .groupTopics)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      }.padding(.horizontal, 8)
    }
    .refreshable {
      reloader.toggle()
    }
    .animation(.default, value: rakuenListMode)
    .navigationTitle("超展开")
    .toolbarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu {
          Menu {
            ForEach(SubjectTopicFilterMode.allCases, id: \.self) { mode in
              NavigationLink(value: NavDestination.rakuenSubjectTopics(mode)) {
                Text(mode.description)
              }
            }
          } label: {
            Text("条目讨论")
          }

          Menu {
            ForEach(GroupTopicFilterMode.allCases, id: \.self) { mode in
              NavigationLink(value: NavDestination.rakuenGroupTopics(mode)) {
                Text(mode.description)
              }
            }
          } label: {
            Text("小组话题")
          }
          Divider()

          Menu {
            ForEach(GroupFilterMode.allCases, id: \.self) { mode in
              NavigationLink(value: NavDestination.groupList(mode)) {
                Text(mode.description)
              }
            }
          } label: {
            Text("浏览小组")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
    }
  }
}
