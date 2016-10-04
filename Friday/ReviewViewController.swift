//
//  ReviewViewController.swift
//  Story
//
//  Created by Christopher Rydahl on 24/04/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class ReviewViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, StarReviewViewDelegate {
    
    
    @IBOutlet weak var starRateReview: StarRateView!
    
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textViewReview: UITextView!
    
    @IBOutlet weak var buttonSend: UIBarButtonItem!
    let screenSize = UIScreen.mainScreen().bounds.size;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        enableButtonSend()
        textViewDidEndEditing(self.textViewReview)
        starRateReview.delegate = self
    }
    
    //Prevent automatic scrolling
    override func viewWillAppear(animated: Bool) {}
    
    
    //MARK - Table View Delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch(indexPath.row){
        case 0:
            return 60;
        case 1:
            return 50;
        case 2:
            return screenSize.height - 110;
        default:
            return 10;
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        textFieldTitle.resignFirstResponder()
        textViewReview.resignFirstResponder()
    }
    
    func enableButtonSend(){
        if starRateReview.markReview != nil && textFieldTitle.text != ""{
            self.buttonSend.enabled = true
        }else{
            self.buttonSend.enabled = false
        }
    }
    
    //MARK - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        
        if (textView.text == "Review (optional)".localized) {
            textView.text = "";
            textView.textColor = UIColor.blackColor();
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Review (optional)".localized;
            textView.textColor = UIColor.lightGrayColor();
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ThankReviewVC"{
            if let dest = segue.destinationViewController as? ThankReviewViewController{
                dest.markReview = self.starRateReview.markReview
            }
        }
    }
    
    @IBAction func buttonSend(sender: AnyObject) {
        //if (markReview != nil && textFieldTitle.text != ""){
        if (starRateReview.markReview != nil && textFieldTitle.text != ""){
            let review = AWSReview()
            
            review.idSender = AWSManager.sharedInstance.getIdFacebook()
            
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd HH:mm"
            review.createdAt = dateFormat.stringFromDate(NSDate())
            
            review.mark = starRateReview.markReview!
            review.title = self.textFieldTitle.text!
            review.review = self.textViewReview.text
            self.tableView.makeToastActivity()
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            dynamoDBObjectMapper.save(review).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                print("task.exc \(task.exception)")
                print("error \(task.error)")
                print("task.result \(task.result)")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.hideToastActivity()
                    self.performSegueWithIdentifier("ThankReviewVC", sender: self)
                }
                return nil
            })
            
        }
    }
    
    //Mark - StarReviewViewDelegate
    func didButtonStar(starRateReview: StarRateView) {
        enableButtonSend()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editTextField(sender: AnyObject) {
        enableButtonSend()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textViewReview.becomeFirstResponder()
        return true
    }

    
}

