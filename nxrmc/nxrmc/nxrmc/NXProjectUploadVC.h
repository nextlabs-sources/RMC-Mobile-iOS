//
//  NXProjectUploadVC.h
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/3/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXLocalProtectVC.h"

#import "NXProject.h"

@interface NXProjectUploadVC : NXLocalProtectVC
@property(nonatomic, strong) NXProjectFolder *folder; //folder which will be uploaded;
@property(nonatomic, strong) NXProjectModel *project;
@property(nonatomic, strong) NSString *vcTitle;
@property(nonatomic, strong) NSString *btnTitle;

@end
