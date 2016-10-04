//
//  PhotoGalerieViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 09/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class PhotoGalerieViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var imageView: UIImageView = UIImageView()
    var image: UIImage?
    var pageIndex: Int?
    var photoKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PhotoGalerieViewController viewDidLoad")
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        self.scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        let twoFingerTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewTwoFingerTapped:")
        twoFingerTapRecognizer.numberOfTapsRequired = 1;
        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
        self.scrollView.addGestureRecognizer(twoFingerTapRecognizer)
        
        
        if let photoKey = photoKey{
            let transferManager = AWSS3TransferUtility.defaultS3TransferUtility()
            transferManager.downloadDataFromBucket("tuesdayphotosbucket", key: photoKey, expression: nil, completionHander: { (task:AWSS3TransferUtilityDownloadTask, url:NSURL?, data:NSData?, error:NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    
                    if let data = data {
                        if let image = UIImage(data:data){
                            self.didDownloadImageLoad(image);
                            self.didDownloadImageWillAppear(image);
                            self.image = UIImage()
                            self.image=image;
                        }
                    }
                    
                }
                
            })
            
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(self.image != nil){
            //self.didDownloadImageLoad(image!);
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        centerScrollViewContents()
    }
    
    
    //MARK - Image
    
    func didDownloadImageLoad(image: UIImage){
        self.imageView = UIImageView(image: image)
        
        self.imageView.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height)
        self.scrollView.addSubview(self.imageView);
        
        // Tell the scroll view the size of the contents
        self.scrollView.contentSize = image.size;
    }
    
    func didDownloadImageWillAppear(image: UIImage){
        self.scrollView.contentSize = image.size;
        
        // Set up the minimum & maximum zoom scales
        let scrollViewFrame = self.view.frame;
        let scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
        let scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
        let minScale = min(scaleWidth, scaleHeight);
        
        self.scrollView.minimumZoomScale = minScale;
        self.scrollView.maximumZoomScale = 1.0;
        self.scrollView.zoomScale = minScale;
        
        centerScrollViewContents();
    }
    
    
    //Mark - Scrollview
    func centerScrollViewContents(){
        let boundsSize = self.view.bounds.size;
        var contentsFrame = self.imageView.frame;
        
        if (contentsFrame.size.width < boundsSize.width) {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0;
        } else {
            contentsFrame.origin.x = 0.0;
        }
        
        if (contentsFrame.size.height < boundsSize.height) {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0;
        } else {
            contentsFrame.origin.y = 0.0;
        }
        
        self.imageView.frame = contentsFrame;
    }
    
    func scrollViewDoubleTapped(recognizer:UITapGestureRecognizer){
        // Get the location within the image view where we tapped
        let pointInView = recognizer.locationInView(self.imageView)
        
        // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
        var newZoomScale = self.scrollView.zoomScale * 1.5;
        newZoomScale = min(newZoomScale, self.scrollView.maximumZoomScale);
        
        // Figure out the rect we want to zoom to, then zoom to it
        let scrollViewSize = self.scrollView.bounds.size;
        
        let w = scrollViewSize.width / newZoomScale;
        let h = scrollViewSize.height / newZoomScale;
        let x = pointInView.x - (w / 2.0);
        let y = pointInView.y - (h / 2.0);
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        self.scrollView.zoomToRect(rectToZoomTo, animated: true)
        
    }
    
    func scrollViewTwoFingerTapped(recognizer:UITapGestureRecognizer){
        // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
        var newZoomScale = self.scrollView.zoomScale / 1.5;
        newZoomScale = max(newZoomScale, self.scrollView.minimumZoomScale);
        self.scrollView.setZoomScale(newZoomScale, animated: true)
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
}
