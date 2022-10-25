//
//  NXShareWithCell.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/1/9.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NXShareWithType){
    NXShareWithTypeUser = 0,
    NXShareWithTypeProject,
    NXShareWithTypeWorkSpace
};

typedef void(^DeleteBlock)(id sender);
@interface NXShareWithCell : UICollectionViewCell


//@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) NXShareWithType shareWithType;
@property(nonatomic, strong) id item;
@property(nonatomic, assign) BOOL enable;
@property(nonatomic, strong) DeleteBlock deleteBlock;

+ (CGSize)sizeForTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
