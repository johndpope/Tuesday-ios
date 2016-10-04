
//
//  ExplicationTableViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 01/07/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class ExplicationTableViewController: UITableViewController {

    let screenHeight = UIScreen.mainScreen().bounds.size.height
    var didLikeOtherGroup: Bool = true;
    @IBOutlet weak var justToldLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(didLikeOtherGroup){
            self.justToldLabel.text = "You have just told us you liked this user".localized
        }else{
            self.justToldLabel.text = "You have just told us you didn't like this user".localized
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row){
        case (0,0):
            return screenHeight/2;
            
        case (0,1):
            return screenHeight/2;
            
        case (1,0):
            return screenHeight/5;
            
        case (1,1):
            return screenHeight*4/5;
            
        default:
            return 0;
        }
    }
    
    func scrollToSection(section: Int){
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.tableView.numberOfRowsInSection(section)-1, inSection: section), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
}
