//
//  UpgradeView.swift
//  LedGrid
//
//  Created by Ted on 27/08/2022.
//

import SwiftUI
import AlertToast


struct UpgradeView: View {
    @Binding var isOpened: Bool
    @ObservedObject var manager = StoreManager.shared
    
    var purchaseButton: some View {
        Group {
            if let product = manager.products.first(where: { $0.productIdentifier == StoreProduct.pixeePlus.rawValue }) {
                if manager.transactionState == .purchasing {
                    Button {
                    } label: {
                        Spinner()
                    }.buttonStyle(LargeButton())
                        .allowsHitTesting(false)
                        .padding(.horizontal)
                } else if manager.transactionState == .purchased || manager.transactionState == .restored || Utility.isPlus {
                    Button {
                    } label: {
                        Text("You're Upgraded!")
                    }.buttonStyle(LargeButton())
                        .allowsHitTesting(false)
                        .padding(.horizontal)
                } else {
                    Button {
                        manager.purchaseProduct(product: product)
                    } label: {
                        Text("Upgrade to Plus")
                    }.buttonStyle(LargeButton(isLoading: manager.transactionState == .purchasing))
                        .padding(.horizontal)
                }
            } else {
                Button {
                    
                } label: {
                    Text("Cannot Upgrade")
                }.buttonStyle(LargeButton())
                    .padding(.horizontal)
                    .disabled(true)
            }
        }
    }
    
    var priceField: some View {
        Group {
            if let product = manager.products.first(where: { $0.productIdentifier == StoreProduct.pixeePlus.rawValue }) {
                Text("Available for \(product.priceLocale.currencySymbol ?? "$")\(product.price)").font(.callout).foregroundColor(.gray)
            } else {
                Text("Failed to reach App Store").font(.callout).foregroundColor(.gray)
            }
        }
    }
    
    var featuresView: some View {
        VStack(spacing: 15) {
            IconListItemView(image: "square.grid.3x3.fill", title: "Multiple Sizes", subtitle: "Create more detailed art with 12x12 and 16x16 grids")
            IconListItemView(image: "square.stack.3d.up.fill", title: "Frames", subtitle: "Send movies of multiple grids, just like a gif")
            IconListItemView(image: "plus.circle", title: "And More...", subtitle: "Improved widgets and better sharing are on the way")
            // TODO: 1.2
//            IconListItemView(image: "plus.square.dashed", title: "Custom Widgets", subtitle: "Personalise your home screen with any art you'd like")
        }
    }
    
    var restoreView: some View {
        VStack(spacing: 5) {
            Text("Already purchased?")
                .font(.callout)
                .foregroundColor(.gray)
            Button {
                manager.restoreProducts()
            } label: {
                Text("Restore Purchases")
            }.disabled(manager.transactionState == .purchasing)
        }.padding(.vertical, 5)
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                CloseButton {
                    withAnimation {
                        isOpened = false
                    }
                }
            }
            Text("Pixee Plus")
                .font(.system(size: 40, design: .rounded).weight(.bold))
            Spacer()
            Text("Features include:")
                .fontWeight(.medium)
                .padding(0)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            featuresView
            Spacer()
            priceField
            purchaseButton
            restoreView
        }
        .toast(isPresenting: $manager.didSucceed) {
            AlertToast(type: .complete(.gray), title: "Upgraded to Pixee Plus! Enjoy!")
        }
        .toast(isPresenting: $manager.didFail) {
            AlertToast(type: .error(.gray), title: "Failed to upgrade", subTitle: "You have not been charged.")
        }
        .onChange(of: manager.transactionState) { state in
            if state == .restored || state == .purchased {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                    isOpened = false
                    }
                }
            }
        }
    }
}



struct PixeePlusView_Previews: PreviewProvider {
    static var previews: some View {
        UpgradeView(isOpened: .constant(false))
            .previewDevice("iPhone 13 mini")
    }
}
