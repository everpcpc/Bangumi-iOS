import Flow
import SwiftData
import SwiftUI

struct PersonWorksView: View {
  let personId: Int
  let works: [PersonWorkDTO]

  var body: some View {
    VStack(spacing: 2) {
      HStack(alignment: .bottom) {
        Text("最近参与")
          .foregroundStyle(works.count > 0 ? .primary : .secondary)
          .font(.title3)
        Spacer()
        if works.count > 0 {
          NavigationLink(value: NavDestination.personWorkList(personId)) {
            Text("更多作品 »").font(.caption)
          }.buttonStyle(.navigation)
        }
      }
      Divider()
    }.padding(.top, 5)
    VStack {
      ForEach(works) { item in
        PersonWorksItemView(item: item)
      }
    }
    .padding(.bottom, 8)
    .animation(.default, value: works)
  }
}

#Preview {
  let container = mockContainer()
  let person = Person.preview
  container.mainContext.insert(person)

  return NavigationStack {
    ScrollView {
      LazyVStack(alignment: .leading) {
        PersonWorksView(personId: person.personId, works: person.works)
          .modelContainer(container)
      }.padding()
    }
  }
}
