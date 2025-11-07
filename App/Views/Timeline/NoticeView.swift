import SwiftUI

struct NoticeView: View {
  @AppStorage("isAuthenticated") var isAuthenticated: Bool = false

  @State private var fetched: Bool = false
  @State private var updating: Bool = false
  @State private var notices: [NoticeDTO] = []
  @State private var unreadCount: Int = 0

  func loadNotice() async throws {
    let resp = try await Chii.shared.listNotice(limit: 20)
    notices = resp.data
    unreadCount = notices.count(where: { $0.unread })
  }

  func refreshNotice() async {
    updating = true
    do {
      try await loadNotice()
    } catch {
      Notifier.shared.alert(error: error)
    }
    fetched = true
    updating = false
  }

  func clearNotice() {
    if updating { return }
    updating = true
    let ids = notices.map { $0.id }
    Task {
      do {
        try await Chii.shared.clearNotice(ids: ids)
        try await loadNotice()
      } catch {
        Notifier.shared.alert(error: error)
      }
      for i in 0..<notices.count {
        notices[i].unread = false
      }
      updating = false
    }
  }

  func markAsRead(id: Int) {
    updating = true
    Task {
      do {
        try await Chii.shared.clearNotice(ids: [id])
        if let index = notices.firstIndex(where: { $0.id == id }) {
          notices[index].unread = false
          unreadCount = notices.count(where: { $0.unread })
        }
      } catch {
        Notifier.shared.alert(error: error)
      }
    }
    updating = false
  }

  var body: some View {
    if isAuthenticated {
      List {
        if !fetched {
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }
        } else {
          ForEach(notices.indices, id: \.self) { index in
            NoticeRowView(notice: $notices[index])
              .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
              .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if notices[index].unread {
                  Button {
                    markAsRead(id: notices[index].id)
                  } label: {
                    Label("已读", systemImage: "checkmark")
                  }
                  .tint(.blue)
                }
              }
          }
        }
      }
      .animation(.default, value: notices)
      .refreshable {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        await refreshNotice()
      }
      .navigationTitle(unreadCount > 0 ? "电波提醒 (\(unreadCount))" : "电波提醒")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            clearNotice()
          } label: {
            Label("全部已读", systemImage: "checkmark.rectangle.stack")
              .adaptiveButtonStyle(.borderedProminent)
          }
          .disabled(unreadCount == 0 || updating)
        }
      }
      .task {
        await refreshNotice()
      }
    } else {
      AuthView(slogan: "请登录 Bangumi 以查看通知")
    }
  }
}

#Preview {
  let container = mockContainer()

  return NoticeView()
    .modelContainer(container)
}
