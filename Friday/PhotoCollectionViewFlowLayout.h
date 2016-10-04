//
//  PhotoCollectionViewFlowLayout.h
//  Bob
//
//  Created by Christopher Rydahl on 22/07/2014.
//  Copyright (c) 2014 Christopher Rydahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXReorderableCollectionViewFlowLayout.h"

@interface PhotoCollectionViewFlowLayout : LXReorderableCollectionViewFlowLayout

@property (nonatomic, strong) NSDictionary *layoutInfo;


@property (nonatomic) float columnWidth;
@property (nonatomic) float padding;
@property (nonatomic) float rowHeight;
@property (nonatomic) float largeCell;
@property (nonatomic) float mediumCell;


@end
