//
//  DashboardCell.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 15/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class DashboardCell: UICollectionViewCell {
    
    var delegate: DashboardCellDelegate?
    
    @IBOutlet weak var profilImageView: AWSImageView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var labelLikeNope: UILabel!
    
    @IBOutlet weak var viewLabel: UIView!
    @IBOutlet weak var label: UILabel!
    
    @IBAction func crossButton(sender: AnyObject) {
        cross()
    }
    
    @IBAction func checkButton(sender: AnyObject) {
        check()
    }
    
    func cross(){
        if let isNewOnDashboardNope = NSUserDefaults.standardUserDefaults().objectForKey(NSUserDefaultsKey.IS_NEW_ON_DASHBOARD_NOPE) as? Bool {
            if isNewOnDashboardNope{
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: NSUserDefaultsKey.IS_NEW_ON_DASHBOARD_NOPE)
                NSUserDefaults.standardUserDefaults().synchronize()
                let alertView = UIAlertController(title: "Not interested?".localizedStringWithVariables() , message: "Tapping the ❌ indicates you're not interested in this user".localized, preferredStyle: UIAlertControllerStyle.Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                })
                
                let okAction = UIAlertAction(title: "Not interested".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
                    self.effectCellBeforeDeleting(isLiked: false)
                })
                
                alertView.addAction(cancelAction)
                alertView.addAction(okAction)
                self.delegate?.presentAlertController(alertView)
                return
            }
        }
        
        self.effectCellBeforeDeleting(isLiked: false)
    }
    
    func check(){
        if let isNewOnDashboardLike = NSUserDefaults.standardUserDefaults().objectForKey(NSUserDefaultsKey.IS_NEW_ON_DASHBOARD_LIKE) as? Bool {
            if isNewOnDashboardLike {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: NSUserDefaultsKey.IS_NEW_ON_DASHBOARD_LIKE)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let alertView = UIAlertController(title: "Like?".localized, message: "Tapping the ✅ indicates you liked this user".localized, preferredStyle: UIAlertControllerStyle.Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                })
                
                let okAction = UIAlertAction(title: "Like".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
                    self.effectCellBeforeDeleting(isLiked: true)
                })
                
                alertView.addAction(cancelAction)
                alertView.addAction(okAction)
                self.delegate?.presentAlertController(alertView)
                return;
            }
        }
        
        self.effectCellBeforeDeleting(isLiked: true)
    }
    
    func effectCellBeforeDeleting(isLiked _isLiked: Bool){
        var color: UIColor
        var text: String
        var intRotation: CGFloat
        if (_isLiked){
            color = UIColor(red: 0/255.0, green: 195/255.0, blue: 0/255.0, alpha: 1.0)
            text = "LIKE".localized
            intRotation = 1
        }else{
            color = UIColor(red: 195/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
            text = "NOPE".localized
            intRotation = -1
        }
        
        labelLikeNope.text=text;
        labelLikeNope.layer.borderColor=color.CGColor;
        labelLikeNope.textColor=color;
        labelLikeNope.alpha=0;
        
        labelLikeNope.transform = CGAffineTransformMakeRotation(intRotation * CGFloat(M_PI)/4)
        
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.labelLikeNope.alpha=1;
            self.labelLikeNope.transform=CGAffineTransformConcat(CGAffineTransformScale(self.labelLikeNope.transform, 0.5, 0.5),CGAffineTransformMakeRotation(-intRotation*CGFloat(M_PI/4+M_PI/8)));
            }, completion: { (success: Bool) -> Void in
                
                if (_isLiked){
                    self.delegate?.checkButton(self)
                }
                else{
                    self.delegate?.crossButton(self)
                }
                
                UIView.animateWithDuration(0.3, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.labelLikeNope.alpha=0;
                    
                    }, completion:{ (success: Bool) -> Void in
                        self.labelLikeNope.transform=CGAffineTransformConcat(CGAffineTransformScale(self.labelLikeNope.transform, 0.5, 0.5),CGAffineTransformMakeRotation(intRotation*CGFloat(M_PI/2)));
                        self.labelLikeNope.removeFromSuperview()
                })
                
        })
    }
}

protocol DashboardCellDelegate{
    func checkButton(cell: UICollectionViewCell)
    func crossButton(cell: UICollectionViewCell)
    func presentAlertController(alertController: UIAlertController)
}
