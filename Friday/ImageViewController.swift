//
//  ImageViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 03/08/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, IndexProtocol {

    @IBOutlet weak var imageView: UIImageView!
    var imageName: String?
    var index:Int=0
    
    func initialisation(imageName _imageName: String){
        self.imageName = _imageName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.imageName != nil {
            self.imageView.image = UIImage(named: self.imageName! )
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
