//
//  NoBouncePageViewController.swift
//  Story
//
//  Created by Christopher Rydahl on 31/03/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class NoBouncePageViewController: UIPageViewController, UIScrollViewDelegate{
    
    var currentPage: Int=1
    var numberPages: Int=3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate=self;
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
            if (self.currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
            }
            if (self.currentPage == self.numberPages-1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
                scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
            }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (self.currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
            _ = CGPointZero;
            _ = CGPointMake(scrollView.bounds.size.width, 0);
            
        }
        if (self.currentPage == self.numberPages-1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
            _ = CGPointZero;
            _ = CGPointMake(scrollView.bounds.size.width, 0);
        }
    }
    
    
    
    

}