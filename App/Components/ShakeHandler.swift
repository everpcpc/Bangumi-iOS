import SwiftUI
import UIKit

struct ShakeHandler: UIViewControllerRepresentable {
  @AppStorage("titlePreference") var titlePreference: TitlePreference = .original

  func makeUIViewController(context: Context) -> ShakeViewController {
    ShakeViewController()
  }

  func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {
    uiViewController.onShake = {
      // Toggle between chinese and original
      titlePreference = titlePreference == .chinese ? .original : .chinese

      // Provide haptic feedback
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()

      // Show notification
      let preferenceText = titlePreference == .chinese ? "中文名优先" : "原名优先"
      Notifier.shared.notify(message: "已切换为\(preferenceText)")
    }
  }
}

class ShakeViewController: UIViewController {
  var onShake: (() -> Void)?

  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      onShake?()
    }
  }
}
