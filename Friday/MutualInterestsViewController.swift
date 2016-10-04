//
//  MutualInterestsViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 21/10/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class MutualInterestsViewController: UITableViewController {
    
    var idOtherUser:String?
    var mutualFacebookLikes : [FacebookLike] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.tintColor = UIColor.lightGrayColor()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh".localized)
        self.refreshControl?.addTarget(self, action: #selector(MutualInterestsViewController.refreshMutualFacebookLikes(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshMutualFacebookLikes(self)
    }
    
    func refreshMutualFacebookLikes(sender:AnyObject){
        
        if let idOtherUser = idOtherUser {
            self.refreshControl?.endRefreshing()
            
            FacebookManager.sharedInstance.getMutualLikesWithOtherUser(idOtherUser, completionBlock: { (mutualLikes, error) -> Void in
                
                if (error == nil){
                    
                    print("getMutualLikesWithOtherUser \(mutualLikes)")
                    self.mutualFacebookLikes = mutualLikes.sort({ (a:FacebookLike, b:FacebookLike) -> Bool in
                        return a.name.localizedCaseInsensitiveCompare(b.name) == NSComparisonResult.OrderedAscending
                    })
                    self.tableView.reloadData()
                    
                }
                
            })
            
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mutualFacebookLikes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:AlbumCell! = tableView.dequeueReusableCellWithIdentifier("AlbumCell", forIndexPath: indexPath) as! AlbumCell
        if cell == nil {
            tableView.registerNib(UINib(nibName: "AlbumCell", bundle: nil), forCellReuseIdentifier: "AlbumCell")
            cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell") as? AlbumCell
        }
        self.configureCell(cell, withFacebookLike: self.mutualFacebookLikes[indexPath.row])
        return cell
    }
    
    func configureCell(cell: AlbumCell, withFacebookLike facebookLike: FacebookLike){
        cell.title.text = facebookLike.name
        
        if (facebookLike.picture != nil) {
            cell.illustrationView.image = facebookLike.picture;
        } else {
            // set default user image while image is being downloaded
            cell.illustrationView.image = UIImage();
            
            let urlString = "/"+facebookLike.idFacebook
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: urlString, parameters: ["fields":"picture"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                }
                else
                {
                    print("result: \(result)")
                    if let picture = result["picture"] as? NSDictionary{
                        
                        if let picture_data = picture["data"] as? NSDictionary{
                            
                            if let picture_url = picture_data["url"] as? String{
                                
                                // download the image asynchronously
                                PhotoManager.downloadImageWithURL(NSURL(string: picture_url) as NSURL!, completionBlock: {
                                    (succeeded: Bool, image: UIImage?) -> Void in
                                    if (succeeded) {
                                        // change the image in the cell
                                        cell.illustrationView.image = image;
                                        
                                        // cache the image for use later (when scrolling up)
                                        facebookLike.picture = image;
                                    }
                                })
                            }
                        }
                        
                    }
                    
                }
            })
            
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
