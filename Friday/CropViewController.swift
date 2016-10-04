//
//  CropViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class CropViewController: HFImageEditorViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var photoAlbum :PhotoAlbum?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.cropRect=CGRectMake(0, (self.view.frame.size.height-self.view.frame.size.width)/2, self.view.frame.size.width, self.view.frame.size.width);
        self.reset(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getPhoto()
    }
    
    
    func getPhoto2(){
        if (photoAlbum != nil){
            self.refreshActivity(true)
            let graphPath = "/" + self.photoAlbum!.idPhotoAlbum
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: graphPath, parameters: ["fields":"images"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                }
                else
                {
                    print("result: \(result)")
                    if let images : NSArray = result["images"] as? NSArray{
                        var height = 0
                        var picture_url_string = String()
                        for image in images{
                            if let imageDict = image as? NSDictionary{
                                if let heightImage = imageDict.objectForKey("height") as? Int{
                                    if (heightImage > height){
                                        height = heightImage
                                        picture_url_string = imageDict.objectForKey("source") as! String
                                    }
                                    
                                }
                            }
                        }
                        
                        let picture_url = NSURL(string: picture_url_string)
                        PhotoManager.downloadImageWithURL(picture_url!, completionBlock: {
                            (succeeded: Bool, image: UIImage?) -> Void in
                            if (succeeded) {
                                self.sourceImage = image
                                self.changeImage()
                                self.refreshActivity(false)
                            }
                        })
                    }
                }
            })
        }
    }
    
    func getPhoto(){
        if (photoAlbum != nil){
            self.refreshActivity(true)
            let picture_url = NSURL(string: photoAlbum!.sourceString)
            PhotoManager.downloadImageWithURL(picture_url!, completionBlock: {
                (succeeded: Bool, image: UIImage?) -> Void in
                if (succeeded) {
                    self.sourceImage = image
                    self.changeImage()
                    self.refreshActivity(false)
                }
            })
            
        }
    }
    
    // MARK: - refreshActivity
    func refreshActivity(isActivity: Bool){
        if (isActivity){
            activityIndicator.startAnimating()
            self.doneButton.tintColor = UIColor.lightGrayColor()
            self.doneButton.enabled = false
        }else{
            activityIndicator.stopAnimating()
            self.doneButton.tintColor = UIColor.purpleColor()
            self.doneButton.enabled = true
        }
    }
    
    
    // MARK: - Navigation
    
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
