//
//  StoreManager.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 23/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class StoreManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    let validationReceiptURL = ""
    
    var productIDs: Array<String> = []
    var productsArray: Array<SKProduct!>?
    var transactionInProgress = false
    var delegate: StoreManagerDelegate?
    
    class var sharedInstance: StoreManager {
        struct Static {
            static var instance: StoreManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = StoreManager()
        }
        
        return Static.instance!
    }
    
    class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func initialisation(delegate:StoreManagerDelegate?){
        self.delegate = delegate
        
        if let productsArray = productsArray{
            delegate?.didGetProducts(productsArray)
        }
        else{
            productIDs = [];
            productIDs.append("tuesday_extra_credit_10")
            productIDs.append("tuesday_extra_credit_20")
            productIDs.append("tuesday_extra_credit_30")
            
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            
            requestProductInfo()
        }
        
    }
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs)
            print("productIdentifiers \(productIdentifiers)")
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    
    
    //MARK - SKProductsRequestDelegate
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        productsArray = [];
        
        if response.products.count != 0 {
            for product in response.products {
                productsArray!.append(product as SKProduct)
            }
        }
        else {
            print("There are no products.")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
        
        print("productsArray \(productsArray)")
        delegate?.didGetProducts(productsArray!)
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("request didFailWithError.")
    }
    
    func performPurchase(product: SKProduct){
        let payment = SKMutablePayment(product: product)
        if let applicationUsername = AWSManager.sharedInstance.idFacebook?.sha1(){
            payment.applicationUsername = applicationUsername
        }
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    
    //MARK - SKPaymentTransactionObserver
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                self.completeTransaction(transaction)
                break;
                
            case SKPaymentTransactionState.Failed:
                failedTransaction(transaction)
                break;
                
            case .Restored:
                restoreTransaction(transaction)
                break
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        print("Transaction Failed");
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        transactionInProgress = false
        delegate?.didFailedTransaction()
    }
    
    
    private func completeTransaction(transaction: SKPaymentTransaction) {
        print("Transaction completed successfully.")
        if let receiptURL = NSBundle.mainBundle().appStoreReceiptURL{
            if let receipt = NSData(contentsOfURL: receiptURL){
                
                if let idFacebook = AWSManager.sharedInstance.idFacebook {
                    
                    let receiptString = receipt.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
                    
                    let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
                    let jsonObject: [String:AnyObject] = [
                        "idUser" : idFacebook,
                        "receipt" : receiptString,
                        "isSandbox" : Params.IS_SANDBOX
                    ]
                    
                    lambdaInvoker.invokeFunction("AWSvalidateAppleReceipt", JSONObject: jsonObject).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                        
                        print("task.result \(task.result)")
                        print("exception \(task.exception)")
                        print("error \(task.error)")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            if let result = task.result as? NSDictionary {
                                if let isOk = result.objectForKey("isOk") as? Bool {
                                    if isOk {
                                        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                                        self.transactionInProgress = false
                                        self.delegate?.didCompleteTransaction()
                                    }
                                    else{
                                        if let errorMessage = result.objectForKey("message") as? String{
                                            print("errorMessage \(errorMessage)")
                                        }
                                    }
                                }
                            }
                            
                        }
                        return nil
                        
                    })
                    
                    
                    
                }
            }
            
        }
        
        
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        transactionInProgress = false
    }
    
    
}

protocol StoreManagerDelegate{
    func didGetProducts(productsArray: Array<SKProduct!>)
    func didCompleteTransaction()
    func didFailedTransaction()
}


extension String {
    func sha1() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
}