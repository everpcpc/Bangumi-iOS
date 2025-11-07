import SwiftUI

struct ChiiRakuenView: View {
  @AppStorage("rakuenListMode") var rakuenListMode: GroupTopicFilterMode = .joined

  @State private var reloader = false

  var body: some View {
    ScrollView {
      VStack {
        HotGroupsView()
        VStack(alignment: .leading, spacing: 5) {
          HStack {
            HStack(spacing: 2) {
              Picker(selection: $rakuenListMode, label: Text("话题列表")) {
                ForEach(GroupTopicFilterMode.allCases, id: \.self) { mode in
                  Text(mode.description).tag(mode)
                }
              }
            }
            Spacer()
          }.padding(.top, 8)
          RakuenGroupTopicListView(mode: rakuenListMode, reloader: $reloader)
        }
      }.padding(.horizontal, 8)
    }
    .refreshable {
      reloader.toggle()
    }
    .onChange(of: rakuenListMode) {
      reloader.toggle()
    }
    .navigationTitle("超展开")
    .toolbarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu {
          Section {
            ForEach(SubjectTopicFilterMode.allCases, id: \.self) { mode in
              NavigationLink(value: NavDestination.rakuenSubjectTopics(mode)) {
                Text(mode.description)
              }
            }
          } header: {
            Text("条目讨论")
          }
          Divider()

          Section {
            ForEach(GroupTopicFilterMode.allCases, id: \.self) { mode in
              NavigationLink(value: NavDestination.rakuenGroupTopics(mode)) {
                Text(mode.description)
              }
            }
          } header: {
            Text("小组话题")
          }
          Divider()

          Section {
            ForEach(GroupFilterMode.allCases, id: \.self) { mode in
              NavigationLink(value: NavDestination.groupList(mode)) {
                Text(mode.description)
              }
            }
          } header: {
            Text("小组")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
    }
  }
}
