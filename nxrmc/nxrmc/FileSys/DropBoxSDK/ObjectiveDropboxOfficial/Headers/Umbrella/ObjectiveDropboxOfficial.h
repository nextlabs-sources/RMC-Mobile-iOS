///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Umbrella import for importing as a framework
///

#import "TargetConditionals.h"

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for ObjectiveDropboxOfficial.
FOUNDATION_EXPORT double ObjectiveDropboxOfficialVersionNumber;

//! Project version string for ObjectiveDropboxOfficial.
FOUNDATION_EXPORT const unsigned char ObjectiveDropboxOfficialVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import
// <ObjectiveDropboxOfficial/PublicHeader.h>

#import "DBSDKImportsShared.h"

#if TARGET_OS_IPHONE
#import "DBSDKImports-iOS.h"
#elif TARGET_OS_MAC
#import <ObjectiveDropboxOfficial/DBSDKImports-macOS.h>
#endif
