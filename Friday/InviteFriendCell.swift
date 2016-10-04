//
//  InviteFriendCell.swift
//  Friday
//
//  Created by Christopher Rydahl on 30/09/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//


import Foundation

class InviteFriendCell: UITableViewCell {
    
    var addressBookContact: AddressBookContact?
    
    @IBOutlet weak var label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
        // Initialization code
    }
    
    func setUp(){
        
        
    }
    
}