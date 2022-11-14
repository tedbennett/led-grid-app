//
//  UpdateView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//

import SwiftUI

struct UpdateView: View {
    var dismiss: () -> Void
    
    var items: [AccordionItem] = [
        AccordionItem(
            title: "Reactions",
            subtitle: "Respond with any emoji",
            image: "hand.thumbsup.circle",
            items: [
                "React directly to your friends' art",
                "Press the thumbs up icon on art that you've received to pick a reaction",
                "Press the \"+\" button to select any emoji you like!"
            ]
        ),
        AccordionItem(
            title: "New Editing Features",
            subtitle: "Creating art is even easier",
            image: "paintbrush.pointed",
            items: [
                "Drag from the colour picker square to fill with that colour!",
                "Different colour picker options for finer colour control",
                "Grid outlines can now be turned off"
            ]
        ),
        AccordionItem(
            title: "Better Settings",
            subtitle: "Tune the app just how you like it",
            image: "gear",
            items: [
                "Ability to turn off haptics",
                "Press the thumbs up icon on art you've received to choose a reaction emoji",
                "Press the \"+\" button to select any emoji you like!"
            ]
        ),
        AccordionItem(
            title: "General Improvements",
            subtitle: "Making the app easier to use",
            image: "hammer.circle",
            items: [
                "Brand new ",
                "Art is now grouped by friends",
                "Art with frames automatically plays as you scroll",
                "Press the \"+\" button to select any emoji you like!"
            ]
        ),
    ]
    
    
    var body: some View {
        
        NavigationView {
            VStack {
                HStack {
                    PixeeLogoView(size: 32)
                    Text("Pixee 1.1")
                        .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                }.padding(.bottom, 30)
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("What's New?")
                            .font(.system(.title2, design: .rounded).weight(.medium))
                            .multilineTextAlignment(.center)
                        Text("Tap on any item to learn more")
                            .foregroundColor(.gray)
                            .font(.callout)
                            .padding(.bottom)
                        ForEach(items, id: \.title) { item in
                            Accordion(item: item)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(10)
                            //                        Divider()
                        }
                        
                    }.padding(.horizontal, 8)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }.buttonStyle(LargeButton())
                    .padding(.horizontal, 30)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }.tint(Color(uiColor: .label))
    }
}

struct UpdateView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
            .sheet(isPresented: .constant(true)) {
                UpdateView { }
            }
    }
}

