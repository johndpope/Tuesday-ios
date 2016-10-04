//
//  LoginModelController.swift
//  Friday
//
//  Created by Christopher Rydahl on 03/08/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class LoginModelController: ModelController {
   
    override init(){
        super.init()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imageViewController0 = storyboard.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        imageViewController0.initialisation(imageName: "5.5-inch (iPhone 6+) - Screenshot 1.jpg")
        imageViewController0.index = 0                  
        
        let imageViewController1 = storyboard.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        imageViewController1.initialisation(imageName: "5.5-inch (iPhone 6+) - Screenshot 2.jpg")
         imageViewController1.index = 1
        
        let imageViewController2 = storyboard.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        imageViewController2.initialisation(imageName: "5.5-inch (iPhone 6+) - Screenshot 3.jpg")
        imageViewController2.index = 2
        
        let imageViewController3 = storyboard.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        imageViewController3.initialisation(imageName: "5.5-inch (iPhone 6+) - Screenshot 4.jpg")
        imageViewController3.index = 3
        
        /*let imageViewController4 = storyboard.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        imageViewController4.initialisation(imageName: "5.5-inch (iPhone 6+) - Screenshot 5.jpg")
        imageViewController4.index = 4*/
        
        self.viewControllers = [imageViewController0, imageViewController1, imageViewController2, imageViewController3]
    }
    
}
