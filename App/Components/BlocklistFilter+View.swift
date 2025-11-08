import SwiftUI

struct BlocklistFilter: ViewModifier {
  let uid: Int
  let placeholder: Bool

  @AppStorage("hideBlocklist") var hideBlocklist: Bool = false
  @AppStorage("blocklist") var blocklist: [Int] = []

  func body(content: Content) -> some View {
    if hideBlocklist, blocklist.contains(uid) {
      if placeholder {
        Rectangle()
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [Color.secondary, Color.clear]),
              startPoint: .leading,
              endPoint: .trailing)
          )
          .frame(height: 8)
      }
    } else {
      content
    }
  }
}

extension View {
  func blocklistFilter(_ uid: Int, placeholder: Bool = true) -> some View {
    modifier(BlocklistFilter(uid: uid, placeholder: placeholder))
  }
}
