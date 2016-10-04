//
//  PhotoAlbumViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var album: Album?
    var photoArray: [PhotoAlbum] = []
    let edge: CGFloat = 1.0
    let nbCellPerRow: CGFloat = 4.0
    
    @IBOutlet weak var titleBarItem: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleBarItem.text = album!.name
        getPhotos()
    }
    
    func initialisation(){
        
    }
    
    func getPhotos(){
        if (album != nil){
            self.refreshActivity(true)
            let graphPath = "/" + self.album!.idAlbum + "/photos?limit=200"
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: graphPath, parameters: ["fields":"id, source, picture"])
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
                        let array = NSMutableArray()
                        data.enumerateObjectsUsingBlock{
                            (alb : AnyObject!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                            let photoAlbum = PhotoAlbum(_idPhotoAlbum: alb.objectForKey("id") as! String, _sourceString: alb.objectForKey("source") as! String, _pictureString: alb.objectForKey("picture") as! String)
                            array.addObject(photoAlbum)
                        }
                        
                        self.photoArray = NSArray(array: array) as! [PhotoAlbum]
                        self.collectionView.reloadData()
                        self.refreshActivity(false)
                    }
                }
            })
        }
    }
    
    // MARK: - Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:PhotoCell! = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        if cell == nil {
            collectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as? PhotoCell
        }
        self.configurePhotoCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configurePhotoCell(cell: PhotoCell, atIndexPath indexPath: NSIndexPath){
        let photoAlbum = photoArray[indexPath.row]
        
        if (photoAlbum.picture != nil) {
            cell.photoView.image = photoAlbum.picture;
        } else {
            // set default user image while image is being downloaded
            cell.photoView.image = UIImage();
            let picture_url = NSURL(string: photoAlbum.pictureString)
            
            // download the image asynchronously
            PhotoManager.downloadImageWithURL(picture_url as NSURL! , completionBlock: {
                (succeeded: Bool, image: UIImage?) -> Void in
                if (succeeded) {
                    // change the image in the cell
                    cell.photoView.image = image;
                    
                    // cache the image for use later (when scrolling up)
                    photoAlbum.picture = image;
                }
            })
            
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("CropPhotoVC", sender: photoArray[indexPath.row])
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.frame.size.width / nbCellPerRow - 8 ;
        return CGSizeMake(width, width);
    }
    
    
    
    // MARK: - refreshActivity
    func refreshActivity(isActivity: Bool){
        if (isActivity){
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "CropPhotoVC" ){
            if let dest = segue.destinationViewController as? CropViewController, photoAlbum = sender as? PhotoAlbum{
                
                dest.sourceImage = photoAlbum.picture;
                dest.previewImage = photoAlbum.picture;
                
                dest.minimumScale = 0.2;
                dest.maximumScale = 10;
                
                dest.photoAlbum = photoAlbum;
                dest.checkBounds = true;
                dest.doneCallback = {(editedImage: UIImage?, canceled: Bool) -> Void in
                    if(!canceled) {
                        let imageData = UIImageJPEGRepresentation(editedImage!, 1.0);
                        if let editPhotoViewController = self.navigationController!.viewControllers[1] as? EditPhotoViewController{
                            editPhotoViewController.sendImage(imageData!)
                            self.navigationController?.popToViewController(editPhotoViewController, animated: true)
                        }
                    }else{
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                
                
            }
        }
    }
}
