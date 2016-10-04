//
//  CALayer+XibConfiguration.m
//  Story
//
//  Created by Christopher Rydahl on 01/04/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//
#import "CALayer+XibConfiguration.h"

@implementation CALayer(XibConfiguration)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end