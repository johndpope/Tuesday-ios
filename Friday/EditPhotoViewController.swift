//
//  EditPhotoViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class EditPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: AWSUser?
    var dynamoDBObjectMapper: AWSDynamoDBObjectMapper?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let user = user {
                self.user = user
            }
        }
    }
    
    func sendImage(imageData: NSData){
        print("sendImage")
        
        var order = 0;
        if let count = user?.photoKeys?.count {
            order = count
        }
        
        if let cell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: order, inSection: 0)) as? PictureCell{
            cell.activityIndicator.startAnimating()
            
            PhotoManager.sharedInstance.uploadDataPhoto(imageData, completionBlock: { () -> Void in
                
                cell.activityIndicator.stopAnimating()
                let imageView = AWSImageView()
                imageView.image = UIImage(data: imageData)
                cell.backgroundView = imageView
                
            })
        }
        
        else{
            self.view.makeToast("An error occured".localized)
        }
        
        
        
        
    }
    
    func getLocalPhotos(){
        print("getLocalPhotos")
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let user = user {
                self.user = user
                print("self.user \(self.user)")
                self.collectionView.reloadData()
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:PictureCell! = collectionView.dequeueReusableCellWithReuseIdentifier("PictureCell", forIndexPath: indexPath) as! PictureCell
        self.configurePictureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configurePictureCell(cell: PictureCell, atIndexPath indexPath: NSIndexPath){
        cell.activityIndicator.stopAnimating()
        
        
        if let currentUser = user {
            
            if let photoKeys = currentUser.photoKeys{
                
                if indexPath.row < photoKeys.count{
                    
                    let imageView = AWSImageView()
                    imageView.setPhotoPictureFromKey(PhotoManager.sharedInstance.getKey(currentUser.idFacebook!, suffix: photoKeys[indexPath.row]))
                    cell.backgroundView = imageView
                    cell.imagePlus.hidden = true
                    
                }
                    
                else{
                    cell.backgroundView = nil
                    cell.backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
                    cell.imagePlus.hidden = false
                }
                
            }
            
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let photoKeys = user?.photoKeys {
            
            if indexPath.row < photoKeys.count{
                
                let alertView = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
                })
                alertView.addAction(cancelAction)
                
                if (indexPath.row == 0 && photoKeys.count == 1){
                    let addPhotoAction = UIAlertAction(title: "Add Photo".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                        self.performSegueWithIdentifier("AlbumsVC", sender: self)
                    })
                    alertView.addAction(addPhotoAction)
                }
                else{
                    let deletePhotoAction = UIAlertAction(title: "Delete Photo".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                        var newPhotoKeys = self.user?.photoKeys
                        newPhotoKeys?.removeAtIndex(indexPath.row);
                        self.user?.photoKeys = newPhotoKeys
                        self.dynamoDBObjectMapper?.saveUpdateSkipNullAttributes(self.user).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                            dispatch_async(dispatch_get_main_queue()) {
                                print("taskerror \(task.error)")
                                print("taskexception \(task.exception)")
                                if let error = task.error{
                                    print("taskerror \(error)")
                                    self.view.makeToast("An error occured".localized)
                                }
                                else{
                                    self.getLocalPhotos()
                                }
                            }
                            return nil
                        })
                    })
                    alertView.addAction(deletePhotoAction)
                }
                
                
                
                
                self.presentViewController(alertView, animated: true, completion: nil)
                
                return
                
            }
            
        }
        
        self.performSegueWithIdentifier("AlbumsVC", sender: self)
        
    }
    
    // MARK - LXReorderableCollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, willEndDraggingItemAtIndexPath indexPath: NSIndexPath) {
        print("willEndDraggingItemAtIndexPath \(indexPath)")
        if let currentUser = user {
            self.dynamoDBObjectMapper?.saveUpdateSkipNullAttributes(currentUser)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, itemAtIndexPath fromIndexPath: NSIndexPath, willMoveToIndexPath toIndexPath: NSIndexPath) {
        if let currentUser = user {
            
            var photoKeys = currentUser.photoKeys
            
            if let myPhotoUtilisateur = photoKeys?[fromIndexPath.row]{
                photoKeys?.removeAtIndex(fromIndexPath.row);
                photoKeys?.insert(myPhotoUtilisateur, atIndex:toIndexPath.row)
                currentUser.photoKeys = photoKeys
                
                self.dynamoDBObjectMapper?.saveUpdateSkipNullAttributes(currentUser)
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let photoKeys = user?.photoKeys{
            if(indexPath.row < photoKeys.count){
                return true;
            }
            else{
                return false;
            }
        }
        return true
        
    }
    
    func collectionView(collectionView: UICollectionView, itemAtIndexPath fromIndexPath: NSIndexPath, canMoveToIndexPath toIndexPath: NSIndexPath) -> Bool {
        if let photoKeys = user?.photoKeys{
            if(toIndexPath.row < photoKeys.count && fromIndexPath.row < photoKeys.count){
                return true;
            }
            else{
                return false;
            }
        }
        return true
    }
    
    
    
    @IBAction func addPhotoButton(sender: AnyObject) {
        self.performSegueWithIdentifier("AlbumsVC", sender: self)
    }
    
    // MARK: - Navigation
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
