//
//  WhenViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 13/10/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class WhenViewController: UITableViewController {
    
    var dateInCityPlaces: [AWSDateInCityPlace] = []
    var delegate: WhenViewControllerProtocol?
    var placeID:String?
    var namePlaceID: String?
    var user: AWSUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            self.user = user
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        queryAllDateInCityPlace()
    }
    
    func queryAllDateInCityPlace(){
        print("queryAllDateInCityPlace")
        if let placeID = placeID{
            let queryExpression = AWSDynamoDBQueryExpression()
            
            queryExpression.hashKeyAttribute = "placeID"
            queryExpression.hashKeyValues = placeID
            
            queryExpression.rangeKeyConditionExpression = "dateString > :dateString"
            var dateStringMin = NSDate()
            let daysToAdd = 2.0
            dateStringMin = dateStringMin.dateByAddingTimeInterval(60*60*24*daysToAdd)
            queryExpression.expressionAttributeValues = [":dateString":dateStringMin.toYYYYMMdd()]
            
            //dans l'ordre décroissant de dateString
            queryExpression.scanIndexForward = false
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            dynamoDBObjectMapper.query(AWSDateInCityPlace.self, expression: queryExpression).continueWithBlock { (task:AWSTask) -> AnyObject? in
                print("task.result \(task.result)")
                print("exception \(task.exception)")
                print("error \(task.error)")
                if let dateInCityPlaces = task.result?.items as? [AWSDateInCityPlace]{
                    print("dateInCityPlaces \(dateInCityPlaces)")
                    self.dateInCityPlaces = dateInCityPlaces.sort({ (a:AWSDateInCityPlace, b:AWSDateInCityPlace) -> Bool in
                        if let aDate = a.dateString, bDate = b.dateString{
                            return aDate < bDate
                        }
                        return true
                    })
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
                
                return nil
            }
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            var cell:TitleSubtitleCell! = tableView.dequeueReusableCellWithIdentifier("TitleSubtitleCell", forIndexPath: indexPath) as! TitleSubtitleCell
            if cell == nil {
                tableView.registerNib(UINib(nibName: "TitleSubtitleCell", bundle: nil), forCellReuseIdentifier: "TitleSubtitleCell")
                cell = tableView.dequeueReusableCellWithIdentifier("TitleSubtitleCell") as? TitleSubtitleCell
            }
            self.configureTitleSubtitleCell(cell, withDateInCityPlaces: dateInCityPlaces[indexPath.row])
            return cell
        
    }
    
    func configureTitleSubtitleCell(cell: TitleSubtitleCell, withDateInCityPlaces dateInCityPlace: AWSDateInCityPlace) {
        if let date = dateInCityPlace.dateString?.getDateYYYYMMdd(), nbGroupLimit = dateInCityPlace.nbGroupLimit, nbBoyGroup = dateInCityPlace.nbBoyGroup, nbGirlGroup = dateInCityPlace.nbGirlGroup, isBoy = self.user?.isBoy{
            cell.titleLabel.text = DateManager.getTitle(date, isTime: false)
            cell.subtitleLabel.text = DateManager.getSubtitle(date)
            
            if (nbGroupLimit.integerValue > (isBoy.boolValue ? nbBoyGroup.integerValue : nbGirlGroup.integerValue)){
                cell.contentView.alpha = 1.0;
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            else{
                cell.contentView.alpha = 0.3;
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
    
    func areAllDateFull() -> Bool{
        for dateInCityPlace in dateInCityPlaces{
            if let nbGroupLimit = dateInCityPlace.nbGroupLimit, nbBoyGroup = dateInCityPlace.nbBoyGroup, nbGirlGroup = dateInCityPlace.nbGirlGroup, isBoy = self.user?.isBoy{
                
                if (nbGroupLimit.integerValue > (isBoy.boolValue ? nbBoyGroup.integerValue : nbGirlGroup.integerValue)){
                    return false
                }
                
            }
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (section == 0){
            if (areAllDateFull()){
                if let namePlaceID = namePlaceID{
                    return "There are no date available for hanging out in %@. Come back later. If you want to know the future dates, please like our facebook page.".localizedStringWithVariables(namePlaceID)
                }
                else{
                    return "There are no date available for hanging out in %@. Come back later. If you want to know the future dates, please like our facebook page.".localizedStringWithVariables("your city".localized)
                }
            }
            return nil
        }
        else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dateInCityPlaces.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        let dateInCityPlace = dateInCityPlaces[indexPath.row]
        if let date = dateInCityPlace.dateString?.getDateYYYYMMdd(), nbGroupLimit = dateInCityPlace.nbGroupLimit, nbBoyGroup = dateInCityPlace.nbBoyGroup, nbGirlGroup = dateInCityPlace.nbGirlGroup, isBoy = self.user?.isBoy{
            
            if (nbGroupLimit.integerValue > (isBoy.boolValue ? nbBoyGroup.integerValue : nbGirlGroup.integerValue)){
                delegate?.didSelectDate(date)
                self.backButton(self)
            }
            else{
                self.tableView.makeToast("This date is already full. Try another date.".localized, duration: 2.0, position: "center");
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

protocol WhenViewControllerProtocol{
    func didSelectDate(date: NSDate?)
}

