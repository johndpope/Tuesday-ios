//
//  AlbumsViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class AlbumsViewController: UITableViewController {
    
    var albumArray: Array<Album> = [];
    @IBOutlet weak var activityIndicator: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllAlbums()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Facebook
    func getAllAlbums(){
        self.refreshActivity(true)
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/albums", parameters: ["fields":"id, name, count, cover_photo"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("result: \(result)")
                if let data : NSArray = result["data"] as? NSArray{
                    let albumUnsorted = NSMutableArray()
                    data.enumerateObjectsUsingBlock{
                        (alb : AnyObject!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                        
                        let idAlbum = alb.objectForKey("id") as? String
                        let name = alb.objectForKey("name") as? String
                        let count = alb.objectForKey("count") as? Int
                        let coverPhoto = alb.objectForKey("cover_photo") as? NSDictionary
                        let idCoverPhoto = coverPhoto!.objectForKey("id") as? String
                        
                        print("idAlbum: \(idAlbum)")
                        
                        if idAlbum != nil && name != nil && count != nil && idCoverPhoto != nil {
                            let album = Album(_idAlbum:idAlbum!, _name: name!, _count: count!, _idCoverPhoto: idCoverPhoto!)
                            albumUnsorted.addObject(album)
                        }
                    }
                    
                    
                    let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
                    let sortDescriptors = [sortDescriptor]
                    albumUnsorted.sortUsingDescriptors(sortDescriptors)
                    self.albumArray = NSArray(array: albumUnsorted) as! [Album]

                    self.tableView.reloadData()
                    self.refreshActivity(false)
                }
            }
        })
    }
    
    // MARK: - TableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:AlbumCell! = tableView.dequeueReusableCellWithIdentifier("AlbumCell", forIndexPath: indexPath) as! AlbumCell
        if cell == nil {
            tableView.registerNib(UINib(nibName: "AlbumCell", bundle: nil), forCellReuseIdentifier: "AlbumCell")
            cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell") as? AlbumCell
        }
        self.configureAlbumCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureAlbumCell(cell: AlbumCell, atIndexPath indexPath : NSIndexPath){
        
        let album=self.albumArray[indexPath.row]
        cell.title.text=album.name;
        
        cell.subtitle.text = "%d photos".localizedStringWithVariables(album.count)
        if (album.picture != nil) {
            cell.illustrationView.image = album.picture;
        } else {
            // set default user image while image is being downloaded
            cell.illustrationView.image = UIImage();
            let urlString = "/"+album.idCoverPhoto
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: urlString, parameters: ["fields":"id, picture"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                }
                else
                {
                    print("result: \(result)")
                    let picture_url = NSURL(string: result.objectForKey("picture") as! String)
                    
                    // download the image asynchronously
                    PhotoManager.downloadImageWithURL(picture_url as NSURL! , completionBlock: {
                        (succeeded: Bool, image: UIImage?) -> Void in
                        if (succeeded) {
                            // change the image in the cell
                            cell.illustrationView.image = image;
                            
                            // cache the image for use later (when scrolling up)
                            album.picture = image;
                        }
                    })
                    
                }
            })
            
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("PhotoAlbumVC", sender: albumArray[indexPath.row])
    }
    
    
    
    // MARK: - refreshActivity
    func refreshActivity(isActivity: Bool){
        if (isActivity){
            activityIndicator.beginRefreshing()
        }else{
            activityIndicator.endRefreshing()
        }
        
    }
    
    // MARK: - Navigation
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "PhotoAlbumVC" ){
            if let dest = segue.destinationViewController as? PhotoAlbumViewController, album = sender as? Album{
                dest.album = album
            }
        }
    }
}
