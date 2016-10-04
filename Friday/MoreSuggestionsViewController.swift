//
//  MoreSuggestionsViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 13/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class MoreSuggestionsViewController: UITableViewController {

    @IBOutlet weak var labelGroup1: UILabel!
    @IBOutlet weak var labelGroup2: UILabel!
    @IBOutlet weak var labelGroup3: UILabel!
    
    var countUsersInGroup: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelGroup1.hidden = (countUsersInGroup != 1)
        labelGroup2.hidden = (countUsersInGroup != 2)
        labelGroup3.hidden = (countUsersInGroup != 3)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
