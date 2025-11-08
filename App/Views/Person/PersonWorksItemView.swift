import Flow
import SwiftUI

struct PersonWorksItemView: View {
  let item: PersonWorkDTO

  var body: some View {
    CardView {
      HStack(alignment: .top) {
        ImageView(img: item.subject.images?.resize(.r200))
          .imageStyle(width: 60, height: 60)
          .imageType(.subject)
          .imageLink(item.subject.link)
        VStack(alignment: .leading) {
          VStack(alignment: .leading) {
            Text(item.subject.name.withLink(item.subject.link))
              .font(.callout)
              .lineLimit(1)
            if item.subject.nameCN.isEmpty {
              Label(item.subject.type.description, systemImage: item.subject.type.icon)
                .lineLimit(1)
                .font(.footnote)
                .foregroundStyle(.secondary)
            } else {
              Label(item.subject.nameCN, systemImage: item.subject.type.icon)
                .lineLimit(1)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            Text(item.subject.info ?? "")
              .font(.caption)
              .lineLimit(1)
              .foregroundStyle(.secondary)
            Divider()
          }.frame(height: 60)
          HFlow {
            ForEach(item.positions) { position in
              HStack {
                BorderView {
                  Text(position.type.cn).font(.caption)
                }
              }
              .foregroundStyle(.secondary)
              .lineLimit(1)
            }
          }
        }
        Spacer(minLength: 0)
      }
    }
  }
}
