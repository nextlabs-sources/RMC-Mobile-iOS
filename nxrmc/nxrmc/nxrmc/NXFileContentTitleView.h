//
//  NXFileContentTitleView.h
//  nxrmc
//
//  Created by EShi on 11/10/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXFileContentTitleView : UIView
@property(nonatomic, strong) NSString *fileTitle;
@property(nonatomic, strong) NSString *fileRepoAlias;

- (instancetype)initWithFrame:(CGRect) frame title:(NSString *)title repoAlias:(NSString *)alias;
@end
