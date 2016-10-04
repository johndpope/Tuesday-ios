//
//  DiscoveryPreferencesViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class DiscoveryPreferencesViewController: UITableViewController {
    
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageSlider: NMRangeSlider!
    
    var user: AWSUser?
    var userProfile: AWSUserProfile?
    var dynamoDBObjectMapper: AWSDynamoDBObjectMapper?
    
    var constantAgeMax: Int = 55 ;
    private var b: Int = 18 ;
    private var a: Int = 55-18 ;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        self.ageSlider.minimumRange=3/Float(a);
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            print("getUser \(user)")
            print("getUser userProfile \(userProfile)")
            if let currentUser = user, currentUserProfile = userProfile {
                self.user = currentUser
                self.userProfile = currentUserProfile
                
                if let ageMin = self.userProfile?.ageMin, let ageMax = self.userProfile?.ageMax{
                    
                    print("ageMin \(ageMin)")
                    
                    self.updateAgeLabel(Int(ageMin), ageMax: Int(ageMax))
                    
                    self.ageSlider.upperValue = self.ageToSlide(ageMax)
                    self.ageSlider.lowerValue = self.ageToSlide(ageMin)
                }
                
            }
        }
        
    }
    
    
    
    @IBAction func ageSlider(sender: AnyObject) {
        let ageMin = slideToAge(ageSlider.lowerValue)
        let ageMax = slideToAge(ageSlider.upperValue)
        
        updateAgeLabel(ageMin, ageMax: ageMax)
        
        self.userProfile?.ageMin = NSNumber(integer: ageMin)
        self.userProfile?.ageMax = NSNumber(integer: ageMax)
        self.dynamoDBObjectMapper?.saveUpdateSkipNullAttributes(userProfile)
        
    }
    
    func updateAgeLabel(ageMin: Int, ageMax: Int){
        if constantAgeMax == ageMax {
            self.ageLabel.text = "SHOW PEOPLE FROM %d TO %d+".localizedStringWithVariables(ageMin, ageMax)
        }
        else{
            self.ageLabel.text = "SHOW PEOPLE FROM %d TO %d".localizedStringWithVariables(ageMin, ageMax)
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func ageToSlide(age: NSNumber) -> Float{
        let f=(Float(age)-Float(b))/Float(a);
        return f;
    }
    
    func slideToAge(slide: Float) -> Int{
        let age=Int(Float(slide)*Float(a)+Float(b));
        return age;
    }
    
    
}

extension AWSDynamoDBObjectMapper{
    func saveUpdateSkipNullAttributes(model:AWSDynamoDBObjectModel?) -> AWSTask{
        let updateMapperConfig = AWSDynamoDBObjectMapperConfiguration()
        updateMapperConfig.saveBehavior = AWSDynamoDBObjectMapperSaveBehavior.UpdateSkipNullAttributes
        
        return self.save(model, configuration: updateMapperConfig)
    }
}
