//
//  NXEmailCell.h
//  nxrmcUITest
//
//  Created by nextlabs on 11/10/16.
//  Copyright © 2016 zhuimengfuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DeleteBlock)(id sender);

@interface NXEmailCell : UICollectionViewCell

@property(nonatomic, weak, readonly) UIButton *errorButton;
@property(nonatomic, weak, readonly) UILabel *titleLabel;

@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) BOOL enable;
@property(nonatomic, strong) DeleteBlock deleteBlock;

+ (CGSize)sizeForTitle:(NSString *)title;

@end
