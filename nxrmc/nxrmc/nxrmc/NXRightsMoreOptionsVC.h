//
//  NXRightsMoreOptionsVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/6/13.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXRightsCellModel;

typedef void(^AfterFinishedOptionBlock)(NSArray<NXRightsCellModel*> *modelArray);
@interface NXRightsMoreOptionsVC : UIViewController
@property (nonatomic, copy)AfterFinishedOptionBlock finishedOptionBlock;
@property(nonatomic, copy) NSArray <NXRightsCellModel *> *dataArray;
@end


