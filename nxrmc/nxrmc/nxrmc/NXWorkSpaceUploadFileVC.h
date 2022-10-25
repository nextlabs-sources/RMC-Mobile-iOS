//
//  NXWorkSpaceUploadFileVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/9/27.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXLocalProtectVC.h"


@class NXWorkSpaceFolder;
@interface NXWorkSpaceUploadFileVC : NXLocalProtectVC
@property(nonatomic, strong)NXWorkSpaceFolder *folder; //folder which will be uploaded;
@end


