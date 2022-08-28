//
//  StoreManager.swift
//  LedGrid
//
//  Created by Ted on 20/08/2022.
//


import Foundation
import StoreKit

enum StoreProduct: String, CaseIterable {
    case pixeePlus = "com.edwardbennett.LedGrid.IAP.PixeePlus"
    
    static var identifiers: [String] {
        StoreProduct.allCases.map { $0.rawValue }
    }
}

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // MARK: - Lifecycle
    
    static var shared = StoreManager()
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - Products
    
    var request: SKProductsRequest!
    
    @Published var products = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?
    
    @Published var didSucceed = false
    @Published var didFail = false
    
    func getProducts() {
        let productIdentifiers = Set(["com.edwardbennett.LedGrid.IAP.PixeePlus"])
        
        request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products.append(contentsOf: response.products)
        }
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
    
    // MARK: - Transactions
    
    func purchaseProduct(product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                if transaction.payment.productIdentifier == StoreProduct.pixeePlus.rawValue {
                    Utility.isPlus = true
                    didSucceed = true
                }
                queue.finishTransaction(transaction)
                transactionState = .purchased
            case .restored:
                if transaction.payment.productIdentifier == StoreProduct.pixeePlus.rawValue {
                    Utility.isPlus = true
                    didSucceed = true
                }
                queue.finishTransaction(transaction)
                transactionState = .restored
            case .failed, .deferred:
                print("Payment Queue Error: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                transactionState = .failed
                didFail = true
            default:
                queue.finishTransaction(transaction)
            }
        }
    }

    
    func restoreProducts() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        transactionState = .purchasing
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Utility.isPlus = true
        didSucceed = true
        transactionState = .restored
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        transactionState = .failed
        didFail = true
    }
}
