
//
//  AddFriendCell.swift
//  Friday
//
//  Created by Christopher Rydahl on 10/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class AddFriendCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    var facebookFriend: FacebookFriend?
    var invitableFriend: NSDictionary?
    var isCellSelected: Bool = false
    var isCellSpecial: Bool = false
    
    @IBOutlet weak var imageIsSelected: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
        // Initialization code
    }
    
    func setUp(){
        if(isCellSpecial){
            specialSetUp()
        }else{
            classicSetUp()
        }
        
    }
    
    func classicSetUp(){
        if (isCellSelected){
            imageIsSelected.backgroundColor = self.tintColor
            imageIsSelected.image = UIImage(named: "Checkmark2.png")
            imageIsSelected.layer.borderWidth = 0.0
            label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            self.backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
        }
        else{
            imageIsSelected.backgroundColor = UIColor.clearColor()
            imageIsSelected.image = nil
            imageIsSelected.layer.borderWidth = 0.5
            label.font = UIFont(name: "HelveticaNeue", size: 17)
            self.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func specialSetUp(){
        imageIsSelected.backgroundColor = UIColor.clearColor()
        imageIsSelected.layer.borderWidth = 0.0
        if (isCellSelected){
            imageIsSelected.image = UIImage(named: "StarFilled.png")
            label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            self.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        }
        else{
            imageIsSelected.image = UIImage(named: "Star.png")
            label.font = UIFont(name: "HelveticaNeue", size: 17)
            self.backgroundColor = UIColor.whiteColor()
        }
    }

}
