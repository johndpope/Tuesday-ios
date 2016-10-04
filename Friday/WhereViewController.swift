//
//  WhereViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 10/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import Foundation

class WhereViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredTableData : NSMutableDictionary = NSMutableDictionary()
    var letters : NSMutableArray = []
    
    var delegate: WhereViewControllerProtocol?
    
    var cityPlaces: [AWSCityPlace] = []
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    
    let NEXT_CITY: String = "Next city"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func queryAllCityPlace(){
        print("queryAllCityPlace")
        let scanExpression = AWSDynamoDBScanExpression()
        dynamoDBObjectMapper.scan(AWSCityPlace.self, expression: scanExpression).continueWithBlock { (task:AWSTask) -> AnyObject? in
            print("task.result \(task.result)")
            print("exception \(task.exception)")
            print("error \(task.error)")
            if let cityPlaces = task.result?.items as? [AWSCityPlace]{
                print("cityPlaces \(cityPlaces)")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.cityPlaces = cityPlaces
                    self.updateTable("")
                }
            }
            
            return nil
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        updateTable(searchText)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        queryAllCityPlace()
    }
    
    func updateTable(searchText: String){
        filteredTableData = NSMutableDictionary()
        
        for cityPlace in self.cityPlaces {
            
            if let name = cityPlace.name {
                
                if (isMatchSearchText(searchText, name: name)){
                    // Find the first letter of the food's name. This will be its gropu
                    let firstLetter = name.substringToIndex(name.startIndex.advancedBy(1));
                    print("firstLetter \(firstLetter)")
                    
                    // Check to see if we already have an array for this group
                    if let arrayForLetter : NSMutableArray = self.filteredTableData.objectForKey(firstLetter) as? NSMutableArray{
                        arrayForLetter.addObject(cityPlace)
                    }else{
                        let arrayForLetter = NSMutableArray()
                        arrayForLetter.addObject(cityPlace)
                        self.filteredTableData.setObject(arrayForLetter, forKey: firstLetter)
                    }
                }
            }
        }
        
        //On trie les lettres dans l'ordre alphabétique
        if let allKeys:[NSString] = self.filteredTableData.allKeys as? [NSString]{
            letters = NSMutableArray(array: allKeys.sort{ $0.localizedCaseInsensitiveCompare($1 as String) == NSComparisonResult.OrderedAscending })
        }
        
        
        //On trie les personnes dans chaque section dans l'ordre alphabétique
        let count = letters.count
        for i in 0 ..< count {
            let letter = letters[i]
            if let array = self.filteredTableData.objectForKey(letter) as? NSMutableArray{
                array.sortUsingComparator({ (a:AnyObject, b: AnyObject) -> NSComparisonResult in
                    if let a = a as? AWSCityPlace, let b = b as? AWSCityPlace{
                        if let nameA = a.name, nameB = b.name{
                            return nameA.compare(nameB)
                        }
                    }
                    
                    return NSComparisonResult.OrderedSame
                })
            }
        }
        
        self.tableView.reloadData()
    }
    
    func isMatchSearchText(searchString: String,name: NSString) -> Bool{
        var isMatch = false;
        if(searchString.characters.count == 0)
        {
            // If our search string is empty, everything is a match
            isMatch = true;
        }
        else
        {
            // If we have a search string, check to see if it matches the food's name or description
            let nameRange = name.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if(nameRange.location != NSNotFound){
                isMatch = true;
            }
        }
        
        // If we have a match...
        return isMatch
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return letters.count + 1
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section < letters.count){
            if(letters.count > 0){
                let str = letters[section] as! String
                return String(str)
            }
        }
        return nil
        
    }
    
    //Pour ajouter une index list
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let count = letters.count
        if(count > 0){
            var indexes :[String] = []
            
            for i in 0 ..< count {
                let letter = letters[i] as! String
                if (letter != NEXT_CITY){
                    indexes.append(letter)
                }
            }
            return indexes
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section < letters.count){
            // Return the number of rows in the section.
            if let letter : NSString = self.letters[section] as? NSString{
                if let f :NSMutableArray = filteredTableData[letter] as? NSMutableArray{
                    return f.count
                }
            }
            return 0
        }
        else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section < letters.count){
            return 60
        }
        return 118
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section < letters.count){
            if let letter : NSString = self.letters[indexPath.section] as? NSString{
                if let f :NSMutableArray = filteredTableData[letter] as? NSMutableArray{
                    if let cityPlace: AWSCityPlace = f[indexPath.row] as? AWSCityPlace{
                        var cell:TitleSubtitleCell! = tableView.dequeueReusableCellWithIdentifier("TitleSubtitleCell", forIndexPath: indexPath) as! TitleSubtitleCell
                        if cell == nil {
                            tableView.registerNib(UINib(nibName: "TitleSubtitleCell", bundle: nil), forCellReuseIdentifier: "TitleSubtitleCell")
                            cell = tableView.dequeueReusableCellWithIdentifier("TitleSubtitleCell") as? TitleSubtitleCell
                        }
                        self.configureTitleSubtitleCell(cell, forCityPlace: cityPlace)
                        return cell
                    }
                }
            }
        }
        
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("NextCityCell", forIndexPath: indexPath)
        if cell == nil {
            tableView.registerNib(UINib(nibName: "NextCityCell", bundle: nil), forCellReuseIdentifier: "NextCityCell")
            cell = tableView.dequeueReusableCellWithIdentifier("NextCityCell")
        }
        return cell
    }
    
    func configureTitleSubtitleCell(cell: TitleSubtitleCell, forCityPlace cityPlace: AWSCityPlace) {
        cell.titleLabel.text = cityPlace.name
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchBar.resignFirstResponder()
        
        if (indexPath.section < letters.count){
            if let letter : NSString = self.letters[indexPath.section] as? NSString{
                if let f :NSMutableArray = filteredTableData[letter] as? NSMutableArray{
                    if let cityPlace: AWSCityPlace = f[indexPath.row] as? AWSCityPlace{
                        
                        self.delegate?.didSelectPlace(cityPlace)
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    }
                }
            }
        }
            
        else{
            self.performSegueWithIdentifier("WhereGoogleVC", sender: self)
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


protocol WhereViewControllerProtocol{
    func didSelectPlace(cityPlace: AWSCityPlace?)
}