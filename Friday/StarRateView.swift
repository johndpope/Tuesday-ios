//
//  StarRateCell.swift
//  Friday
//
//  Created by Christopher Rydahl on 24/09/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class StarRateView: UIView {

    var nibName: String = "StarRateView"
    var view: UIView!;
    
    @IBOutlet weak var buttonStar1: UIButton!
    @IBOutlet weak var buttonStar2: UIButton!
    @IBOutlet weak var buttonStar3: UIButton!
    @IBOutlet weak var buttonStar4: UIButton!
    @IBOutlet weak var buttonStar5: UIButton!
    @IBOutlet weak var containerButtonStar: UIView!
    var markReview: Int?
    var delegate:StarReviewViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    func setUp(){
        view = loadViewFromNib()
        
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        addSubview(view)
        
        //Initialisation
        
    }
    
    func loadViewFromNib() -> UIView{
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func buttonStar(sender: AnyObject) {
        if let buttonStar = sender as? UIButton{
            let tag = buttonStar.tag
            for subview in self.containerButtonStar.subviews{
                if let otherButtonStar = subview as? UIButton{
                    if otherButtonStar.tag > tag{
                        otherButtonStar.setImage(UIImage(named: "StarRating.png") , forState: UIControlState.Normal)
                    }else{
                        otherButtonStar.setImage(UIImage(named: "StarRatingFilled.png") , forState: UIControlState.Normal)
                    }
                }
            }
            markReview = tag
        }
        delegate?.didButtonStar(self)
    }
    
}

protocol StarReviewViewDelegate{
    func didButtonStar(starRateReview:StarRateView)
}


