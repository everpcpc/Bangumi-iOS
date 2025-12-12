import SwiftUI

struct ProgressSecondLineView: View {
  @AppStorage("progressSecondLineMode") var progressSecondLineMode: ProgressSecondLineMode =
    .subtitle
  @AppStorage("titlePreference") var titlePreference: TitlePreference = .original

  @Environment(Subject.self) var subject

  var body: some View {
    switch progressSecondLineMode {
    case .subtitle:
      if let subtitle = subject.subtitle(with: titlePreference) {
        Text(subtitle)
          .foregroundStyle(.secondary)
          .font(.subheadline)
          .lineLimit(1)
      }
    case .category:
      Text(subject.category)
        .foregroundStyle(.secondary)
        .font(.subheadline)
    case .watching:
      let doing = subject.collection.doing
      let collect = subject.collection.collect
      if doing > 0 || collect > 0 {
        Text("\(doing) 人在看 · \(collect) 人看过")
          .foregroundStyle(.secondary)
          .font(.footnote)
      }
    case .ratingRank:
      let rank = subject.rating.rank
      let score = subject.rating.score
      let total = subject.rating.total
      if rank > 0 || score > 0 {
        HStack(spacing: 12) {
          if rank > 0 {
            Text("#\(rank)")
              .foregroundStyle(.secondary)
              .font(.footnote)
          }
          if total > 10 {
            if score > 0 {
              StarsView(score: score, size: 12)
              Text("\(score.rateDisplay)")
                .font(.caption)
                .foregroundStyle(.orange)
            }
          } else {
            Text("(少于10人评分)")
              .foregroundStyle(.secondary)
              .font(.caption)
          }
        }
      }
    case .airTime:
      if !subject.airtime.date.isEmpty {
        Text(subject.airtime.date)
          .foregroundStyle(.secondary)
          .font(.subheadline)
      }
    case .info:
      if !subject.info.isEmpty {
        Text(subject.info)
          .foregroundStyle(.secondary)
          .font(.caption)
          .lineLimit(2)
      }
    case .metaTag:
      let tags = subject.metaTags.prefix(5)
      if !tags.isEmpty {
        HStack(spacing: 4) {
          ForEach(tags, id: \.self) { tag in
            Text(tag)
              .fixedSize()
              .padding(2)
              .background(.secondary.opacity(0.1))
              .clipShape(RoundedRectangle(cornerRadius: 5))
          }
        }
        .foregroundStyle(.secondary)
        .font(.caption)
      }
    }
  }
}
