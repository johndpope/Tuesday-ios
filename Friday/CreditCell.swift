//
//  CreditCell.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 23/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class CreditCell: UITableViewCell {

    @IBOutlet weak var nbCreditsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var illustrationImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
        // Initialization code
    }
    
    func setUp(){
        
        
    }

}
