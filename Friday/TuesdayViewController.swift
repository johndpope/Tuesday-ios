//
//  TuesdayViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 13/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class TuesdayViewController: ContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate!.tuesdayViewController = self
    }
    
    override func updateCurrentViewController(completionBlock : (() -> Void)?){
        print("updateCurrentViewController TuesdayViewController")
        
        MeetingManager.sharedInstance.getCurrentUserInGroup { (user_in_Group, error) -> Void in
            self.updateViewController(user_in_Group)
        }
    }
    
    func updateViewController(user_in_Group:AWSUser_in_Group?){
        print("updateViewController user_in_Group \(user_in_Group)")
        
        if let user_in_Group = user_in_Group{
            
            if let dateString = user_in_Group.dateString?.getDateYYYYMMdd() {
                if (NSDate().isLessOrEqualThanDateWithoutTime(dateString)){
                    editGroupViewController?.user_in_group = user_in_Group
                    
                    if let groupPartitionKey = user_in_Group.groupPartitionKey, groupSortKey = user_in_Group.groupSortKey{
                        
                        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                        dynamoDBObjectMapper.load(AWSGroup.self, hashKey: groupPartitionKey, rangeKey: groupSortKey).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                            
                            if let myGroup = task.result as? AWSGroup{
                                dispatch_async(dispatch_get_main_queue()) {
                                    if let otherGroupSortKey = myGroup.otherGroupSortKey{
                                        if (otherGroupSortKey == "-1"){
                                            self.editGroupViewController?.otherGroupSortKey = "-1"
                                            self.displayViewController(self.editGroupViewController)
                                        }
                                        else{
                                            self.meetingViewController?.user_in_group = user_in_Group
                                            self.meetingViewController?.myGroup = myGroup
                                            self.displayViewController(self.meetingViewController)
                                        }
                                    }
                                    else{
                                         self.displayViewController(self.editGroupViewController)
                                    }
                                }
                            }
                            
                            return nil
                        })
                        
                    }
                    
                    
                }
                else{
                    createGroupViewController?.previousUserInGroup = user_in_Group
                    self.displayViewController(createGroupViewController)
                }
                
            }
            
        }
        else{
            createGroupViewController?.previousUserInGroup = nil
            self.displayViewController(createGroupViewController)
        }
        
    }
    
}
