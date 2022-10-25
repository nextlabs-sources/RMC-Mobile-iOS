//
//  NXProtectedResultVC.h
//  nxrmc
//
//  Created by Sznag on 2020/12/28.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NXProtectedResultVC : UIViewController
@property(nonatomic, strong)NSArray *successFileArray;
@property(nonatomic, strong)NSArray *failFileArray;
@property(nonatomic, strong)NSArray *allFilesArray;
@property(nonatomic, strong)NSString *savePath;
@end

NS_ASSUME_NONNULL_END
