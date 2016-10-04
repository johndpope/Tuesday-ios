//
//  UtilisateurGalerieViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 11/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class UtilisateurGalerieViewController: GalerieViewController {
    
    var user: AWSUser?
    var truth:String! = "This user didn't edit his truths/lies".localized
    var desc:String! = "This user didn't fill in his profile".localized
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var truthButton: UIButton!
    @IBOutlet weak var descriptionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognize = UITapGestureRecognizer(target: self, action: #selector(UtilisateurGalerieViewController.tapView(_:)))
        self.view.addGestureRecognizer(tapGestureRecognize)
        
        if let isBoy = user?.isBoy{
            truth = ( isBoy == 1 ? "This user didn't edit his truths/lies".localized : "This user didn't edit her truths/lies".localized )
            desc = ( isBoy == 1 ? "This user didn't fill in his profile".localized : "This user didn't fill in her profile".localized )
        }
        
        initialisation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        createLabel();
        setFrameLabel("")
        super.viewDidAppear(animated)
    }
    
    override func initialisation(){
        
        if let user = user {
            if let firstName = user.firstName {
                self.titleLabel.text = firstName
            }
            
            self.viewControllers = NSMutableArray();
            
            if let photoKeys = user.photoKeys{
                let count = photoKeys.count
                if count > 0 {
                    var newPhotoKeys: [String] = []
                    for i in 0 ..< count{
                        newPhotoKeys.append(PhotoManager.sharedInstance.getKey(user.idFacebook!, suffix: photoKeys[i]))
                    }
                    self.photoKeys = newPhotoKeys
                    self.numberOfPages = photoKeys.count;
                    for _ in 0 ..< self.numberOfPages {
                        self.viewControllers.addObject(NSNull());
                    }
                    super.initialisation()
                }
            }
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            dynamoDBObjectMapper.load(AWSUserProfile.self, hashKey: user.idFacebook!, rangeKey: nil).continueWithBlock { (task:AWSTask) -> AnyObject? in
                print("AWSManager UserProfile")
                if let userProfile = task.result as? AWSUserProfile {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if let description = userProfile.desc {
                            if (description != ""){
                                self.desc = description
                                self.descriptionButton.alpha = 1
                            }
                        }
                        
                        //truth
                        let lie = userProfile.lie
                        let truth1 = userProfile.truth1
                        let truth2 = userProfile.truth2
                        
                        var array: [String] = []
                        if (lie != nil && lie != ""){
                            array.append(lie!)
                        }
                        if (truth1 != nil && truth1 != ""){
                            array.append(truth1!)
                        }
                        if (truth2 != nil && truth2 != ""){
                            array.append(truth2!)
                        }
                        let count = array.count
                        
                        if (count > 0){
                            self.truth = "Which clue is a lie?".localized
                            self.truth = self.truth + "\n"
                            
                            array.shuffle()
                            for i in 0 ..< count {
                                self.truth = self.truth + "• " + array[i]
                                if (i != count - 1){
                                    self.truth = self.truth + "\n"
                                }
                            }
                            
                            self.truthButton.alpha = 1
                        }
                        
                    }
                }
                return nil
            }
            
            
        }
        
        
    }
    
    
    @IBAction func dotsButton(sender: AnyObject) {
        
        let actionSheetView = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
        })
        actionSheetView.addAction(cancelAction)
        
        let reportUserAction = UIAlertAction(title: "Report this user".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            
            var titleAlertView = "Confirm you report this user".localized
            if let firstName = self.user?.firstName {
                titleAlertView = "Confirm you report %@".localizedStringWithVariables(firstName)
            }
            
            let alertView = UIAlertController(title: titleAlertView, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction2 = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
            })
            alertView.addAction(cancelAction2)
            
            let confirmAction = UIAlertAction(title: "Confirm".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                
                let reportUser = AWSReportUser()
                reportUser.idReportingUser = AWSManager.sharedInstance.idFacebook!
                reportUser.idReportedUser = self.user!.idFacebook
                reportUser.whichReport = NSNumber(integer: 0)
                
                let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                dynamoDBObjectMapper.saveUpdateSkipNullAttributes(reportUser).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.view.makeToast("User reported".localized, duration: 2.0, position: "center")
                    }
                    return nil
                })
                
                
            });
            alertView.addAction(confirmAction)
            
            self.presentViewController(alertView, animated: true, completion: nil)
            
        })
        actionSheetView.addAction(reportUserAction)
        
        let mutualInterestAction = UIAlertAction(title: "See mutual interests".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mutualInterestsViewController = storyboard.instantiateViewControllerWithIdentifier("MutualInterestsViewController") as? MutualInterestsViewController{
                mutualInterestsViewController.idOtherUser = self.user?.idFacebook
                let navigationController = UINavigationController(rootViewController: mutualInterestsViewController)
                navigationController.navigationBar.tintColor = UIColor.purpleColor()
                navigationController.navigationBar.translucent = false
                self.presentViewController(navigationController, animated: true, completion: nil)
            }
            
        })
        actionSheetView.addAction(mutualInterestAction)
        
        self.presentViewController(actionSheetView, animated: true, completion: nil)
        
    }
    
    
    @IBAction func descriptionButton(sender: AnyObject) {
        let shouldDisplayDescription = (maskView.alpha==0) || (descriptionLabel.text != desc)
        displayDescriptionLabel(shouldDisplayDescription: shouldDisplayDescription, text:desc);
    }
    
    @IBAction func truthButton(sender: AnyObject) {
        let shouldDisplayDescription = (maskView.alpha==0) || (descriptionLabel.text != truth)
        displayDescriptionLabel(shouldDisplayDescription: shouldDisplayDescription, text:truth);
    }
    
    func displayDescriptionLabel(shouldDisplayDescription _shouldDisplayDescription: Bool, text: String){
        if (_shouldDisplayDescription){
            self.descriptionLabel.alpha = 0;
            self.descriptionLabel.hidden = false;
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                () -> Void in
                self.setFrameLabel(text);
                self.titleLabel.frame=CGRectMake(self.titleLabel.frame.origin.x, self.descriptionLabel.frame.origin.y-self.titleLabel.frame.size.height, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
                self.maskView.alpha=0.7;
                self.descriptionLabel.alpha=1;
                }, completion: nil)
        }
        else{
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                () -> Void in
                self.maskView.alpha=0;
                self.descriptionLabel.alpha=0;
                self.setFrameLabel("");
                self.titleLabel.frame=CGRectMake(self.titleLabel.frame.origin.x, self.descriptionLabel.frame.origin.y-self.titleLabel.frame.size.height, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
                }, completion: {(success: Bool) -> Void in
                    
            })
        }
    }
    
    
    
    func tapView(sender: AnyObject) {
        
        if(containerDotsButton.hidden){
            
            self.dotsButton.hidden=false;
            self.containerDotsButton.hidden = false;
            self.doneButton.hidden = false;
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                () -> Void in
                self.titleLabel.alpha=1;
                self.line.alpha=1;
                self.dotsButton.alpha=1;
                self.containerDotsButton.alpha = 1;
                self.doneButton.alpha = 1;
                }, completion: nil)
        }
        else{
            displayDescriptionLabel(shouldDisplayDescription: false, text: "");
            
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                () -> Void in
                self.titleLabel.alpha=0;
                self.line.alpha=0;
                self.dotsButton.alpha=0;
                self.containerDotsButton.alpha = 0;
                self.doneButton.alpha = 0;
                }, completion: {(success: Bool) -> Void in
                    self.dotsButton.hidden=true;
                    self.containerDotsButton.hidden = true;
                    self.doneButton.hidden = true;
            })
        }
    }
}

extension CollectionType where Index == Int {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
