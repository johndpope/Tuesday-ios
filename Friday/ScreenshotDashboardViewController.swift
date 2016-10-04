//
//  ScreenshotDashboardViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 03/07/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class ScreenshotDashboardViewController: UIViewController {

    var labelLikeNope: UILabel = UILabel(frame: CGRectMake(0, 0, 250, 100))
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelLikeNope.layer.cornerRadius=15;
        labelLikeNope.layer.borderWidth=4.0;
        labelLikeNope.font = UIFont(name: "HelveticaNeue-Bold", size: 75)
        labelLikeNope.textAlignment = NSTextAlignment.Center
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func displayLikeLabel(){
        var color: UIColor
        var text: String
        var intRotation: CGFloat
        color = UIColor(red: 0/255.0, green: 195/255.0, blue: 0/255.0, alpha: 1.0)
        text = "LIKE"
        intRotation = 1
        
        labelLikeNope.text=text;
        labelLikeNope.layer.borderColor=color.CGColor;
        labelLikeNope.textColor=color;
        labelLikeNope.alpha=0;
        
        self.containerView.addSubview(labelLikeNope)
        labelLikeNope.center = self.containerView.center
        labelLikeNope.transform = CGAffineTransformMakeRotation(intRotation * CGFloat(M_PI)/4)
        
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.labelLikeNope.alpha=1;
            self.labelLikeNope.transform=CGAffineTransformConcat(CGAffineTransformScale(self.labelLikeNope.transform, 0.5, 0.5),CGAffineTransformMakeRotation(-intRotation*CGFloat(M_PI/4+M_PI/8)));
            }, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
