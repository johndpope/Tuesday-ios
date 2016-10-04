//
//  PopUpViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/10/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//sdfds

import Foundation

class PopUpViewController: UIViewController {
    
    var delegate: PopUpControllerDelegate?
    @IBOutlet weak var popupView: UIView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        self.view.addSubview(popupView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
    @IBAction func laterButton(sender: AnyObject) {
        delegate?.popUpControllerDelegateViewControllerdidFinish(false)
    }
}


protocol PopUpControllerDelegate{
    func popUpControllerDelegateViewControllerdidFinish(willDoIt: Bool)
}