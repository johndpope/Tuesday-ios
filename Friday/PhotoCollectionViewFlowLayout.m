//
//  PhotoCollectionViewFlowLayout.m
//  Bob
//
//  Created by Christopher Rydahl on 22/07/2014.
//  Copyright (c) 2014 Christopher Rydahl. All rights reserved.
//

#import "PhotoCollectionViewFlowLayout.h"
#define kPadding 4


static NSString * const CellKind = @"PictureCell";

@implementation PhotoCollectionViewFlowLayout

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{    
    float width=[UIScreen mainScreen].bounds.size.width;
    self.mediumCell=(width-4*kPadding)/3;
    self.largeCell=2*self.mediumCell+kPadding;
    self.columnWidth=self.mediumCell;
    self.rowHeight=self.mediumCell;
}

#pragma mark - Layout

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForAlbumPhotoAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[CellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

#pragma mark - Private

- (CGRect)frameForAlbumPhotoAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index=indexPath.row;
    
    int column = 0;
    switch (index) {
        case 0:
        case 5:
            column = 0;
            break;
        case 4:
            column = 1;
            break;
        case 1:
        case 2:
        case 3:
            column = 2;
            break;
        default:
            column = 0;
            break;
    }
    
    int row = 0;
    switch (index) {
        case 0:
        case 1:
            row = 0;
            break;
        case 2:
            row = 1;
            break;
        case 3:
        case 4:
        case 5:
            row = 2;
            break;
        default:
            row = 0;
            break;
    }
    float horizontalOffset = kPadding+((self.columnWidth + kPadding) * column);
    float verticalOffset = kPadding+(self.rowHeight + kPadding) * row;
    
    // finally, determine the size of the cell.
    float width = 0.0;
    float height = 0.0;
    
    switch (index) {
        case 0:
            width = self.largeCell;
            height = self.largeCell;
            break;
        default:
            width = self.mediumCell;
            height = self.mediumCell;
            break;
    }
    
    return CGRectMake(horizontalOffset, verticalOffset, width, height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[CellKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
}
@end
