
//
//  MessageChatCell.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 15/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

public struct TypeMessageChatCell{
    static let MyMessageChatCell = 1;
    static let OtherMessageChatCell = 2;
}

class MessageChatCell: UITableViewCell {
    
    var typeMessageChatCell: Int = TypeMessageChatCell.MyMessageChatCell
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var containerChatLabel: UIView!
    @IBOutlet weak var chatLabelAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var sentImageView: AWSImageView!
    
    let systemFont = UIFont.systemFontOfSize(15)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setNeedsLayout()
        //println("setNeedsLayout")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDisplay()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateDisplay()
        self.layoutIfNeeded()
    }
    
    func updateDisplay(){
        print("updateDisplay")
        var fixedWidth = widthForView(chatLabel.text!, font: systemFont, height: 18)
        
        if (typeMessageChatCell == TypeMessageChatCell.OtherMessageChatCell){
            fixedWidth = fixedWidth + 8 + 8 + 8 + 26
        }
        else{
            fixedWidth = fixedWidth + 8 + 8 + 8 + 16 // Width of container
        }
        let constantConstraint = UIScreen.mainScreen().bounds.size.width - self.timeLabel.frame.origin.x - fixedWidth // because cell.chatLabelAlignmentConstraint + fixedWidth = UIScreen.mainScreen().bounds.width - cell.timeLabel.frame.origin.x
        
        if (constantConstraint >= 0){
            self.chatLabelAlignmentConstraint.constant = constantConstraint
        }else{
            self.chatLabelAlignmentConstraint.constant = 0
        }
    }
    
    func widthForView(text:String, font:UIFont, height:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, CGFloat.max, height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.width
    }
}
