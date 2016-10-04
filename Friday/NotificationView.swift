//
//  NotificationView.swift
//  Story
//
//  Created by Christopher Rydahl on 18/05/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class NotificationView: UIView {

    @IBOutlet weak var title: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame);
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        print("codercodercoder")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib")
    }
    
}
