import Foundation
import SwiftUI

let HANDOFF_ACTIVITY_TYPE = "com.everpcpc.chobits.viewPage"

extension View {
  func handoff(activityType: String = HANDOFF_ACTIVITY_TYPE, url: URL, title: String? = nil) -> some View {
    modifier(HandoffModifier(activityType: activityType, url: url, title: title))
  }
}

private struct HandoffModifier: ViewModifier {
  let activityType: String
  let url: URL
  let title: String?

  @State private var activity: NSUserActivity?

  func body(content: Content) -> some View {
    content
      .onAppear {
        let userActivity = NSUserActivity(activityType: activityType)
        userActivity.webpageURL = url
        userActivity.title = title
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = false
        userActivity.isEligibleForPublicIndexing = false
        self.activity = userActivity
        userActivity.becomeCurrent()
      }
      .onDisappear {
        activity?.invalidate()
        activity = nil
      }
  }
}
