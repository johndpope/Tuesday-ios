//
//  StoreViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 23/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class StoreViewController: UITableViewController, StoreManagerDelegate {

    var productsArray: Array<SKProduct!> = []
    var firstPrice:Double?
    var firstNbCredits:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.makeToastActivity()
        StoreManager.sharedInstance.initialisation(self)
        
    }
    
    
    
    //StoreManagerDelegate
    func didGetProducts(productsArray: Array<SKProduct!>){
        self.tableView.hideToastActivity()
        self.productsArray = productsArray
        self.productsArray.sortInPlace { (a: SKProduct!, b: SKProduct!) -> Bool in
            return a.price.doubleValue < b.price.doubleValue
        }
        print("productsArray \(productsArray)")
        if productsArray.count > 0 {
            firstPrice = productsArray[0].price.doubleValue
            firstNbCredits = getNbCredits(productsArray[0].localizedTitle)
            self.tableView.reloadData()
        }
    }
    
    func didCompleteTransaction(){
        self.tableView.hideToastActivity()
        self.tableView.makeToast("Congratulation, the transaction worked successfully".localized, duration: 5.0, position: "center")
    }
    
    func didFailedTransaction(){
        self.tableView.hideToastActivity()
        self.tableView.makeToast("An error occured".localized, duration: 5.0, position: "center")
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count + 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row < productsArray.count){
            
            var cell:CreditCell! = tableView.dequeueReusableCellWithIdentifier("BuyCreditCell", forIndexPath: indexPath) as! CreditCell
            if cell == nil {
                tableView.registerNib(UINib(nibName: "BuyCreditCell", bundle: nil), forCellReuseIdentifier: "BuyCreditCell")
                cell = tableView.dequeueReusableCellWithIdentifier("BuyCreditCell") as? CreditCell
            }
            self.configureBuyCreditCell(cell, withProduct: productsArray[indexPath.row], atIndexPath: indexPath)
            return cell
        }
            
        else{
            var cell:CreditCell! = tableView.dequeueReusableCellWithIdentifier("FreeCreditCell", forIndexPath: indexPath) as! CreditCell
            if cell == nil {
                tableView.registerNib(UINib(nibName: "FreeCreditCell", bundle: nil), forCellReuseIdentifier: "FreeCreditCell")
                cell = tableView.dequeueReusableCellWithIdentifier("FreeCreditCell") as? CreditCell
            }
            self.configureFreeCreditCell(cell)
            return cell
        }
    }
    
    func configureBuyCreditCell(cell: CreditCell, withProduct product: SKProduct, atIndexPath indexPath: NSIndexPath){
        
        
        //Illustration
        switch(indexPath.row){
        case 0:
            cell.illustrationImage.image = UIImage(named: "Cheap")
            break;
            
        case 1:
            cell.illustrationImage.image = UIImage(named: "Average")
            break;
            
        default:
            cell.illustrationImage.image = UIImage(named: "Expensive")
            break;
        }
        
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberFormatter.locale = product.priceLocale
        let price = numberFormatter.stringFromNumber(product.price)
        cell.priceLabel.text = price
        
        cell.nbCreditsLabel.text = product.localizedTitle
        
        let nbCredits = getNbCredits(product.localizedTitle)
        var save: Double = 0;
        let priceShoudHavePaid: Double = firstPrice! / Double(firstNbCredits!) * Double(nbCredits)
        save = (priceShoudHavePaid - product.price.doubleValue) / priceShoudHavePaid
        if (save > 0) {
            cell.saveLabel.text = "SAVE %d".localizedStringWithVariables(Int(floor(save * 100))) + "%"
        }
        else{
            cell.saveLabel.text = ""
        }
        
        if (StoreManager.canMakePayments()){
            cell.payButton.setTitle("Buy".localized, forState: .Normal)
            cell.tag = indexPath.row
            cell.payButton.addTarget(self, action: #selector(StoreViewController.purchaseButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.payButton.tag = indexPath.row;
        }
        else{
            cell.payButton.setTitle("Not available".localized, forState: .Normal)
            cell.payButton.removeTarget(self, action: #selector(StoreViewController.purchaseButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func configureFreeCreditCell(cell: CreditCell){
        cell.payButton.addTarget(self, action: #selector(StoreViewController.freeButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    func purchaseButton(sender: AnyObject) {
        if let tag = sender.tag{
            if (tag < self.productsArray.count){
                self.tableView.makeToastActivity()
                StoreManager.sharedInstance.performPurchase(self.productsArray[tag])
            }
        }
    }
    
    func freeButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let dest = storyboard.instantiateViewControllerWithIdentifier("LikeUsOnFacebookViewController") as? LikeUsOnFacebookViewController{
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getNbCredits(localizedTitle: String) -> Int{
        let localizedTitleArray = localizedTitle.characters.split{$0 == " "}.map(String.init)
        return Int(localizedTitleArray[0])!
    }

}
