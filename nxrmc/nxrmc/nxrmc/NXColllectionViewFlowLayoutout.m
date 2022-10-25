//
//  NXColllectionViewFlowLayoutout.m
//  nxrmcUITest
//
//  Created by nextlabs on 11/11/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import "NXColllectionViewFlowLayoutout.h"

@implementation NXColllectionViewFlowLayoutout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *answer = [super layoutAttributesForElementsInRect:rect];
    
    if (answer.count) {
        UICollectionViewLayoutAttributes *temp = answer[0];
        CGRect frame = temp.frame;
        frame.origin.x = 0;
        
        CGFloat maxWidth = self.collectionViewContentSize.width - self.sectionInset.right - self.sectionInset.left;
        frame.size.width = frame.size.width > maxWidth ? maxWidth : frame.size.width;
        
        temp.frame = frame;
    }
    
    for(int i = 1; i < [answer count]; ++i) {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        
        if(origin + self.maximumInteritemSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width - self.sectionInset.right && currentLayoutAttributes.indexPath.row != 0) {
            //two cell's max space to work
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + _maximumInteritemSpacing;
            if (currentLayoutAttributes.frame.origin.y != prevLayoutAttributes.frame.origin.y) {
                frame.origin.x = 0;
            }
            currentLayoutAttributes.frame = frame;
        } else {
            //for first row in new row, just make it align left.
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = 0;
            currentLayoutAttributes.frame = frame;
        }
        //when itemsize.width is out of range of collectionview's bounds, just make item's width adjust the width
        if (currentLayoutAttributes.frame.size.width >= self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.size.width = self.collectionViewContentSize.width;
            currentLayoutAttributes.frame = frame;
        }
    }
    
    return answer;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    //TODO
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}

@end
