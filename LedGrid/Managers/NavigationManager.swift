//
//  NavigationManager.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/10/2022.
//

import SwiftUI

class NavigationManager: ObservableObject {
    
    static var shared = NavigationManager()
    
    private init () { }
    
    @Published var selectedGrid: String?
    @Published var selectedFriend: String?
    @Published var currentTab: Int = 0 {
        willSet {
            if newValue == 1 && currentTab == 1 {
                setFriend(nil)
            }
        }
    }
    
    func navigateTo(friend: String, grid: String?) {
        DispatchQueue.main.async {
            self.currentTab = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.selectedFriend = friend
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.selectedGrid = grid
        }
    }
    
    func setFriend(_ friendId: String?) {
        DispatchQueue.main.async {
            self.selectedFriend = friendId
        }
    }
}

struct NavigationStackModifier<Item, Destination: View>: ViewModifier {
    let item: Binding<Item?>
    let destination: (Item) -> Destination

    func body(content: Content) -> some View {
        content.background(NavigationLink(isActive: item.mappedToBool()) {
            if let item = item.wrappedValue {
                destination(item)
            } else {
                EmptyView()
            }
        } label: {
            EmptyView()
        })
    }
}

public extension View {
    func navigationDestination<Item, Destination: View>(
        for binding: Binding<Item?>,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        self.modifier(NavigationStackModifier(item: binding, destination: destination))
    }
}

public extension Binding where Value == Bool {
    init<Wrapped>(bindingOptional: Binding<Wrapped?>) {
        self.init(
            get: {
                bindingOptional.wrappedValue != nil
            },
            set: { newValue in
                guard newValue == false else { return }

                /// We only handle `false` booleans to set our optional to `nil`
                /// as we can't handle `true` for restoring the previous value.
                bindingOptional.wrappedValue = nil
            }
        )
    }
}

extension Binding {
    public func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        return Binding<Bool>(bindingOptional: self)
    }
}
