//
//  CALayer+XibConfiguration.h
//  Story
//
//  Created by Christopher Rydahl on 01/04/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer(XibConfiguration)

// This assigns a CGColor to borderColor.
@property(nonatomic, assign) UIColor* borderUIColor;

@end