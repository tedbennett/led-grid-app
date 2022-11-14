//
//  Accordion.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//

import SwiftUI


struct Accordion: View {
    var item: AccordionItem
    
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(item.items, id: \.self) { text in
                    HStack(alignment: .top, spacing: 0) {
                        Text("・")
                        Text(text)
                    }//.foregroundColor(.gray)
                }
            }.padding(.vertical, 10)
                .padding(.bottom, 10)
        } label: {
            HStack {
                Image(systemName: item.image)
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.system(.title3, design: .rounded).weight(.medium))
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 10)
        }.buttonStyle(.plain)
            .padding(.horizontal, 12)
    }
}


struct AccordionItem {
    var title: String
    var subtitle: String?
    var image: String
    var items: [String]
}

struct Accordion_Previews: PreviewProvider {
    static var previews: some View {
        Accordion(item: AccordionItem(title: "See More", subtitle: nil, image: "circle", items: ["Step 1", "Step 2"]))
    }
}
