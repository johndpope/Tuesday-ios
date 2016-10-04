//
//  ContainerViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 25/12/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    var createGroupViewController : CreateGroupViewController?
    var editGroupViewController : EditGroupViewController?
    var meetingViewController : MeetingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        createGroupViewController = storyboard.instantiateViewControllerWithIdentifier("CreateGroupViewController") as? CreateGroupViewController
        createGroupViewController?.containerViewController = self
        
        editGroupViewController = storyboard.instantiateViewControllerWithIdentifier("EditGroupViewController") as? EditGroupViewController
        editGroupViewController?.containerViewController = self
        
        meetingViewController = storyboard.instantiateViewControllerWithIdentifier("MeetingViewController") as? MeetingViewController
        meetingViewController?.containerViewController = self
        
        updateCurrentViewController(nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func updateCurrentViewController(completionBlock : (() -> Void)?){
        print("super updateCurrentViewController")
    }
    
    
    func displayViewController(viewController: UIViewController?){
        
        if let viewController = viewController{
            
            if let tableViewController = viewController as? UITableViewController{
                self.view.addSubview(tableViewController.view)
            }
                
            else{
                self.view.addSubview(viewController.view)
            }
            self.addChildViewController(viewController)
            viewController.didMoveToParentViewController(self)
        }
        
    }
    
    
    
}
