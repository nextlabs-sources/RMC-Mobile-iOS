//
//  NXAddRepoPageCellModel.m
//  nxrmc
//
//  Created by nextlabs on 11/28/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXAddRepoPageCellModel.h"

#import "NXCommonUtils.h"

@implementation NXAddRepoPageCellModel

- (instancetype)initWithServiceType:(ServiceType)type {
    if (self = [super init]) {
        _type = type;
        [self commonInit];
    }
    return self;;
}

- (void)commonInit {
    NSString *str = [NXCommonUtils rmcToRMSRepoType:[NSNumber numberWithInteger:_type]];
    _title = [NXCommonUtils rmsToRMCDisplayName:str];
    
    switch (_type) {
        case kServiceOneDrive:
        {
            _imagename = @"onedrive - black";
        }
            break;
        case kServiceDropbox:
        {
            _imagename = @"dropbox - black";
        }
            break;
        case kServiceGoogleDrive:
        {
            _imagename = @"google-drive-color";
        }
            break;
        case kServiceSharepoint:
        {
            _imagename = @"sharepoint - black";
        }
            break;
        case kServiceSharepointOnline:
        {
            _imagename = @"sharepoint - black";
        }
            break;
        case kServiceBOX:
        {
            _imagename = @"box - black";
        }
            break;
        default:
            break;
    }
}
@end
