//
//  RateEveningViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 25/09/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class RateEveningViewController: UITableViewController, StarReviewViewDelegate {
    
    @IBOutlet weak var eveningStarRateView: StarRateView!
    @IBOutlet weak var otherGroupStarRateView: StarRateView!
    @IBOutlet weak var barStarRateView: StarRateView!
    
    @IBOutlet weak var eveningRateLabel: UILabel!
    @IBOutlet weak var otherGroupRateLabel: UILabel!
    @IBOutlet weak var barRateLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var rateMeeting: AWSRateMeeting! = AWSRateMeeting();
    
    var previousGroup: AWSGroup?
    
    var labels :[UILabel] = []
    var starRateViews :[StarRateView] = []
    
    
    var textLabels : [[String]] = [
        [
            "I would like to complain about this evening".localized,
            "Definitely not the best evening of my life".localized,
            "Nice evening!".localized,
            "A lot of fun!".localized,
            "Awesome: I love this app!".localized
        ],
        [
            "I would like to complain about this group".localized,
            "I don't want to see them again!".localized,
            "A nice group".localized,
            "They were very friendly, we will probably meet them again".localized,
            "We will definetely hang out again".localized
        ],
        [
            "I would like to complain about this bar".localized,
            "Definitely not the best place ever".localized,
            "A nice place".localized,
            "I love this spot!".localized,
            "Awesome place, amazing staff, I will come back!".localized
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labels = [eveningRateLabel, otherGroupRateLabel, barRateLabel]
        starRateViews = [eveningStarRateView, otherGroupStarRateView, barStarRateView]
        eveningStarRateView.delegate = self
        otherGroupStarRateView.delegate = self
        barStarRateView.delegate = self
        enableDoneButton()
    }
    
    //Mark - StarReviewViewDelegate
    func didButtonStar(starRateReview: StarRateView) {
        let tag = starRateReview.tag;
        labels[tag].text = textLabels[tag][starRateReview.markReview! - 1]
        enableDoneButton()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        
        if let markReview0 = starRateViews[0].markReview, markReview1 = starRateViews[1].markReview, markReview2 = starRateViews[2].markReview{
            
            self.tableView.makeToastActivity()
            
            rateMeeting.markEvening = NSNumber(integer: markReview0)
            rateMeeting.markOtherGroup = NSNumber(integer: markReview1)
            rateMeeting.markBar = NSNumber(integer: markReview2)
            rateMeeting.idUser = AWSManager.sharedInstance.idFacebook
            rateMeeting.dateString = NSDate().toYYYYMMdd()
            rateMeeting.groupPartitionKey = previousGroup?.dashboardKey
            rateMeeting.groupSortKey = previousGroup?.sortKey
            
            if (markReview0 == 1 || markReview1 == 1 || markReview2 == 1){
                self.performSegueWithIdentifier("CommentEveningVC", sender: self)
            }else{
                
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
            
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CommentEveningVC"{
            if let dest = segue.destinationViewController as? CommentEveningViewController{
                dest.rateMeeting = rateMeeting
            }
        }
    }
    
    
    func enableDoneButton(){
        var isEnabled = true;
        let count = starRateViews.count;
        for i in 0 ..< count {
            if starRateViews[i].markReview == nil{
                isEnabled = false
                break;
            }
        }
        
        doneButton.tintColor = isEnabled ? UIColor.purpleColor() : UIColor.clearColor()
        doneButton.enabled = isEnabled
    }
}
