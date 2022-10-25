//
//  NXActionSheetItem.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 02/05/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXActionSheetItem.h"

@interface NXActionSheetItem()
@end

@implementation NXActionSheetItem

- (id)init
{
    self = [super init];
    
    if (self) {
        _subItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image subItems:(NSMutableArray *)subItems action:(NXActionSheetItemHandler)handler
{
    NXActionSheetItem *item = [[NXActionSheetItem alloc] init];
    
    item.title = title;
    item.image = image;
    item.subItems = subItems;
    item.action = handler;
    return item;
}
+(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image subItems:(NSMutableArray *)subItems andRightImage:(UIImage *)rightImage action:(NXActionSheetItemHandler)handler{
    NXActionSheetItem *item = [[NXActionSheetItem alloc] init];
    
    item.title = title;
    item.image = image;
    item.subItems = subItems;
    item.action = handler;
    item.rightImage = rightImage;
    return item;
    
}

@end
