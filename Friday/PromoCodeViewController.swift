//
//  PromoCodeViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 21/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class PromoCodeViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var promoCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        sendPromoCode()
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.promoCodeTextField.resignFirstResponder()
    }
    
    /* scrollView Delegate
    ------------------------------------------*/
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.promoCodeTextField.resignFirstResponder()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        if let promoCode = self.promoCodeTextField.text?.lowercaseString{
            if promoCode != "" {
                sendPromoCode()
            }
        }
    }
    
    func sendPromoCode(){
        if let promoCode = self.promoCodeTextField.text?.lowercaseString, idFacebook = AWSManager.sharedInstance.idFacebook {
            
            if promoCode != "" {
                self.view.makeToastActivity()
                //sendPromoCode
                let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
                let jsonObject = [
                    "idUser": idFacebook,
                    "promoCode": promoCode
                ]
                lambdaInvoker.invokeFunction("AWSsendPromoCode", JSONObject: jsonObject).continueWithBlock { (task:AWSTask) -> AnyObject? in
                    
                    print("lambdaInvoker result: \(task.result)");
                    print("lambdaInvoker exception: \(task.exception)");
                    print("lambdaInvoker error: \(task.error)");
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.view.hideToastActivity()
                        if let result = task.result as? NSDictionary {
                            if let isOk = result.objectForKey("isOk") as? Bool {
                                if isOk {
                                    
                                }
                                else{
                                    if let errorMessage = result.objectForKey("message") as? String{
                                        self.view.makeToast(errorMessage.localized, duration: 3.0, position: "center")
                                    }
                                }
                            }
                        }
                    }
                    return nil
                }
                
                return
            }
        }
    }
}



extension String {
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start: start, end: end)]
    }
}