//
//  IAPHelper.swift
//  AirGuitar
//
//  Created by Lucas Luz on 01/12/15.
//  Copyright © 2015 Lucas Luz. All rights reserved.
//

import StoreKit

/// Notification that is generated when a product is purchased.
public let IAPHelperProductPurchasedNotification = "IAPHelperProductPurchasedNotification"

/// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

/// Completion handler called when products are fetched.
public typealias RequestProductsCompletionHandler = (_ success: Bool, _ products: [SKProduct]) -> ()


/// A Helper class for In-App-Purchases, it can fetch products, tell you if a product has been purchased,
/// purchase products, and restore purchases.  Uses NSUserDefaults to cache if a product has been purchased.
open class IAPHelper : NSObject  {
    
    // Used to keep track of the possible products and which ones have been purchased.
    fileprivate var productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    
    // Used by SKProductsRequestDelegate
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var completionHandler: RequestProductsCompletionHandler?
    
    /// MARK: - User facing API
  
    /// Initialize the helper.  Pass in the set of ProductIdentifiers supported by the app.
    public init(productIdentifiers: Set<ProductIdentifier>) {
        self.productIdentifiers = productIdentifiers
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    /// Gets the list of SKProducts from the Apple server calls the handler with the list of products.
    open func requestProductsWithCompletionHandler(_ handler: @escaping RequestProductsCompletionHandler) {
        completionHandler = handler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    /// Initiates purchase of a product.
    open func purchaseProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    /// Given the product identifier, returns true if that product has been purchased.
    open func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    /// If the state of whether purchases have been made is lost  (e.g. the
    /// user deletes and reinstalls the app) this will recover the purchases.
    open func restoreCompletedTransactions() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    open class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        completionHandler?(true, products)
        clearRequest()
        
        // debug printing
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error)")
        completionHandler?(false, [])
        clearRequest()
        
    }
    
    fileprivate func clearRequest() {
        productsRequest = nil
        completionHandler = nil
    }
    
}


extension IAPHelper: SKPaymentTransactionObserver {
    /// This is a function called by the payment queue, not to be called directly.
    /// For each transaction act accordingly, save in the purchased cache, issue notifications,
    /// mark the transaction as complete.
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                completeTransaction(transaction)
                break
            case .failed:
                failedTransaction(transaction)
                break
            case .restored:
                restoreTransaction(transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if(queue.transactions.count == 0) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "cancelPurchase"), object: nil, userInfo: ["message":"You did not buy this feature yet."])
        }
    }
    
    fileprivate func completeTransaction(_ transaction: SKPaymentTransaction) {
        print("completeTransaction...")
        provideContentForProductIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    fileprivate func restoreTransaction(_ transaction: SKPaymentTransaction) {
        let productIdentifier = transaction.original!.payment.productIdentifier
        print("restoreTransaction... \(productIdentifier)")
        provideContentForProductIdentifier(productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // Helper: Saves the fact that the product has been purchased and posts a notification.
    fileprivate func provideContentForProductIdentifier(_ productIdentifier: String) {
        purchasedProductIdentifiers.insert(productIdentifier)
        UserDefaults.standard.set(true, forKey: productIdentifier)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: IAPHelperProductPurchasedNotification), object: nil, userInfo: ["product":productIdentifier])
    }
    
    fileprivate func failedTransaction(_ transaction: SKPaymentTransaction) {
        print("failedTransaction...")
        //if transaction.error!.code != SKErrorPaymentCancelled {
            print("Transaction error: \(transaction.error!.localizedDescription)")
        //}
        NotificationCenter.default.post(name: Notification.Name(rawValue: "cancelPurchase"), object: nil, userInfo: ["message":""])
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }

}
