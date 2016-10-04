//
//  CommentEveningViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 25/09/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class CommentEveningViewController: UITableViewController {
    
    @IBOutlet weak var commentTextView: UITextView!
    var rateMeeting: AWSRateMeeting!
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ThankReviewVC3"{
            if let dest = segue.destinationViewController as? ThankReviewViewController{
                dest.markReview = Int(rateMeeting.markEvening!)
                
            }
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        self.tableView.makeToastActivity()
        
        rateMeeting.comment = commentTextView.text
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        dynamoDBObjectMapper.saveUpdateSkipNullAttributes(rateMeeting).continueWithBlock({ (task:AWSTask) -> AnyObject? in
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.hideToastActivity()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let thankReviewViewController = storyboard.instantiateViewControllerWithIdentifier("ThankReviewViewController") as! ThankReviewViewController
                thankReviewViewController.markReview = Int(self.rateMeeting.markEvening!)
                self.navigationController?.pushViewController(thankReviewViewController, animated: true)
            }
            return nil
        })
        
    }
    
    /* scrollView Delegate
    ------------------------------------------*/
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.commentTextView.resignFirstResponder()
    }
}
