//
//  WhereGoogleViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 21/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit
import GoogleMaps


class WhereGoogleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var placesClient: GMSPlacesClient?
    
    var results: [AnyObject] = []
    
    override func viewDidLoad() {
        placesClient = GMSPlacesClient()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchBar.becomeFirstResponder()
        self.searchBar.text = "P"
        self.searchBar(self.searchBar, textDidChange: "P")
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText != ""){
            googlePlaceAutocomplete(searchText)
        }
    }
    
    func googlePlaceAutocomplete(searchText: String) {
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.City
        placesClient!.autocompleteQuery(searchText, bounds: nil, filter: filter, callback: { (results, error: NSError?) -> Void in
            if let error = error {
                self.tableView.makeToast("An error occurred".localized, duration: 2.0, position: "center")
                print("error : \(error)")
            }
            if let results = results{
                self.results = results
                self.tableView.reloadData()
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:TitleSubtitleCell! = tableView.dequeueReusableCellWithIdentifier("TitleSubtitleCell", forIndexPath: indexPath) as! TitleSubtitleCell
        if cell == nil {
            tableView.registerNib(UINib(nibName: "TitleSubtitleCell", bundle: nil), forCellReuseIdentifier: "TitleSubtitleCell")
            cell = tableView.dequeueReusableCellWithIdentifier("TitleSubtitleCell") as? TitleSubtitleCell
        }
        self.configureTitleSubtitleCell(cell, forResult: self.results[indexPath.row])
        return cell
    }
    
    func configureTitleSubtitleCell(cell: TitleSubtitleCell, forResult result: AnyObject) {
        if let result = result as? GMSAutocompletePrediction {
            
            let regularFont = UIFont.systemFontOfSize(UIFont.labelFontSize())
            let boldFont = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
            
            let bolded = result.attributedFullText.mutableCopy() as! NSMutableAttributedString
            bolded.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, bolded.length), options: NSAttributedStringEnumerationOptions.Reverse) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let font = (value == nil) ? regularFont : boldFont
                bolded.addAttribute(NSFontAttributeName, value: font, range: range)
            }
            
            cell.titleLabel.attributedText = bolded
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.searchBar.resignFirstResponder()
        
        if indexPath.row < results.count {
            
            if let result = results[indexPath.row] as? GMSAutocompletePrediction {
                
                let cityPlaceVote = AWSCityPlaceVote()
                
                cityPlaceVote.placeID = result.placeID
                cityPlaceVote.idUser = AWSManager.sharedInstance.idFacebook
                cityPlaceVote.dateString = NSDate().toYYYYMMddhhmm()
                
                self.view.makeToastActivity()
                let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                dynamoDBObjectMapper?.saveUpdateSkipNullAttributes(cityPlaceVote).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.view.hideToastActivity()
                        let alertController = UIAlertController(title: "Thank you".localized, message: "We will try to launch Tuesday in %@ as soon as possible".localizedStringWithVariables(result.attributedFullText.string), preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let doAction = UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                            self.navigationController?.popViewControllerAnimated(true)
                        })
                        
                        alertController.addAction(doAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                    return nil
                    
                })
                
                
                
                
            }
        }
        
    }
    
    @IBAction func backButton(sender: AnyObject) {
        print("backButton")
        self.searchBar.resignFirstResponder()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}
