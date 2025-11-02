import SwiftUI

struct HotGroupsView: View {
  @State private var groups: [SlimGroupDTO] = []
  @State private var loading = false

  private func load() async {
    loading = true
    defer { loading = false }

    do {
      let resp = try await Chii.shared.getGroups(mode: .all, sort: .members, limit: 10)
      groups = resp.data
    } catch {
      Notifier.shared.alert(error: error)
    }
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("热门小组").font(.title3)
        Spacer()
      }.padding(.top, 8)
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack {
          ForEach(groups) { group in
            VStack {
              ImageView(img: group.icon?.large)
                .imageStyle(width: 80, height: 80)
                .imageType(.icon)
                .imageLink(group.link)
              Text(group.title)
                .lineLimit(2)
                .font(.footnote)
                .foregroundStyle(.secondary)
              Text("\(group.members ?? 0) 位成员")
                .font(.caption)
                .foregroundStyle(.secondary)
            }.frame(width: 80, height: 120)
          }
        }
      }.frame(height: 120)
    }
    .onAppear {
      Task {
        await load()
      }
    }
  }
}
