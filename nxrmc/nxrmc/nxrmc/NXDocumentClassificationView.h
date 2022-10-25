//
//  NXDocumentClassificationView.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 15/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXClassificationCategory;
@interface NXDocumentClassificationView : UIView
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)NSArray<NXClassificationCategory *> *documentClassicationsArray;
@end
