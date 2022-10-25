//
//  NXUploadFileVC.h
//  nxrmc
//
//  Created by Sznag on 2020/9/27.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class  NXFileBase;
@interface NXUploadFileVC : UIViewController
@property(nonatomic, strong)NXFileBase *currentFile;
@end

NS_ASSUME_NONNULL_END
