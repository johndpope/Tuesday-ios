//
//  MessageViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 24/12/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    var isKeyboardVisible:Bool = false
    var heightKeyboard: CGFloat = 0.0
    var delegate: MessageViewControllerDelegate?
    
    var newHeightContainerViewBefore: CGFloat = -1.0
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        return true
    }
    
    func keyboardWillShow(notification: NSNotification){
        print("keyboardWillShow")
        isKeyboardVisible = true
        if let userInfo = notification.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                heightKeyboard = keyboardHeight
                textViewBottomConstraint.constant = keyboardHeight
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
                delegate?.keyboardDidShow(keyboardHeight)
            }
        }
        
        textViewDidChange(self.textView);
    }
    
    func keyboardWillHide(notification: NSNotification){
        print("keyboardWillHide")
        isKeyboardVisible = false
        textViewBottomConstraint.constant = 0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        textViewDidChange(self.textView);
    }
    
    //Mark - UITextViewDelegate
    func textViewDidChange(textView: UITextView) {
        print("textViewDidChange")
        updateSendButton();
        
        var newHeightContainerView: CGFloat = min (textView.contentSize.height + 17.0, 100)
        print("newHeightContainerView \(newHeightContainerView)")
        
        if (isKeyboardVisible){
            newHeightContainerView = newHeightContainerView + heightKeyboard
        }
        
        newHeightContainerView = newHeightContainerView - 1
        
        print("newHeightContainerView \(newHeightContainerView)")
        
        if (newHeightContainerView == newHeightContainerViewBefore){
            return;
        }
        
        delegate?.textViewDidChange(newHeightContainerView)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
    func updateSendButton(){
        print("textView.text \(textView.text)")
        if (textView.text == ""){
            self.sendButton.enabled = false
            self.sendButton.titleLabel?.textColor = UIColor.lightGrayColor()
        }else{
            self.sendButton.enabled = true
            self.sendButton.titleLabel?.textColor = UIColor(red: 0/255.0, green: 102/255.0, blue: 204/255.0, alpha: 1.0)
        }
    }
    
    
    @IBAction func sendButton(sender: AnyObject) {
        if (self.textView.text == ""){
            return
        }
        self.delegate?.sendButton()
        self.textView.text = ""
        self.textViewDidChange(self.textView)
    }
}

protocol MessageViewControllerDelegate{
    func textViewDidChange(newHeight: CGFloat)
    func sendButton()
    func keyboardDidShow(keyboardHeight: CGFloat)
}
