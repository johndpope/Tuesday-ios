//
//  ExplicationViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 01/07/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class ExplicationViewController: UIViewController {
    
    var delegate: ExplicationViewControllerDelegate?
    
    var explicationTableViewController: ExplicationTableViewController?
    var index = 0;
    var didLikeOtherGroup: Bool = true;
    
    @IBOutlet weak var okView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapGestureRecognizer:")
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.explicationTableViewController = storyboard.instantiateViewControllerWithIdentifier("ExplicationTableViewController") as? ExplicationTableViewController
        explicationTableViewController!.view.frame = UIScreen.mainScreen().bounds
        explicationTableViewController!.didLikeOtherGroup = didLikeOtherGroup
        self.view.addSubview(explicationTableViewController!.view)
        self.view.addSubview(okView)
        explicationTableViewController!.didMoveToParentViewController(self)
    }
    
    func tapGestureRecognizer(recognizer: UITapGestureRecognizer){
        index++;
        
        if (index >= explicationTableViewController!.tableView.numberOfSections){
            delegate?.explicationViewControllerdidFinish()
            return
        }
        
        self.explicationTableViewController?.scrollToSection(index)
        
    }
    
}

protocol ExplicationViewControllerDelegate{
    func explicationViewControllerdidFinish()
}
