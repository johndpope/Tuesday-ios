//
//  GalerieViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 09/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class GalerieViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
    var numberOfPages: Int = 0
    var viewControllers : NSMutableArray = []
    var photoKeys: [String] = []
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var dotsButton: UIButton!
    @IBOutlet weak var containerDotsButton: UIView!
    var descriptionLabel: UILabel = UILabel()
    
    let font = UIFont(name:"HelveticaNeue-Thin", size:14)
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
    func initialisation() {
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        let startingViewController = self.viewControllerAtIndex(0)
        if let startingViewController = startingViewController {
            if self.viewControllers.count > 0 {
                self.viewControllers.replaceObjectAtIndex(0, withObject: startingViewController)
                self.pageViewController.setViewControllers([startingViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            }
        }
        
        //Si il n'y a pas de photo...
        /*if self.viewControllers.count == 0 {
            print("self.viewControllers.count == 0")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let photoGalerieViewController = storyboard.instantiateViewControllerWithIdentifier("PhotoGalerieViewController") as? PhotoGalerieViewController
            photoGalerieViewController!.pageIndex = 0;
            self.viewControllers.addObject(photoGalerieViewController!)
        }*/
        
        // Change the size of page view controller
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.view.insertSubview(self.pageViewController.view, atIndex: 0)
        
    }
    
    
    
    func viewControllerAtIndex(index: Int) -> PhotoGalerieViewController?{
        if (numberOfPages == 0) || (index >= numberOfPages) {
            return nil;
        }
        
        if(index < self.viewControllers.count ){
            if(!(self.viewControllers.objectAtIndex(index) is NSNull)){
                return self.viewControllers.objectAtIndex(index) as? PhotoGalerieViewController;
            }
        }
        
        // Create a new view controller and pass suitable data.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoGalerieViewController = storyboard.instantiateViewControllerWithIdentifier("PhotoGalerieViewController") as? PhotoGalerieViewController
        photoGalerieViewController!.pageIndex = index;
        if index < self.photoKeys.count {
            photoGalerieViewController!.photoKey = self.photoKeys[index];
        }
        self.viewControllers.replaceObjectAtIndex(index, withObject: photoGalerieViewController!)
        return photoGalerieViewController;
    }
    
    //Mark - UIPageViewControllerDatasource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PhotoGalerieViewController).pageIndex;
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
        
        index!--;
        
        return self.viewControllerAtIndex(index!)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PhotoGalerieViewController).pageIndex;
        
        if (index == NSNotFound) {
            return nil;
        }
        
        index!++;
        if (index == self.numberOfPages) {
            return nil;
        }
        
        return self.viewControllerAtIndex(index!)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return numberOfPages
    }
    
    
    func createLabel(){
        descriptionLabel = UILabel(frame: CGRectMake(0,0,0,0));
        descriptionLabel.text = "";
        descriptionLabel.textColor=UIColor.lightGrayColor()
        descriptionLabel.font=font;
        descriptionLabel.hidden=true;
        descriptionLabel.numberOfLines=10;
        self.view.addSubview(descriptionLabel)
    }
    
    func setFrameLabel(description: NSString){
        var descriptionHeight = CGFloat(0);
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width;
        
        if (description != ""){
            let sizeOfString = font?.sizeOfString(description as String, constrainedToWidth: Double(screenWidth))
            descriptionHeight = sizeOfString!.height;
        }
        
        descriptionLabel.frame = CGRectMake(15, self.line.frame.origin.y-10-descriptionHeight, screenWidth-30, descriptionHeight);
        descriptionLabel.text = description as String;
        
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}
