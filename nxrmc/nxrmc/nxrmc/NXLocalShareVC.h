//
//  NXLocalShareVC.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXFileOperationPageBaseVC.h"
@class  NXFileBase;
typedef NS_ENUM(NSInteger,NXShareSelectRightsType) {
    NXShareSelectRightsTypeDigital,
    NXShareSelectRightsTypeClassification
};
@interface NXLocalShareVC : NXFileOperationPageBaseVC

@property(nonatomic, strong) NXFileBase *fileItem;
@property (nonatomic, assign)NXShareSelectRightsType currentType;

@end
