//
//  NXCommonUtils.m
//  nxrmc
//
//  Created by Kevin on 15/5/12.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXCommonUtils.h"
#import "NSString+Codec.h"

#import <CoreData/CoreData.h>
#import <string>
#import "NXLoginNavigationController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <netdb.h>


#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#ifdef APPLE_DEV_HD
#import "../nxrmc_hd/AppDelegate.h"
#else
#import "../nxrmc/AppDelegate.h"
#endif

#import "NXCacheManager.h"
#import "NXBoundService+CoreDataClass.h"
#import "NXRMCDef.h"
#import "NXRMCCommon.h"
#import "NXKeyChain.h"
#import "NXServiceOperation.h"
#import "NXOneDrive.h"
#import "NXSharePoint.h"
#import "NXSharepointOnline.h"
#import "NXSharePointFolder.h"
#import "NXDropBox.h"
#import "NXGoogleDrive.h"
#import "NXSkyDrmBox.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CommonCrypto/CommonCrypto.h>
#import "NSString+Codec.h"
#import "SSZipArchive.h"
#import "NXRepositorySysManager.h"
#import "NXSharePointFolder.h"
#import "NSData+zip.h"
#import "NXSharedWithMeFile.h"
#import "MagicalRecord.h"
#import "NXTimeServerManager.h"
#import "NXBox.h"
#import "NXSharedWorkspace.h"
#import "NXLProfile.h"
#import "NXLMetaData.h"
#import "NXSharedWithProjectFile.h"
#define FILETYPE_HSF            @"hoopsviewer/x-hsf"


static NSRegularExpression *regular = nil;

@implementation NXCommonUtils

//+ (UIView*) createWaitingView
//{
//    CGRect r = [UIScreen mainScreen].applicationFrame;
//    UIView* bg = [[UIView alloc] initWithFrame: r];
//    [bg setTag:8808];
//    
//    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    //  activityView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhiteLarge;
//    
//    activityView.frame = CGRectMake(r.size.width /2 - 15, r.size.height /2 - 15, 30.0f, 30.0f);
//    
//    UIImageView* waitingbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WaitingBk"]];
//    waitingbg.frame = CGRectMake(r.size.width/2 -30, r.size.height /2 - 30, 60, 60);
//    
//    [bg addSubview:waitingbg];
//    [bg addSubview:activityView];
//    
//    
//    [activityView startAnimating];
//    
//    return bg;
//    
//}
//
//+ (UIView*) createWaitingView:(CGFloat)sidelength {
//    CGRect r = [UIScreen mainScreen].applicationFrame;
//    CGRect frame = CGRectMake(r.size.width/2 - sidelength/2, r.size.height/2 - sidelength/2, sidelength, sidelength);
//    
//    UIView* bg = [[UIView alloc] initWithFrame:frame];
//    [bg setTag:8808];
//    
//    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    //  activityView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhiteLarge;
//    
//    activityView.frame = CGRectMake(0, 0, sidelength, sidelength);
//    
//    UIImageView* waitingbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WaitingBk"]];
//    waitingbg.frame = CGRectMake(0,0, sidelength, sidelength);
//    
//    [activityView startAnimating];
//    [bg addSubview:waitingbg];
//    [bg addSubview:activityView];
//    
//    return bg;
//}
//
//+ (UIView*) createWaitingViewWithCancel:(id)target selector:(SEL)selector inView:(UIView*)view
//{
//    UIView* bg = [[UIView alloc] init];
//    [bg setTag:8808];
//    bg.translatesAutoresizingMaskIntoConstraints = NO;
//    bg.backgroundColor = [UIColor clearColor];
//    
//    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    activityView.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    UIImageView* waitingbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WaitingBk"]];
//    waitingbg.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    //add subview
//    [bg addSubview:waitingbg];
//    [bg addSubview:activityView];
//    [view addSubview:bg];
//    
//    
//    // add cancel buttonr
//    UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btn setTitle:@"Cancel" forState:UIControlStateNormal];
//    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
//    [btn setBackgroundColor:[UIColor redColor]];
//    [bg addSubview:btn];
//    
//    //do auto layout
//    [self doAutoLayoutForWaitingView:view backgroundView:bg waitingBg:waitingbg activityView:activityView];
//    
//    //do auto layout for cancel button
//    btn.translatesAutoresizingMaskIntoConstraints = NO;
//    [bg addConstraint:[NSLayoutConstraint
//                       constraintWithItem:btn
//                       attribute:NSLayoutAttributeWidth
//                       relatedBy:NSLayoutRelationEqual
//                       toItem:nil
//                       attribute:NSLayoutAttributeNotAnAttribute
//                       multiplier:1
//                       constant:100]];
//    
//    [bg addConstraint:[NSLayoutConstraint
//                       constraintWithItem:btn
//                       attribute:NSLayoutAttributeHeight
//                       relatedBy:NSLayoutRelationEqual
//                       toItem:nil
//                       attribute:NSLayoutAttributeNotAnAttribute
//                       multiplier:1
//                       constant:30]];
//    [bg addConstraint:[NSLayoutConstraint
//                       constraintWithItem:btn
//                       attribute:NSLayoutAttributeCenterX
//                       relatedBy:NSLayoutRelationEqual
//                       toItem:bg
//                       attribute:NSLayoutAttributeCenterX
//                       multiplier:1
//                       constant:0]];
//    
//    [bg addConstraint:[NSLayoutConstraint
//                       constraintWithItem:btn
//                       attribute:NSLayoutAttributeTop
//                       relatedBy:NSLayoutRelationEqual
//                       toItem:waitingbg
//                       attribute:NSLayoutAttributeBottom
//                       multiplier:1
//                       constant:20]];
//    [activityView startAnimating];
//    
//    return bg;
//}

+(NSString *) currentRMSAddress
{
    NSString *RMSAddress = [[NSUserDefaults standardUserDefaults] objectForKey:NXRMS_ADDRESS_KEY];
    return (RMSAddress?RMSAddress:@"");
    
}
+(NSString *) currentTenant
{
    NSString *tenant = [[NSUserDefaults standardUserDefaults] objectForKey:NXRMS_TENANT_KEY];
    return (tenant?tenant:@"");

}

+(NSString *) currentSkyDrm
{
    NSString *skyDrm = [[NSUserDefaults standardUserDefaults] objectForKey:NXRMS_SKY_DRM_KEY];
    return (skyDrm?skyDrm:@"");
}
+(NSString *) currentBundleDisplayName
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentDisplayName = [infoDic objectForKey:@"CFBundleDisplayName"];
    return currentDisplayName;
    
}
+(void) updateRMSAddress:(NSString *) rmsAddress
{
    if (rmsAddress && ![rmsAddress isEqualToString:@""] && ![rmsAddress isEqualToString:[self currentRMSAddress]]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:rmsAddress forKey:NXRMS_ADDRESS_KEY];
    }
}
+(void) updateRMSTenant:(NSString *) tenant
{
    if (tenant && ![tenant isEqualToString:@""] && ![tenant isEqualToString:[self currentTenant]]) {

        [[NSUserDefaults standardUserDefaults] setObject:tenant forKey:NXRMS_TENANT_KEY];
    }
}

+(void) updateSkyDrm:(NSString *) skyDrmAddress
{
    if (skyDrmAddress && ![skyDrmAddress isEqualToString:@""] && ![skyDrmAddress isEqualToString:[self currentSkyDrm]]) {
         [self cleanUpTable:TABLE_BOUNDSERVICE];
         [self cleanUpTable:TABLE_CACHEFILE];
        
        NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSError *error = nil;
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]) {
            [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingPathComponent:file] error:&error];
        }

         [[NSUserDefaults standardUserDefaults] setObject:skyDrmAddress forKey:NXRMS_SKY_DRM_KEY];
    }
}

+ (void)forceUserLogout
{
    if ([[NXLoginUser sharedInstance] isLogInState]) {
        [self showAlertView:[NXCommonUtils currentBundleDisplayName] message:NSLocalizedString(@"UI_RMC_SESSION_OUTOFDATE", nil) style:UIAlertControllerStyleAlert OKActionTitle:@"OK" cancelActionTitle:nil OKActionHandle:^(UIAlertAction *action) {
            BOOL hasMarkingTask = [[NXOfflineFileManager sharedInstance] hasMarkingAsOfflinedFile];
            if (hasMarkingTask) {
                [[NXOfflineFileManager sharedInstance] cancelAllMarkTask];
                [[NXLoginUser sharedInstance] logOut];
            }else{
                [[NXLoginUser sharedInstance] logOut];
            }

            NXLoginNavigationController *nav = [[NXLoginNavigationController alloc] init];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        } cancelActionHandle:nil inViewController:[UIApplication sharedApplication].keyWindow.rootViewController position:nil];
    }
}


//+ (void) removeWaitingViewInView:(UIView *) view
//{
//    if ([view viewWithTag:8808]) {
//        [[view viewWithTag:8808] removeFromSuperview];
//    }
//}
//
//+(BOOL) waitingViewExistInView:(UIView *)view
//{
//    if([view viewWithTag:8808])
//    {
//        return YES;
//    }else
//    {
//        return NO;
//    }
//}

//+ (UIView*) createWaitingViewInView:(UIView*)view
//{
//    if ([view viewWithTag:8808]) {
//        return [view viewWithTag:8808];
//    }
//    
//    UIView* bg = [[UIView alloc] init];
//    [bg setTag:8808];
//    bg.translatesAutoresizingMaskIntoConstraints = NO;
//    bg.backgroundColor = [UIColor clearColor];
//    
//    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    activityView.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    UIImageView* waitingbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WaitingBk"]];
//    waitingbg.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    //add subview
//    [bg addSubview:waitingbg];
//    [bg addSubview:activityView];
//    [view addSubview:bg];
//    
//    //do autolay out
//    [self doAutoLayoutForWaitingView:view backgroundView:bg waitingBg:waitingbg activityView:activityView];
//    
//    //start animating
//    [activityView startAnimating];
//    
//    return bg;
//}

//barButtonItem only for iPad, other please pass nil.
+ (void)showAlertView:(NSString *)title
              message:(NSString *)message
                style:(UIAlertControllerStyle)style
        OKActionTitle:(NSString *)okTitle
    cancelActionTitle:(NSString*)cancelTitle
       OKActionHandle:(void (^ __nullable)(UIAlertAction *action))OKActionHandler
   cancelActionHandle:(void (^ __nullable)(UIAlertAction *action))cancelActionHandler
     inViewController:(UIViewController *)controller
             position:(id)sourceView;
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:style];
    if (cancelTitle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelActionHandler];
        [alertController addAction:cancelAction];
    }
    
    if (okTitle) {
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:OKActionHandler];
        [alertController addAction:OKAction];
    }
   
    if ([NXCommonUtils isiPad] && sourceView) {
        if ([sourceView isKindOfClass:[UIBarButtonItem class]]) {
            alertController.popoverPresentationController.barButtonItem = sourceView;
        }else {
            alertController.popoverPresentationController.sourceView = controller.view;
            alertController.popoverPresentationController.sourceRect = controller.view.bounds;
        }
    }
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertView:(NSString *)title
              message:(NSString *)message
                style:(UIAlertControllerStyle)style
        OKActionTitle:(NSString *)okTitle
    cancelActionTitle:(NSString*)cancelTitle
           otherTitle:(NSString *)otherTitle
       OKActionHandle:(void (^ __nullable)(UIAlertAction *action))OKActionHandler
   cancelActionHandle:(void (^ __nullable)(UIAlertAction *action))cancelActionHandler
    otherActionHandle:(void (^ __nullable)(UIAlertAction *action))otherActionHandler
     inViewController:(UIViewController *)controller
             position:(id)sourceView;
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:style];
    if (cancelTitle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelActionHandler];
        [alertController addAction:cancelAction];
    }
    
    if (otherTitle) {
          UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherTitle style:UIAlertActionStyleDestructive handler:otherActionHandler];
          [alertController addAction:otherAction];
    }
    
    if (okTitle) {
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:OKActionHandler];
        [alertController addAction:OKAction];
    }
   
    if ([NXCommonUtils isiPad] && sourceView) {
        if ([sourceView isKindOfClass:[UIBarButtonItem class]]) {
            alertController.popoverPresentationController.barButtonItem = sourceView;
        }else {
            alertController.popoverPresentationController.sourceView = controller.view;
            alertController.popoverPresentationController.sourceRect = controller.view.bounds;
        }
    }
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertView:(NSString *)title
              message:(NSString *)message
                style:(UIAlertControllerStyle)style
    cancelActionTitle:(NSString *)cancelTitle
    otherActionTitles:(NSArray *)otherTitles
     inViewController:(UIViewController *)controller
             position:(id)sourceView
             tapBlock:(void (^)(UIAlertAction *action, NSInteger index))tapBlock {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    if (cancelTitle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            if (tapBlock) {
                tapBlock(action, 0);
            }
        }];
        [alertController addAction:cancelAction];
    }
//
   
    for (NSUInteger i = 0; i < otherTitles.count; i++) {
        NSString *otherButtonTitle = otherTitles[i];
        
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (tapBlock) {
                tapBlock(action, 1 + i);
            }
        }];
        [alertController addAction:otherAction];
    }
    if ([NXCommonUtils isiPad] &&sourceView) {
        if ([sourceView isKindOfClass:[UIBarButtonItem class]]) {
          alertController.popoverPresentationController.barButtonItem = sourceView;
        }else {
           alertController.popoverPresentationController.sourceView = controller.view;
            alertController.popoverPresentationController.sourceRect = controller.view.bounds;
        }
    }
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (NSString *)addIndexForFile:(NSUInteger)index fileName:(NSString *)fileName
{
    if (!fileName) {
        return nil;
    }
    NSString *name = fileName;
    if ([fileName.lastPathComponent containsString:@".nxl"]) {
        name = fileName.stringByDeletingPathExtension;
    }
    NSString *suffix = name.pathExtension;
    NSString *fileNameWithoutSuffix = [name stringByDeletingPathExtension];
    NSString *newName = [NSString stringWithFormat:@"%@(%lu).%@",fileNameWithoutSuffix,(unsigned long)index,suffix];
    
   if ([fileName.lastPathComponent containsString:@".nxl"]) {
       newName = [newName stringByAppendingString:@".nxl"];
   }
    return newName;
}

+ (NSUInteger)getMaxIndexForFile:(NSString *)fileName fileNameArray:(NSArray *)fileNameArr;
{
    if (!fileNameArr || fileNameArr.count == 0) {
        return 0;
    }
    
    NSUInteger index = 0;
    NSString *noNXLSuffixFileName = @"";
       NSString *fileNameWithoutSuffix = @"";
    if ([fileName hasSuffix:@".nxl"]) {
        noNXLSuffixFileName = fileName.stringByDeletingPathExtension;
        fileNameWithoutSuffix = [noNXLSuffixFileName stringByDeletingPathExtension];
    }else{
        noNXLSuffixFileName = fileName;
        fileNameWithoutSuffix = [fileName stringByDeletingPathExtension];
    }
   
    for (NSString *tmpFile in fileNameArr) {
        NSString *noNXLArrayfileName = tmpFile.stringByDeletingPathExtension;
        NSString *noSuffixArrayFileName = noNXLArrayfileName.stringByDeletingPathExtension;
        if ([noSuffixArrayFileName hasPrefix:[NSString stringWithFormat:@"%@(",fileNameWithoutSuffix]] && [noSuffixArrayFileName hasSuffix:@")"] && [noNXLSuffixFileName.pathExtension isEqualToString:noNXLArrayfileName.pathExtension]) {
            NSArray *array = [noSuffixArrayFileName componentsSeparatedByString:[NSString stringWithFormat:@"%@(",fileNameWithoutSuffix]];
            NSString *tailName = [array lastObject];
            NSArray *array2 = [tailName componentsSeparatedByString:@")"];
            NSString *middleCharacter = [array2 firstObject];
            BOOL isNumber = NO;
            if (middleCharacter.length == 0) {
                isNumber = NO;
             }
           NSString *regex = @"[0-9]*";
           NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
           if ([pred evaluateWithObject:middleCharacter]) {
               isNumber = YES;
           }else{
               isNumber = NO;
           }
            if (isNumber) {
                if (middleCharacter.integerValue > index) {
                    index = middleCharacter.integerValue;
                }
            }
        }
        
    }
    return index;
}

+ (BOOL)isValidateEmail:(NSString *)email
{
    if (!email.length) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    
    return [emailTest evaluateWithObject:email];
}
+ (BOOL)isValidateURL:(NSString *)URL {
    NSError *error;
    // 正则1
//    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSString *regulaStr = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:URL options:0 range:NSMakeRange(0, [URL length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches){
        NSString * substringForMatch = [URL substringWithRange:match.range];
        if (substringForMatch) {
            return YES;
        }
        return NO;
    }
    return NO;
}

+ (void) cleanUpTable:(NSString *) tableName
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        Class tableClass = NSClassFromString(tableName);
        SEL selector = NSSelectorFromString(@"MR_truncateAllInContext:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [tableClass performSelector:selector withObject:localContext];
#pragma clang diagnostic pop
    }];
}

+ (void) deleteCachedFilesOnDisk
{
    //only delete cached files in ../Library/Cachees/rms_sid
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
     NSString *uid = [[NSString alloc] initWithFormat:@"%@_%@", [NXLoginUser sharedInstance].profile.individualMembership.tenantId, [NXLoginUser sharedInstance].profile.userId];
    NSString *cachePath = [cacheUrl URLByAppendingPathComponent:uid].path;
    [self deleteFilesAtPath:cachePath];
    
//    //delete cache file in Application_Home/tmp
//    NSURL *tmpPath = [NSURL URLWithString:NSTemporaryDirectory()];
//    [self removeAllFilesAtPath:tmpPath.path];
    
    // delele db  in db.
    [NXCacheFileStorage deleteAllCacheFilesFromCoreData];
}

+ (void) deleteFilesAtPath:(NSString *) directory
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL ret = [fileManager removeItemAtPath:directory error:nil];
    if (!ret) {
        NSLog(@"delete %@ failed", directory);
    }
}

+ (NSNumber *) calculateCachedFileSize {
    //only caculate dirctory ../Library/Cachees/rms_sid
    NSURL *cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *uid = [[NSString alloc] initWithFormat:@"%@_%@", [NXLoginUser sharedInstance].profile.individualMembership.tenantId, [NXLoginUser sharedInstance].profile.userId];
    NSString *cachePath = [cacheUrl URLByAppendingPathComponent:uid].path;
    NSNumber *cacheSize = [self calculateCachedFileSizeAtPath:cachePath];
    
      //cached files in Application_Home/tmp
//    NSURL *tmpPath = [NSURL URLWithString:NSTemporaryDirectory()];
//    cacheSize = @([cacheSize unsignedLongLongValue] + [self calculateCacheSizeAtPath:tmpPath.path].unsignedLongLongValue);
    
    return cacheSize;
}

+ (NSNumber *) calculateCachedFileSizeAtPath:(NSString *)folderPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSNumber *folderSize = [NSNumber numberWithUnsignedLongLong:0];
    
    NSArray* array = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
    for(int i = 0; i < array.count; i++)
    {
        NSString *fullPath = [folderPath stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
            folderSize = [NSNumber numberWithUnsignedLongLong:[folderSize unsignedLongLongValue] + fileAttributeDic.fileSize];
        }
        else
        {
            folderSize = [NSNumber numberWithUnsignedLongLong:[folderSize unsignedLongLongValue] + [[self calculateCachedFileSizeAtPath:fullPath] unsignedLongLongValue]];
        }
    }
    return folderSize;
}







+ (NSArray*) getStoredProfiles
{
    NSMutableDictionary* dict = [NXKeyChain load:KEYCHAIN_PROFILES_SERVICE];  // get info from key chain
    NSData* data = [dict objectForKey:KEYCHAIN_PROFILES];  // get stored value, this is binary data of all profiles
    NSArray* profiles = [NSKeyedUnarchiver unarchiveObjectWithData:data];  // unarchive
    
    NSMutableArray* ary = [NSMutableArray array];
    for (NXLProfile* profile in profiles) {
//        NSLog(@"uname: %@, domain: %@, sid: %@, rmserver: %@", profile.userName, profile.domain, profile.sid, profile.rmserver);
        
        [ary addObject:profile];
    }
    
    return ary;
    
}

+ (void) storeProfile:(NXLProfile *)profile
{
    if (!profile) {
        return;
    }
    
    NSArray *newProfiles = @[profile];
//    NSArray* profiles = [NXCommonUtils getStoredProfiles];  // get existing profiles
//    NSMutableArray* newProfiles = [NSMutableArray arrayWithArray:profiles];
//    for (NXLProfile* p in newProfiles) {
//        if ([p equalProfile:profile]) {
//            [newProfiles removeObject:p];
//            break;
//        }
//    }
//    
//    [newProfiles insertObject:profile atIndex:0];  // add new profile
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:newProfiles];  // archive all profiles
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:data forKey:KEYCHAIN_PROFILES];
    
    [NXKeyChain save:KEYCHAIN_PROFILES_SERVICE data:dict];
}

+ (void) deleteProfile:(NXLProfile*)profile {
    if (!profile) {
        return;
    }
//    NSArray* profiles = [NXCommonUtils getStoredProfiles];
//    NSMutableArray* newProfiles = [NSMutableArray arrayWithArray:profiles];
//    
//    for (NXLProfile*p in newProfiles) {
//        if ([p equalProfile:profile]) {
//            [newProfiles removeObject:p];
//            break;
//        }
//    }
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:@[]];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:data forKey:KEYCHAIN_PROFILES];
    
    [NXKeyChain save:KEYCHAIN_PROFILES_SERVICE data:dict];
}




+ (id<NXServiceOperation>)getServiceOperation:(NXFileBase *)item {
    return [self getServiceOperationFromRepoItem:[[NXLoginUser sharedInstance].myRepoSystem getRepositoryModelByFileItem:item]];
}

+ (id<NXServiceOperation>)getServiceOperationFromRepoItem:(NXRepositoryModel *)repo
{
    id<NXServiceOperation> so = nil;
    if (repo.service_type) {  // add check repo.service_type for the service may deleted, if is deleted, service.service_type = nil, [nil intvalue] = 0
        switch ([repo.service_type intValue]) {
            case kServiceDropbox:
                so = [[NXDropBox alloc] initWithUserId:repo.service_account_id repoModel:repo];
                break;
            case kServiceOneDrive:
                so = [[NXOneDrive alloc]initWithUserId:repo.service_account_id repoModel:repo];
                break;
            case kServiceSharepoint:
                so = [[NXSharePoint alloc] initWithUserId:repo.service_account_id repoModel:repo];
                break;
            case kServiceSharepointOnline:
            {
                if ([repo.service_providerClass isEqualToString:@"APPLICATION"]) {
                    so = [[NXSharedWorkspace alloc] initWithUserId:repo.service_account_id repoModel:repo];
                }else{
                    so = [[NXSharepointOnline alloc] initWithUserId:repo.service_account_id repoModel:repo];
                }
            }
                break;
            case kServiceGoogleDrive:
                so = [[NXGoogleDrive alloc] initWithUserId:repo.service_account_id repoModel:repo];
                break;
            case kServiceSkyDrmBox:
                so = [[NXSkyDrmBox alloc] initWithUserId:repo.service_account_id repoModel:repo];
                break;
            case kServiceBOX:
                so = [[NXBox alloc] initWithUserId:repo.service_account_id repoModel:repo];
                break;
            case kServiceOneDriveApplication:
                so = [[NXSharedWorkspace alloc] initWithUserId:repo.service_account_id repoModel:repo];
                break;
            case KServiceSharepointOnlineApplication:
                so = [[NXSharedWorkspace alloc] initWithUserId:repo.service_account_id repoModel:repo];
            default:
                break;
        }
        [so setAlias:repo.service_alias];
       // [so setBoundService:service];
        
    }
    return so;

}

+ (NXFileBase*) storeThirdPartyFileAndGetNXFile:(NSURL*)fileURL
{

    // TBD!!!!!!!!!!!!!!!
    
    
    return nil;
}





+ (NSString*) getMiMeType:(NSString*)filepath
{
    if (filepath == nil) {
        return nil;
    }
    
    NSString *fileExtension = [NXCommonUtils getExtension:filepath error:nil];
    if (fileExtension == nil) {
        return nil;
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *mimeTypeStr = (__bridge_transfer NSString *)mimeType;
    if (mimeTypeStr == nil) {
        if([fileExtension compare:@"java" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return @"text/x-java-source";
        }
        NSString *extentensionText = @"cpp, c, h, m, log, swift, vb, md, properties,";
        NSRange foundOjb = [extentensionText rangeOfString:fileExtension options:NSCaseInsensitiveSearch];
        if (foundOjb.length > 0) {
            return @"text/plain";
        }
        return @"application/octet-stream";
    }
    return mimeTypeStr;
}

+ (NSString *) getMimeTypeByFileName:(NSString *)fileName
{
    if (fileName == nil) {
        return nil;
    }
    
    NSString *fileExtension = [fileName componentsSeparatedByString:@"."].lastObject;
    if (fileExtension == nil) {
        return nil;
    }
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *mimeTypeStr = (__bridge_transfer NSString *)mimeType;
    if (mimeTypeStr == nil) {
        if([fileExtension compare:@"java" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return @"text/x-java-source";
        }
        NSString *extentensionText = @"cpp, c, h, m, log, swift, vb, md,";
        NSRange foundOjb = [extentensionText rangeOfString:fileExtension options:NSCaseInsensitiveSearch];
        if (foundOjb.length > 0) {
            return @"text/plain";
        }
        return @"application/octet-stream";
    }
    return mimeTypeStr;
}

+ (NSString*) getUTIForFile :(NSString*) filepath
{
    if (filepath == nil) {
        return  nil;
    }
    NSString *extension = [self getExtension:filepath error:nil];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    return (__bridge_transfer NSString *)UTI;
}

+ (NSString *)getExtension:(NSString *)fullpath error:(NSError **)error;
{
    if (fullpath == nil) {
        if (error) {
            *error = [NSError errorWithDomain:NX_ERROR_NXLFILE_DOMAIN  code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:nil];
        }
        return  nil;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
        if (error) {
            *error = [NSError errorWithDomain:NX_ERROR_NXLFILE_DOMAIN  code:NXRMC_ERROR_CODE_NOSUCHFILE userInfo:nil];
        }
        return nil;
    }
    if ([NXLMetaData isNxlFile:fullpath]) {
        __block NSString *fileType = @"";
        __block NSError *tempError = nil;
        dispatch_semaphore_t semi = dispatch_semaphore_create(0);
        [NXLMetaData getFileType:fullpath clientProfile:[NXLoginUser sharedInstance].profile sharedInfo:nil complete:^(NSString *type, NSError *error) {
            fileType = type;
            tempError = error;
            dispatch_semaphore_signal(semi);
        }];
        dispatch_semaphore_wait(semi, DISPATCH_TIME_FOREVER);
        if (tempError && error) {
            *error = [NSError errorWithDomain:tempError.domain code:tempError.code userInfo:tempError.userInfo];
        }
        if ([fileType containsString:@"-"]) {
            fileType = [fileType componentsSeparatedByString:@"-"].firstObject;
        }
        return fileType;
    } else {
        NSString *fileType = [[fullpath pathExtension] lowercaseString];
        if ([fileType containsString:@"-"]) {
            fileType = [fileType componentsSeparatedByString:@"-"].firstObject;
        }
        return fileType;
    }
}


+ (NSString *) arrayToJsonString:(NSArray *)array error:(NSError **)error
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:error];
    if (!jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (NSString *)getFileExtensionByFileName:(NXFileBase *)file
{
    NSString *fileExtension = file.name.pathExtension;
    if (!fileExtension || fileExtension.length == 0) {
        fileExtension = file.localPath.pathExtension;
    }
    
    if ([fileExtension compare:NXL options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        fileExtension = [file.name stringByDeletingPathExtension].pathExtension;
    }
    if ([fileExtension containsString:@"-"]) {
        fileExtension = [fileExtension componentsSeparatedByString:@"-"].firstObject;
    }
    return fileExtension;
}

+(NSString *) convertToCCTimeFormat:(NSDate *) date
{
    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.sssZZ"];
        NSMutableString *timestamp = [NSMutableString stringWithString:[dateFormatter stringFromDate:date]];
        [timestamp insertString:@":" atIndex:(timestamp.length - 2)];
        return timestamp;
    }
    return nil;
}

+ (NSString *) convertRepoTypeToDisplayName:(NSNumber *) repoType
{
    if (repoType) {
        NSDictionary *dic = @{[NSNumber numberWithInteger:kServiceDropbox]:@"Dropbox",
                              [NSNumber numberWithInteger:kServiceSharepointOnline]:@"SharePointOnline",
                              [NSNumber numberWithInteger:kServiceSharepoint]:@"SharePoint",
                              [NSNumber numberWithInteger:kServiceOneDrive]:@"OneDrive",
                              [NSNumber numberWithInteger:kServiceGoogleDrive]:@"Google Drive",
                              [NSNumber numberWithInteger:kServiceSkyDrmBox] : @"MySpace",
                              [NSNumber numberWithInteger:kServiceBOX] : @"Box",
                              [NSNumber numberWithInteger:kServiceOneDriveApplication] : @"OneDrive",
                              [NSNumber numberWithInteger:KServiceSharepointOnlineApplication] : @"SharePointOnline"
                              };
        return dic[repoType];
    }
    return @"";
}

// need to add more file type
+ (BOOL) is3DFileWithMimeType:(NSString*)mimeType
{
    if(mimeType == nil)
    {
        return NO;
    }
    if([mimeType isEqualToString:FILETYPE_HSF] )
    {
        return YES;
    }
    return NO;
}

//
+ (BOOL) is3DFileFormat:(NSString*)extension
{
    if(extension == nil) {
        return NO;
    }
    
    if ([extension compare:FILEEXTENSION_HSF options:NSCaseInsensitiveSearch] == NSOrderedSame ||
        [extension compare:FILEEXTENSION_VDS options:NSCaseInsensitiveSearch] == NSOrderedSame ||
        [extension compare:FILEEXTENSION_RH options:NSCaseInsensitiveSearch] == NSOrderedSame )
    {
        return YES;
    }else if ([self is3DFileNeedConvertFormat:extension]) {
        return YES;
    }else if ([self isHOOPSFileFormat:extension]) {
        return YES;
    }
    return NO;
}
// according to the file type or other file information,judge this 3D format if need convert by service
+ (BOOL) is3DFileNeedConvertFormat:(NSString*)extension
{
    if(extension == nil)
    {
        return NO;
    }
    NSArray *supportedCadformats = @[@".prt", @".sldprt", @".sldasm",@".catpart", @".catshape", @".cgr",@".neu",
                                     @".par", @".psm", @".pdf", @".ipt", @".3dxml", @".wrl", @".3mf", @".sat", @".CATDrawing", @".dae", @".fbx", @".gltf", @".rvt", @".rfa", @".3dm", @".vda", @".glb",@".sab",@".xpr",@".mf1",@".vrml"];
    
    for (NSString *format in supportedCadformats) {
        if ([format compare:[NSString stringWithFormat:@".%@", extension] options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL) isHOOPSFileFormat:(NSString *)extension {
    NSString *hoopsSupportFileTypes = FILE_HOOPS_SUPPORT;
    NSRange foundOjb = [hoopsSupportFileTypes rangeOfString:[NSString stringWithFormat:@".%@.",extension] options:NSCaseInsensitiveSearch];
    if (foundOjb.length > 0) {
        return YES;
    }else {
        return NO;
    }
}

// judge our app if suppport this format,now just accorind to the mimetype,in futere can change the implemetion
+ (BOOL)isTheSupportedFormat:(NSString*)extension
{
    if(extension == nil) {
        NO;
    }
    
    NSString *supportFileTypes = FILESUPPORTOPEN;
    NSRange foundOjb = [supportFileTypes rangeOfString:[NSString stringWithFormat:@".%@.",extension] options:NSCaseInsensitiveSearch];
    if (foundOjb.length > 0) {
        return YES;
    }
    if ([self is3DFileNeedConvertFormat:extension]) {
        return YES;
    }
    if ([self isRemoteViewSupportFormat:extension]) {
        return YES;
    }
    return NO;
}

+ (BOOL) isRemoteViewSupportFormat:(NSString *)extension
{
    if (extension == nil) {
        return NO;
    }
    NSString *supportFileTypes = FILEREMOTEVIEWSUPPORTOPEN;
    NSRange foundOjb = [supportFileTypes rangeOfString:[NSString stringWithFormat:@".%@.",extension] options:NSCaseInsensitiveSearch];
    if (foundOjb.length > 0) {
        return YES;
    }
    return NO;
}

+ (BOOL) isOfflineViewSupportFormat:(NXFileBase *)file
{
    // check is supported offline file format
    NSString *fileExtension = [NXCommonUtils getFileExtensionByFileName:file];
    if ([NXCommonUtils isRemoteViewSupportFormat:fileExtension] || [self is3DFileNeedConvertFormat:fileExtension] || ![NXCommonUtils isTheSupportedFormat:fileExtension]) {
        BOOL result = [fileExtension caseInsensitiveCompare:@"pdf"] == NSOrderedSame;
        if (result) {
            return YES;
        }
        return NO;
    }
    return YES;
}

+ (float) iosVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];;
}

+ (BOOL) isiPad
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

+ (NSString *) deviceID
{
    NSString *deviceID = (NSString *)[NXKeyChain load:KEYCHAIN_DEVICE_ID];
    if (deviceID == nil) {
        deviceID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [NXKeyChain save:KEYCHAIN_DEVICE_ID data:deviceID];
    }
   
    return deviceID;
}

+ (NSNumber*) getPlatformId
{
    long idStart = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        idStart = 600;
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        idStart = 700;
    }
    else
    {
        idStart = 600;
    }
    
    long plus = 0;
    NSString* v = [UIDevice currentDevice].systemVersion;
    NSString *mainVersionStr = [v componentsSeparatedByString:@"."].firstObject;
    if (mainVersionStr) {
        NSInteger mainVersionNum = mainVersionStr.integerValue;
        if (mainVersionNum != 0) {
            NSInteger baseNum = 4;
            plus = mainVersionNum - baseNum;
        }
    }

    return [NSNumber numberWithLong:(idStart + plus)];
}


+ (void)showAlertViewInViewController:(UIViewController*)vc title:(NSString*)title message:(NSString*)message
{
   
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL)
                                                               style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:cancelAction];
        
        [vc presentViewController:alertController animated:YES completion:nil];
    
}

+ (CGRect) getScreenBounds
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
    }
    return screenBounds;
}



+ (NSDictionary*) parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableArray *info = [NSMutableArray arrayWithArray:pairs];
    [info removeObjectAtIndex:0];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in info) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1] stringByRemovingPercentEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

+ (NSString*) randomStringwithLength:(NSUInteger)length
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123467890";
    NSMutableString *randomStr = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < length; ++i) {
        u_int32_t r = arc4random() % alphabet.length;
        unichar c = [alphabet characterAtIndex:r];
        [randomStr appendFormat:@"%C",c];
    }
    return [NSString stringWithString:randomStr];
}

+ (NSString*) getConvertFileTempPath
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"nxrmcTmp"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // folder is not exist,so create a new folder
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

/**
 *  clean temp file,like the file after encrypt and convert for 3D files
 */
+ (void)cleanTempFile
{
    NSString *tmppath = [NXCommonUtils getConvertFileTempPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:tmppath error:nil];
    for(NSString* file in files)
    {
        [fileManager removeItemAtPath:[tmppath stringByAppendingPathComponent:file] error:nil];
    }
}


+ (NSString*) md5Data:(NSData *)data
{    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( data.bytes, (int)data.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *) getRmServer
{
    NSString *rmserver = [[NSUserDefaults standardUserDefaults] stringForKey:@"rmserver"];
    return rmserver;
}

+ (void) saveRmserver:(NSString *)rmserver
{
    [[NSUserDefaults standardUserDefaults] setObject:rmserver forKey:@"rmserver"];
}

+ (void)saveLoggerURL:(NSString *)loggerURL {
    [[NSUserDefaults standardUserDefaults] setObject:loggerURL forKey:@"logger-server"];
}

+ (NSString *)getLoggerURL {
    NSString *loggerURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"logger-server"];
    return loggerURL;
}

+ (void)saveLoggerToken:(NSString *)loggerToken {
    [[NSUserDefaults standardUserDefaults] setObject:loggerToken forKey:@"logger-token"];
}

+ (NSString *)loadLoggerToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"logger-token"];
}

+ (BOOL) isFirstTimeLaunching
{
    NSString *prevStartupVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"prevStartupVersion"];
    if (prevStartupVersion) {
        NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        if (![prevStartupVersion isEqualToString:currentVersion]) {
            [self saveFirstTimeLaunchSymbol];
            return YES;
        }else{
             return NO;
        }
    } else {
        [self saveFirstTimeLaunchSymbol];
        return YES;
    }
    return NO;
}

+ (void) saveFirstTimeLaunchSymbol
{
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"prevStartupVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) unUnarchiverCacheDirectoryData:(NXFileBase *) rootFolder {
    if (!rootFolder.isRoot) {
        return;
    }
    rootFolder.favoriteFileList = [[NXCustomFileList alloc] init];
    rootFolder.offlineFileList = [[NXCustomFileList alloc] init];
    for (NXFileBase *file in [rootFolder getChildren]) {
        [NXCommonUtils unUnarchiverAllNodes:file];
    }
}

+ (void)unUnarchiverAllNodes:(NXFileBase *) file {
    if (file.isFavorite) {
        [[file ancestor].favoriteFileList addNode:file];
    }
    if (file.isOffline) {
        [[file ancestor].offlineFileList addNode:file];
    }
    for (NXFileBase *child in [file getChildren]) {
        [NXCommonUtils unUnarchiverAllNodes:child];
    }
}

+ (NXFileBase*)fetchFileInfofromThirdParty:(NSURL*)fileURL
{
    NXFile *file = [[NXFile alloc] init];
    file.name = fileURL.lastPathComponent;
    
    if ([file.name containsString:@".nxl"]) {
        NSString *fileName = [NSString stringWithFormat:@"%@",[file.name stringByDeletingPathExtension]];
        NSString *fileExtension = [fileName pathExtension];
        if ([fileExtension containsString:@"-"]) {
            NSArray *sep = [fileExtension componentsSeparatedByString:@"-"];
            fileExtension = [sep firstObject];
        }
        
        fileName = [fileName stringByDeletingPathExtension];
        fileName = [fileName stringByAppendingPathExtension:fileExtension];
        fileName = [fileName stringByAppendingPathExtension:NXL];
        file.name = fileName;
    }

    NSError *error;
    NSDictionary *fileAttributs = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:&error];
    if (fileAttributs) {
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[fileAttributs fileModificationDate]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterFullStyle];
        file.isRoot = NO;
        file.lastModifiedTime = dateString;
        file.lastModifiedDate = [fileAttributs fileModificationDate];
        file.size = [fileAttributs fileSize];
        file.fullPath = [NSString stringWithFormat:@"%@/%@", @"/Inbox", fileURL.lastPathComponent];
        file.localPath = fileURL.path;
        ;
    }
    file.fullServicePath = fileURL.path;
    file.localPath = fileURL.path;
    file.sorceType = NXFileBaseSorceType3rdOpenIn;
    
    return file;
 }

+ (NXFileBase*)fetchFileInfofromUniversalLinksWithTransactionCode:(NSString *)transactionCode transactionId:(NSString *)transactionId
{
    NXSharedWithMeFile *file = [[NXSharedWithMeFile alloc] init];
    
    NSString *transCodeMD5 = [[NSString alloc] initWithFormat:@"%@",[transactionCode MD5]];
    NSString *transIdMD5 = [[NSString alloc] initWithFormat:@"%@",[transactionId MD5]];
    
    NSString *fullServicePath = [transCodeMD5 stringByAppendingString:transIdMD5];
    
    file.isRoot = NO;
    file.name = @"";
    file.transactionCode = transactionCode;
    file.transactionId = transactionId;
    file.fullServicePath = fullServicePath;
    file.sorceType = NXFileBaseSorceTypeShareWithMe;
    
    return file;
}

+ (NSString *)createNewNxlTempFile:(NSString *)filename {
    NSString *tmpPath = NSTemporaryDirectory();
    tmpPath = [tmpPath stringByAppendingPathComponent:filename];
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"-yyyy-MM-dd-hh-mm-ss"];
    
  //  NSString *datestr = [NSString stringWithString:[dateFormatter stringFromDate:[NXTimeServerManager sharedInstance].currentServerTime]];
    NSString *extension = [tmpPath pathExtension];
    
    tmpPath = [tmpPath stringByDeletingPathExtension];
    tmpPath = [NSString stringWithFormat:@"%@.%@%@", tmpPath, extension, @".nxl"];
    return tmpPath;
}

+ (NSString *) getTempNXLFilePath:(NSString *) fileName
{
    NSString *tempFilePath = nil;
    if (fileName) {
        tempFilePath  = [self getNXLTempFolderPath];
        tempFilePath = [tempFilePath stringByAppendingPathComponent:fileName];
        tempFilePath = [tempFilePath stringByAppendingString:NXLFILEEXTENSION];
    }
    return tempFilePath;
}

+ (NSString *)getNXLFileOriginalName:(NSString *)NXLFileName
{
    if (!NXLFileName) {
        return nil;
    }
    
    NSString *extension = [NXLFileName pathExtension];
    NSString *markExtension = [NSString stringWithFormat:@".%@", extension];
    if ([markExtension compare:NXLFILEEXTENSION options:NSCaseInsensitiveSearch] == NSOrderedSame) {
    } else {
        return NXLFileName;
    }
    
    NSString *fileName = [NXLFileName componentsSeparatedByString:@".nxl"].firstObject;
    // Now remove the timestamp
//    NSString *fileType = [fileName componentsSeparatedByString:@"."].lastObject;
//    fileName = [NXLFileName componentsSeparatedByString:[NSString stringWithFormat:@".%@",fileType]].firstObject;
//    fileName = [fileName substringToIndex:fileName.length - NXLFILE_FIXED_TIMESTAMP_LENGTH];
//    fileName = [fileName stringByAppendingString:[NSString stringWithFormat:@".%@",fileType]];
    return fileName;
}

+ (NSString *)getMyVaultFilePathBy3rdOpenInFileLocalPath:(NSString *)localPath
{
    if (!localPath) {
        return nil;
    }
    NSString *filePath = nil;
    NSURL *fileURL = [NSURL URLWithString:localPath];
    NSString *nxlfileName = nil;
    if (!fileURL) {
        nxlfileName = [localPath componentsSeparatedByString:@"openedIn/"].lastObject;
    }else{
        nxlfileName = fileURL.lastPathComponent;
    }
  
    if ([nxlfileName containsString:@".nxl"]) {
        NSString *fileName = [NSString stringWithFormat:@"%@",[nxlfileName stringByDeletingPathExtension]];
        NSString *fileExtension = [fileName pathExtension];
        if ([fileExtension containsString:@"-"]) {
            NSArray *sep = [fileExtension componentsSeparatedByString:@"-"];
            fileExtension = [sep firstObject];
        }
        
        fileName = [fileName stringByDeletingPathExtension];
        fileName = [fileName stringByAppendingPathExtension:fileExtension];
        fileName = [fileName stringByAppendingPathExtension:NXL];
        filePath = [NSString stringWithFormat:@"/%@",fileName];
    }
    return filePath;
}

+ (NSString*) getNXLTempFolderPath
{
    NSString *path = [NSTemporaryDirectory()stringByAppendingPathComponent:@"nxTmp"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // folder is not exist,so create a new folder
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+(NSString *) getServiceFolderKeyForFolderDirectory:(NXBoundService *) boundService
{
     return [NSString stringWithFormat:@"%@%@%@", boundService.service_type, NXDIVKEY, boundService.service_account_id];
}

+(NSError *) getNXErrorFromErrorCode:(NXRMC_ERROR_CODE) NXErrorCode error:(NSError *)error
{
    NSError *retError = nil;
    NSDictionary *userInfoDict = nil;
    NSString *localStr = nil;
    NSString *errorDomain = nil;
    if (NXErrorCode == NXRMC_ERROR_NO_NETWORK) {
       localStr = [NSString stringWithFormat:@"(%ld)", (long)NXErrorCode];
       errorDomain = NX_ERROR_NETWORK_DOMAIN;

    }else if(NXErrorCode == NXRMC_ERROR_CODE_TRANS_BYTES_FAILED)
    {
        localStr = [NSString stringWithFormat:@"(%ld)", (long)error.code];
        errorDomain = NX_ERROR_SERVICEDOMAIN;
    }
    else
    {
        localStr = [NSString stringWithFormat:@"(%ld)", (long)NXErrorCode];
        errorDomain = NX_ERROR_SERVICEDOMAIN;
    }
    
    switch (NXErrorCode) {
        case NXRMC_ERROR_CODE_NOSUCHFILE:
        {
            localStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"MSG_NO_SUCH_FILE", nil)];
        }
            break;
        case NXRMC_ERROR_CODE_AUTHFAILED:
        {
            localStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"MSG_USER_UNAUTHENED", nil)];
        }
            break;
        case NXRMC_ERROR_CODE_CONVERTFILEFAILED:
        {
            localStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"MSG_CONVERT_FILE_FAIL", nil)];
        }
            break;
        case NXRMC_ERROR_CODE_CONVERTFILE_CHECKSUM_NOTMATCHED:
        {
            localStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"MSG_CONVERTFILE_CHECKSUM_NOTMATCHED", nil)];
        }
            break;
        case NXRMC_ERROR_SERVICE_ACCESS_UNAUTHORIZED:
        {
            localStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"MSG_ACCESS_REPO_UNAUTHORIZED", nil)];
        }
            break;
        case NXRMC_ERROR_NO_NETWORK:
        {
            localStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"ERROR_NO_NETWORK_DESC", nil)];
        }
            break;
        case NXRMC_ERROR_CODE_TRANS_BYTES_FAILED:
        {
            localStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"MSG_NETWORK_UNUSABLE", nil)];
        }
            break;
        default:
            break;
    }
    
    userInfoDict = @{NSLocalizedDescriptionKey:localStr};
    retError = [NSError errorWithDomain:errorDomain code:NXErrorCode userInfo:userInfoDict];
    return retError;
}

+(NSString *)getImagebyExtension:(NSString *)fullPath {
    NSString *markExtension = [NSString stringWithFormat:@".%@.", [fullPath pathExtension]];

    NSString *wordString = @".docx.docm.doc.dotx.dotm.dot.";
    NSString *pptString = @".pptx.pptm.ppt.potx.potm.pot.ppsx.ppsm.pps.ppam.ppa.";
    NSString *excelString = @".xlsx.xlsb.xls.xltx.xltm.xlt.xlam.";

    BOOL isNormal = YES;
    if ([markExtension compare:@".nxl." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        //TBD "test.jpg.nxl" we will identify the ".jpg" to show protect jpg icon.
        markExtension = [NSString stringWithFormat:@".%@.", [[fullPath stringByDeletingPathExtension] pathExtension]];
        isNormal = NO;
    }
    
    if ([markExtension compare:@".pdf." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - pdf" : @"filetype - pdf - protected";
    }
    if ([markExtension compare:@".txt." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - txt" : @"filetype - txt - protected";
    }
    if ([markExtension compare:@".jpg." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - jpg" : @"filetype - jpg - protected";
    }
    if ([markExtension compare:@".jpeg." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - jpg" : @"filetype - jpg - protected";
    }
    if ([markExtension compare:@".png." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - png" : @"filetype - png - protected";
    }
    if ([markExtension compare:@".dwg." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - dwg" : @"filetype - dwg - protected";
    }
    
    if ([markExtension compare:@".bmp." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - bmp" : @"filetype - bmp - protected";
    }
    if ([markExtension compare:@".docx." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - docx" : @"filetype - docx - protected";
    }
    if ([markExtension compare:@".gif." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - gif" : @"filetype - gif - protected";
    }
    if ([markExtension compare:@".jt." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - jt" : @"filetype - jt - protected";
    }
    if ([markExtension compare:@".pptx." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - pptx" : @"filetype - pptx - protected";
    }
    if ([markExtension compare:@".rtf." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - rtf" : @"filetype - rtf - protected";
    }
    if ([markExtension compare:@".dwg." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - dwg" : @"filetype - dwg - protected";
    }
    if ([markExtension compare:@".tif." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - tif" : @"filetype - tif - protected";
    }
    if ([markExtension compare:@".xlsx." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - xlsx" : @"filetype - xlsx - protected";
    }
    if ([markExtension compare:@".xls." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - xls" : @"filetype - xls - protected";
    }
    if ([markExtension compare:@".vds." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - vds" : @"filetype - vds - protected";
    }
    if ([markExtension compare:@".doc." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - doc" : @"filetype - doc - protectd";
    }
    if ([markExtension compare:@".c." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - c" : @"filetype - c - protected";
    }
    if ([markExtension compare:@".h." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - h" : @"filetype - h - protected";
    }
    if ([markExtension compare:@".xml." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - xml" : @"filetype - xml - protected";
    }
    if ([markExtension compare:@".model." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - model" : @"filetype - model - protected";
    }
    if ([markExtension compare:@".properties." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - properties" : @"filetype - properties - protected";
    }
    if ([markExtension compare:@".log." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - log" : @"filetype - log - protected";
    }
    if ([markExtension compare:@".json." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - json" : @"filetype - json - protected";
    }
    if ([markExtension compare:@".vb." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - vb" : @"filetype - vb - protected";
    }
    if ([markExtension compare:@".m." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - m" : @"filetype - m - protected";
    }
    if ([markExtension compare:@".swift." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - swift" : @"filetype - swift - protected";
    }
    if ([markExtension compare:@".py." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - py" : @"filetype - py - protected";
    }
    if ([markExtension compare:@".java." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - java" : @"filetype - java - protected";
    }
    if ([markExtension compare:@".cpp." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - cpp" : @"filetype - cpp - protected";
    }
    if ([markExtension compare:@".err." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - err" : @"filetype - err - protected";
    }
    if ([markExtension compare:@".md." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - md" : @"filetype - md - protected";
    }
    if ([markExtension compare:@".sql." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - sql" : @"filetype - sql - protected";
    }
    if ([markExtension compare:@".rtf." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - rtf" : @"filetype - rtf - protected";
    }
    if ([markExtension compare:@".csv." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - csv" : @"filetype - csv - protected";
    }
    if ([markExtension compare:@".js." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - js" : @"filetype - js - protected";
    }
    if ([markExtension compare:@".dotx." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - dotx" : @"filetype - dotx - protected";
    }
    if ([markExtension compare:@".docm." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - docm" : @"filetype - docm - protected";
    }
    if ([markExtension compare:@".potm." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - potm" : @"filetype - potm - protected";
    }
    if ([markExtension compare:@".potx." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - potx" : @"filetype - potx - protected";
    }
    if ([markExtension compare:@".xltm." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - xltm" : @"filetype - xltm - protected";
    }
    if ([markExtension compare:@".xlsb." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - xlsb" : @"filetype - xlsb - protected";
    }
    if ([markExtension compare:@".xlsm." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - xlsm" : @"filetype - xlsm - protected";
    }
    if ([markExtension compare:@".xlt." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - xlt" : @"filetype - xlt - protected";
    }
    if ([markExtension compare:@".xltx." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"filetype - xltx" : @"filetype - xltx - protected";
    }
    if ([markExtension compare:@".par." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"PAR" : @"PAR_G";
    }
    if ([markExtension compare:@".psm." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"PSM" : @"PSM_G";
    }
    if ([markExtension compare:@".XMT_TXT." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"XMT_TXT" : @"XMT_TXT_G";
    }
    if ([markExtension compare:@".prt." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"PRT" : @"PRT_G";
    }
    if ([markExtension compare:@".3dxml." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"3DXM" : @"3DXM_G";
    }
    if ([markExtension compare:@".cgr." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"CGR" : @"CGR_G";
    }
    if ([markExtension compare:@".CATPart." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"CATP" : @"CATP_G";
    }
    
    if ([markExtension compare:@".CATShape." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"CATS" : @"CATS_G";
    }
    
    if ([markExtension compare:@".sldasm." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"SLDA" : @"SLDA_G";
    }
    if ([markExtension compare:@".sldprt." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"SLDP" : @"SLDP_G";
    }
    
    if ([markExtension compare:@".ipt." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"IPT" : @"IPT_G";
    }
    if ([markExtension compare:@".igs." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"IGS" : @"IGS_G";
    }
    
    if ([markExtension compare:@".iges." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"IGES" : @"IGES_G";
    }
    
    if ([markExtension compare:@".stp." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"STP" : @"STP_G";
    }
    if ([markExtension compare:@".step." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"STEP" : @"STEP_G";
    }
    
    if ([markExtension compare:@".dxf." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"DXF" : @"DXF_G";
    }
    if ([markExtension compare:@".stl." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"STL" : @"STL_G";
    }
    if ([markExtension compare:@".vsd." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"VSD" : @"VSD_G";
    }
    if ([markExtension compare:@".vsdx." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"VSDX" : @"VSDX_G";
    }
    if ([markExtension compare:@".tiff." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"TIFF" : @"TIFF_G";
    }
    if ([markExtension compare:@".tif." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"TIF" : @"TIF_G";
    }
    if ([markExtension compare:@".X_T." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"XT" : @"XT_G";
    }
    if ([markExtension compare:@".X_B." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"XB" : @"XB_G";
    }
    if ([markExtension compare:@".hsf." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"HSF" : @"HSF_G";
    }
    if ([markExtension compare:@".mp3." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"MP3" : @"MP3_G";
    }
    if ([markExtension compare:@".mp4." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"MP4" : @"MP4_G";
    }
    if ([markExtension compare:@".mov." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"MOV" : @"MOV_G";
    }
    if ([markExtension compare:@".html." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"HTML" : @"HTML_G";
    }
    if ([markExtension compare:@".htm." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"HTM" : @"HTM_G";
    }
    if ([markExtension compare:@".key." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"KEY" : @"KEY_G";
    }
    if ([markExtension compare:@".numbers." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"NUMB" : @"NUMB_G";
    }
    if ([markExtension compare:@".pages." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"PAGE" : @"PAGE_G";
    }
    if ([markExtension compare:@".GDOC." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"GDOC" : @"GDOC_G";
    }
    if ([markExtension compare:@".GSHEET." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"GSHE" : @"GSHE_G";
    }
    if ([markExtension compare:@".GSLIDES." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"GSLI" : @"GSLI_G";
    }
    if ([markExtension compare:@".GDRAW." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"GDRA" : @"GDRA_G";
    }
    if ([markExtension compare:@".3dm." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"3DM" : @"3DM_P";
    }
    if ([markExtension compare:@".3mf." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"3MF" : @"3MF_P";
    }
    if ([markExtension compare:@".arc." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"ARC" : @"ARC_P";
    }
    if ([markExtension compare:@".asm." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"ASM" : @"ASM_P";
    }
    if ([markExtension compare:@".CATDrawing." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"CATD" : @"CATD_P";
    }
    if ([markExtension compare:@".CATProduct." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"CATP" : @"CATP_P";
    }
    if ([markExtension compare:@".dae." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"DAE" : @"DAE_P";
    }
    if ([markExtension compare:@".dlv." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"DLV" : @"DLV_P";
    }
    if ([markExtension compare:@".exp." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"EXP" : @"EXP_P";
    }
    if ([markExtension compare:@".fbx." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"FBX" : @"FBX_P";
    }
    if ([markExtension compare:@".glb." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"GLB" : @"GLB_P";
    }
    if ([markExtension compare:@".gltf." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"GLTF" : @"GLTF_P";
    }
    if ([markExtension compare:@".hsf." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"HSF" : @"HSF_P";
    }
    if ([markExtension compare:@".iam." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"IAM" : @"IAM_P";
    }
    if ([markExtension compare:@".ifc." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"IFC" : @"IFC_P";
    }
    if ([markExtension compare:@".ifczip." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"IFC" : @"IFC_P";
    }
    if ([markExtension compare:@".mf1." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"MF1" : @"MF1_P";
    }
    if ([markExtension compare:@".neu." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"NEU" : @"NEU_P";
    }
    if ([markExtension compare:@".obj." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"OBJ" : @"OBJ_p";
    }
    if ([markExtension compare:@".pkg." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"PKG" : @"PKG_P";
    }
    if ([markExtension compare:@".prc." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"PRC" : @"PRC_P";
    }
    if ([markExtension compare:@".pts." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"PTS" : @"PTS_P";
    }
    if ([markExtension compare:@".ptx." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"PTX" : @"PTX_P";
    }
    if ([markExtension compare:@".pwd." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"PWD" : @"PWD_P";
    }
    if ([markExtension compare:@".rfa." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"RFA" : @"RFA_P";
    }
    if ([markExtension compare:@".sat." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"SAT" : @"SAT_P";
    }
    if ([markExtension compare:@".rvt." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"RVT" : @"RVT_P";
    }
    if ([markExtension compare:@".sab." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"SAB" : @"SAB_P";
    }
    if ([markExtension compare:@".session." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"SESS" : @"SESS_P";
    }
    if ([markExtension compare:@".unv." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"UNV" : @"UNV_P";
    }
    if ([markExtension compare:@".u3d." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"U3D" : @"U3D_P";
    }
    if ([markExtension compare:@".vda." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"VDA" : @"VDA_P";
    }
    if ([markExtension compare:@".vrml." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"VRML" : @"VRML_P";
    }
    if ([markExtension compare:@".wrl." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"WRL" : @"WRL_P";
    }
    if ([markExtension compare:@".xax." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"XAX" : @"XAX_P";
    }
    if ([markExtension compare:@".xpr." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"XPR" : @"XPR_P";
    }
    if ([markExtension compare:@".xyz." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return isNormal ? @"XYZ" : @"XYZ_P";
    }
    NSRange foundOjb = [wordString rangeOfString:markExtension options:NSCaseInsensitiveSearch];
    if (foundOjb.length > 0) {
        return isNormal ? @"filetype - doc" : @"filetype - doc - protectd";
    }
    
    foundOjb = [pptString rangeOfString:markExtension options:NSCaseInsensitiveSearch];
    if (foundOjb.length > 0) {
        return isNormal ? @"filetype - ppt" : @"filetype - ppt - protected";
    }
    
    foundOjb = [excelString rangeOfString:markExtension options:NSCaseInsensitiveSearch];
    if (foundOjb.length > 0) {
        return isNormal ? @"filetype - normal" : @"filetype - normal - protected";
    }
    
    return isNormal ? @"filetype - normal" : @"filetype - normal - protected";
}

+ (void)setLocalFileLastModifiedDate:(NSString *)localFilePath date:(NSDate *)date {
    NSError *error;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [defaultManager attributesOfItemAtPath:localFilePath error:&error];
    if (error) {
        NSLog(@"get file attribute failed, error message: %@", error.localizedDescription);
        return;
    }
    NSMutableDictionary *fileMutableDictory = [NSMutableDictionary dictionaryWithDictionary:fileAttributes];
    if (date) {
        [fileMutableDictory setObject:date forKey:@"NSFileModificationDate"];
        [defaultManager setAttributes:fileMutableDictory ofItemAtPath:localFilePath error:&error];
    } else { 
        NSLog(@"file modified time is null");
        return;
    }

    if(error) {
        NSLog(@"modify last modify date failed,error message :%@", error.localizedDescription);
    }
}

+ (NSDate *)getLocalFileLastModifiedDate:(NSString *)localFilePath {
    NSError *error;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [defaultManager attributesOfItemAtPath:localFilePath error:&error];
    if (error) {
        NSLog(@"get file attribute failed, error message: %@", error.localizedDescription);
        return nil;
    }
    NSDate *lastModifiedTime = [fileAttributes objectForKey:@"NSFileModificationDate"];
    return lastModifiedTime;
}

+ (UIUserInterfaceIdiom) getUserInterfaceIdiom
{
//    return [[UIDevice currentDevice] userInterfaceIdiom];
    return UIUserInterfaceIdiomPad;
}

+ (NSUInteger) getLogIndex
{
    NSUInteger retVal = arc4random();
    return retVal;
}

+ (NSString *) rmcToRMSRepoType:(NSNumber *) rmcRepoType
{
    NSDictionary *mapDict = @{[NSNumber numberWithInteger:kServiceDropbox]:RMS_REPO_TYPE_DROPBOX,
                              [NSNumber numberWithInteger:kServiceSharepointOnline]:RMS_REPO_TYPE_SHAREPOINTONLINE,
                              [NSNumber numberWithInteger:kServiceSharepoint]:RMS_REPO_TYPE_SHAREPOINT,
                              [NSNumber numberWithInteger:kServiceOneDrive]:RMS_REPO_TYPE_ONEDRIVE,
                              [NSNumber numberWithInteger:kServiceGoogleDrive]:RMS_REPO_TYPE_GOOGLEDRIVE,
                              [NSNumber numberWithInteger:kServiceSkyDrmBox]:RMS_REPO_TYPE_SKYDRMBOX,
                              [NSNumber numberWithInteger:kServiceBOX]:RMS_REPO_TYPE_BOX,
                              [NSNumber numberWithInteger:kServiceOneDriveApplication]:RMS_REPO_TYPE_ONE_DRIVE_APPLICATION,
                              [NSNumber numberWithInteger:KServiceSharepointOnlineApplication]:RMS_REPO_TYPE_SHAREPOINTONLINE_APPLICATION
                              };
    
    return mapDict[rmcRepoType];
}

+ (NSNumber *) rmsToRMCRepoType:(NSString *) rmsRepoType
{    
    NSDictionary *mapDict = @{RMS_REPO_TYPE_DROPBOX:[NSNumber numberWithInteger:kServiceDropbox],
                              RMS_REPO_TYPE_SHAREPOINTONLINE:[NSNumber numberWithInteger:kServiceSharepointOnline],
                              RMS_REPO_TYPE_SHAREPOINT:[NSNumber numberWithInteger:kServiceSharepoint],
                              RMS_REPO_TYPE_ONEDRIVE:[NSNumber numberWithInteger:kServiceOneDrive],
                              RMS_REPO_TYPE_GOOGLEDRIVE:[NSNumber numberWithInteger:kServiceGoogleDrive],
                              RMS_REPO_TYPE_SKYDRMBOX:[NSNumber numberWithInteger:kServiceSkyDrmBox],
                              RMS_REPO_TYPE_BOX:[NSNumber numberWithInteger:kServiceBOX],
                              RMS_REPO_TYPE_ONE_DRIVE_APPLICATION:[NSNumber numberWithInteger:kServiceOneDriveApplication],
                              RMS_REPO_TYPE_SHAREPOINTONLINE_APPLICATION:[NSNumber numberWithInteger:KServiceSharepointOnlineApplication]

    };
    return mapDict[rmsRepoType];
}


+ (NSString *) rmsToRMCDisplayName:(NSString *) rmsRepoType
{
    NSDictionary *mapDict = @{RMS_REPO_TYPE_DROPBOX:NSLocalizedString(@"CLOUDSERVICE_DROPBOX", nil),
                              RMS_REPO_TYPE_SHAREPOINTONLINE:NSLocalizedString(@"CLOUDSERVICE_SHAREPOINTONLINE", nil),
                              RMS_REPO_TYPE_SHAREPOINT:NSLocalizedString(@"CLOUDSERVICE_SHAREPOINT", nil),
                              RMS_REPO_TYPE_ONEDRIVE:NSLocalizedString(@"CLOUDSERVICE_ONEDRIVE", nil),
                              RMS_REPO_TYPE_GOOGLEDRIVE:NSLocalizedString(@"CLOUDSERVICE_GOOGLEDRIVE", nil),
                              RMS_REPO_TYPE_SKYDRMBOX:NSLocalizedString(@"CLOUDSERVICE_SKYDRMBOX", nil),
                              RMS_REPO_TYPE_BOX:NSLocalizedString(@"CLOUDSERVICE_BOX", nil),
                              RMS_REPO_TYPE_ONE_DRIVE_APPLICATION:NSLocalizedString(@"CLOUDSERVICE_ONEDRIVE", nil)
                              
                              };
    return mapDict[rmsRepoType];
}

+ (void)clearUpSDK:(ServiceType) serviceType appendData:(id) appendData
{
    switch (serviceType) {
        case kServiceDropbox:
            break;
        case kServiceSharepoint:
            break;
        case kServiceSharepointOnline:
            break;
        case kServiceOneDrive:
        {
        }
            break;
        case kServiceGoogleDrive:
        {
            NSString *keychainItemName = (NSString *)appendData;
            if (keychainItemName) {
                [GTMAppAuthFetcherAuthorization
                 removeAuthorizationFromKeychainForName:keychainItemName];
            }
        }
            break;
        default:
            break;
    }
}
+ (void)changeRMCServiceTokenToRMSServiceToken:(NXRMCRepoItem *)serviceItem
{
    switch (serviceItem.service_type.integerValue) {
        case kServiceGoogleDrive:
        {
            GTMAppAuthFetcherAuthorization* authorization =
            [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:serviceItem.service_account_token];
            
            NSData* authData = [NSKeyedArchiver archivedDataWithRootObject:authorization];
            authData = [authData gzip];
            NSString *dataStr = [authData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
            serviceItem.service_account_token = dataStr;
        }
            break;
        case kServiceSharepoint:
        {
            serviceItem.service_account_token = [NXKeyChain load:serviceItem.service_account_id];
        }
            break;
        default:
            break;
    }

}

+ (void)buildEnviromentForRepoSDK:(NXRepositoryModel *)repoItem
{
    if(repoItem.service_account_token == nil)
        return;
    
    switch (repoItem.service_type.integerValue) {
        case kServiceGoogleDrive:
        {
            NSString *authStr = repoItem.service_account_token;
            NSData *data = [[NSData alloc] initWithBase64EncodedString:authStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
            data = [data ungzip];
            GTMAppAuthFetcherAuthorization *auth = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSString *keychainItemName = [[NSUUID UUID] UUIDString];
            [GTMAppAuthFetcherAuthorization saveAuthorization:auth
                                            toKeychainForName:keychainItemName];
            // update the repoItemInfo
            [repoItem setValue:keychainItemName forKey:@"service_account_token"];
        }
            break;
        case kServiceOneDrive:
        {
//            AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            //  step1. log out the old account if any
            
            
            // step2. stroe the refreshToken to disk(the same file paht for liveSDK)
            NSString *libDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePath = [libDirectory stringByAppendingPathComponent:@"LiveService_auth.plist"];
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            [data setValue:ONEDRIVECLIENTID forKey:LIVE_AUTH_CLIENTID];
            [data setValue:repoItem.service_account_token forKey:LIVE_AUTH_REFRESH_TOKEN];
            [data writeToFile:filePath atomically:YES];
            
            // step3. recreate the liveConnectClient to use the new refresh token
            //[app refreshLiveConnectionClient];
            
        }
            break;
        case kServiceSharepoint:
        {
//            [NXKeyChain save:repoItem.service_account_id data:repoItem.service_account_token];
            [repoItem setValue:repoItem.service_account_id forKey:@"service_account_token"];
        }
            break;
            
        default:
            break;
    }
}

+ (BOOL)cleanUpBoundRepoData:(NXRepositoryModel *)repoModel
{
    //delete directory cache.
    [NXCacheManager deleteCachedRepositoryFileSystemTree:repoModel];
    // delete cache record in db
    [NXCacheFileStorage deleteCacheFilesFromCoreDataForRepo:repoModel];
    
    // delete cache files.
    NSURL* url = [NXCacheManager getLocalUrlForServiceCache:repoModel];
    
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    // do repo special clear
    [self destoryEnviromentForRepoSDK:repoModel];
    
    [NXRepositoryStorage deleteRepoFromCoreData:repoModel];
    return YES;
}

+ (void)destoryEnviromentForRepoSDK:(NXRepositoryModel *)repoItem {
    if (repoItem.service_type.integerValue == kServiceGoogleDrive) {
        
        [self clearUpSDK:(ServiceType)repoItem.service_type.integerValue appendData:repoItem.service_account_token];
        
    }else
    {
        [self clearUpSDK:(ServiceType)repoItem.service_type.integerValue appendData:nil];
    }
    
}


//+(NSString *) userSyncDateDefaultsKey
//{
//    NSString *syncDateKey = [NSString stringWithFormat:@"%@@%@", [NXLoginUser sharedInstance].profile.userId, [NXLoginUser sharedInstance].profile.individualMembership.tenantId];
//
//    [syncDateKey stringByAppendingString:NXSYNC_REPO_DATE_USERDEFAULTS_KEY];
//    return syncDateKey;
//}

+ (NXSyncDateModel *)userSyncDateModel
{
    NSString *syncDateKey = [NSString stringWithFormat:@"%@@%@", [NXLoginUser sharedInstance].profile.userId, [NXLoginUser sharedInstance].profile.individualMembership.tenantId];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:syncDateKey];
    NSData *modelData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([modelData isKindOfClass:[NXSyncDateModel class]]) {
        return (NXSyncDateModel *)modelData;
    }
    return nil;
}

+ (void)storeSyncDateModel:(NXSyncDateModel *)model
{
    NSString *syncDateKey = [NSString stringWithFormat:@"%@@%@", [NXLoginUser sharedInstance].profile.userId, [NXLoginUser sharedInstance].profile.individualMembership.tenantId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:model] forKey:syncDateKey];
}

+ (NSString *)displaySyncDateString {
    NXSyncDateModel *model = [self userSyncDateModel];
    if (model == nil) {
       return NSLocalizedString(@"NOT_SYNC_YET", NULL);
    }
    
    if (model.isSyncSuccessed) {
        return [self timeAgoFromDate:[NSDate dateWithTimeIntervalSince1970:model.syncDate]];
    } else {
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Failed", NULL), [self timeAgoFromDate:[NSDate dateWithTimeIntervalSince1970:model.syncDate]]];
    }
    return @"";
}

+ (NSString *) ISO8601Format:(NSDate *)date {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"<\"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'\""];
    return [formatter stringFromDate:date];
}

// convert URI string to normal string.
+ (NSString *)decodedURLString:(NSString *)encodedString
{
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)encodedString, CFSTR(""));
    return decodedString;
}

+ (NSNumber *)converttoNumber:(NSString *)string
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [f numberFromString:string];
    return number;
}

+ (BOOL)ispdfFileContain3DModelFormat:(NSString *)pdfFilePath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:pdfFilePath]) {
        return NO;
    }
    
    CFURLRef pdfURL = CFURLCreateWithFileSystemPath(NULL, (__bridge CFStringRef)pdfFilePath, kCFURLPOSIXPathStyle, NO);
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(pdfURL);
    
    size_t pages = CGPDFDocumentGetNumberOfPages(document);
    //3D pdf file format: https://www.convertcadfiles.com/3d-pdf/
    for (int i = 0; i < pages; i++) {
        
        CGPDFPageRef page = CGPDFDocumentGetPage(document, i + 1);
        CGPDFDictionaryRef dic = CGPDFPageGetDictionary(page);
        CGPDFObjectRef object;
        if (CGPDFDictionaryGetObject(dic, [@"Annots" UTF8String],&object) && CGPDFObjectGetType(object) == kCGPDFObjectTypeArray) {
              CGPDFArrayRef array;
              CGPDFDictionaryGetArray(dic, [@"Annots" UTF8String], &array);
              for (int j = 0; j < CGPDFArrayGetCount(array); j++) {
                  CGPDFObjectRef object;
                  if (CGPDFArrayGetObject(array, j, &object) && CGPDFObjectGetType(object) == kCGPDFObjectTypeDictionary) {
                      const char *type;
                      CGPDFDictionaryRef anno;
                      if (CGPDFArrayGetDictionary(array, j, &anno) && CGPDFDictionaryGetName(anno, [@"Subtype" UTF8String], &type)) {
                          if ([[NSString stringWithUTF8String:type] isEqualToString:@"3D"]) {
                              CGPDFStreamRef stream;
                              if (CGPDFDictionaryGetStream(anno, [@"3DD" UTF8String], &stream)) {
                                  CGPDFDictionaryRef streamDic = CGPDFStreamGetDictionary(stream);
                                  const char *typeName;
                                  CGPDFDictionaryGetName(streamDic, [@"Type" UTF8String], &typeName);
                                  const char *subTypename;
                                  CGPDFDictionaryGetName(streamDic, [@"Subtype" UTF8String], &subTypename);
                                  if ([[NSString stringWithUTF8String:subTypename] compare:@"U3D" options:NSCaseInsensitiveSearch] == NSOrderedSame||
                                      [[NSString stringWithUTF8String:subTypename] compare:@"PRC" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//                                      CGPDFPageRelease(page);
                                      CFRelease(pdfURL);
                                      CGPDFDocumentRelease(document);
                                      return YES;
                                  }
                              }
                          }
                      }
                  }
              }
        }
        //http://lists.apple.com/archives/quartz-dev/2006/Jun/msg00087.html
//        CGPDFPageRelease(page);
    }
    CFRelease(pdfURL);
    CGPDFDocumentRelease(document);
    return NO;
}

+ (BOOL)isStewardUser:(NSString *)userId forFile:(NXFileBase *)nxlFile {
    if (nxlFile.sorceType == NXFileBaseSorceTypeProject || nxlFile.sorceType == NXFileBaseSorceTypeWorkSpace) {
        return NO;
    }
    return [[NXLoginUser sharedInstance].profile.individualMembership.ID isEqualToString:userId];
}

+ (NXExternalNXLFileSourceType)getExternalNXLFileTypeByFileOwnerID:(NSString *)fileOwnerID;
{
    if (!fileOwnerID) {
        return NXExternalNXLFileSourceTypeOther;
    }
    
    if ([fileOwnerID isEqualToString:[NXLoginUser sharedInstance].profile.individualMembership.ID]) {
       return NXExternalNXLFileSourceTypeMyVault;
    }
    
    __block NXExternalNXLFileSourceType type = NXExternalNXLFileSourceTypeOther;
    NSArray *memberships = [NXLoginUser sharedInstance].profile.memberships;
   
    NSString *systemDefaultProjectTenantId = [NXLoginUser sharedInstance].profile.tenantPrefence.SYSTEM_DEFAULT_PROJECT_TENANTID;
   __block NSString *systemDefaultProjectMembershipId = nil;
    NSString *ownerTenantName = [fileOwnerID componentsSeparatedByString:@"@"].lastObject;
    [memberships enumerateObjectsUsingBlock:^(NXLMembership *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.tenantId isEqualToString:systemDefaultProjectTenantId]) {
            systemDefaultProjectMembershipId = obj.ID;
            if (systemDefaultProjectMembershipId == fileOwnerID) {
                type = NXExternalNXLFileSourceTypeSystemDefaultProject;
                *stop = YES;
            }
        }
        if (obj.projectId) {
            if ([obj.tokenGroupName isEqualToString:ownerTenantName]) {
                type = NXExternalNXLFileSourceTypeProject;
                *stop = YES;
            }
        }
    }];
    
    return type;
}

+ (BOOL)createZipFileAtPath:(NSString *)path withFilesAtPaths:(NSArray *)paths {
  return  [SSZipArchive createZipFileAtPath:path withFilesAtPaths:paths];
}
+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination {
   return  [SSZipArchive unzipFileAtPath:path toDestination:destination];
}

+ (NSString *)sessionTimeOutString {
    double timeOutMilliSeconds = [NXLoginUser sharedInstance].profile.ttl.doubleValue - [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger timeOutSeconds = timeOutMilliSeconds / 1000;
    //    NSInteger days = timeOutSeconds / (24*3600);
    //    timeOutSeconds -= days * 24* 3600;
    //    NSInteger hours = timeOutSeconds / 3600;
    
    //    NSInteger seconds = timeOutSeconds % 60;
    timeOutSeconds /= 60;
    NSInteger minutes = timeOutSeconds % 60;
    timeOutSeconds /= 60;
    NSInteger hours = timeOutSeconds % 24;
    timeOutSeconds /= 24;
    NSInteger days = timeOutSeconds;
    
    NSString *timeoutStr = [NSString stringWithFormat:@"%@%@%@", (days ? [NSString stringWithFormat:@"%ld %@ ",days, days > 1 ? NSLocalizedString(@"DAYS", NULL): NSLocalizedString(@"DAY", NULL)] : @""), (hours ? [NSString stringWithFormat:@"%ld %@ ", hours, hours > 1 ? NSLocalizedString(@"HOURS", NULL) : NSLocalizedString(@"HOUR", NULL)] : @""), (minutes ? [NSString stringWithFormat:@"%ld %@", minutes, minutes > 1 ? NSLocalizedString(@"MINUTES", NULL):NSLocalizedString(@"MINUTE", NULL)]: @"")];
    return timeoutStr;
    //    if (days > 0) {
    //        if (hours > 0) {
    //            timeoutStr = [NSString stringWithFormat:@"%ld %@ %ld %@",(long)days, days>1?NSLocalizedString(@"DAYS", NULL):NSLocalizedString(@"DAY", NULL), (long)hours, hours > 1?NSLocalizedString(@"HOURS", NULL):NSLocalizedString(@"HOUR", NULL)];
    //        }else
    //        {
    //            timeoutStr = [NSString stringWithFormat:@"%ld %@",(long)days, days>1?NSLocalizedString(@"DAYS", NULL):NSLocalizedString(@"DAY", NULL)];
    //        }
    //    }else
    //    {
    //        timeoutStr = [NSString stringWithFormat:@"%ld %@",(long)hours, hours > 1?NSLocalizedString(@"HOURS", NULL):NSLocalizedString(@"HOUR", NULL)];
    //    }
}

+ (NSString *)timeAgoFromDate:(NSDate *)date {
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond)fromDate:date toDate:[NSDate date] options:0];
    
    if (components.year > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        formatter.allowedUnits = NSCalendarUnitYear;
    } else if (components.year > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
        formatter.allowedUnits = NSCalendarUnitYear;
    } else if (components.month > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        formatter.allowedUnits = NSCalendarUnitMonth;
    } else if (components.month > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
        formatter.allowedUnits = NSCalendarUnitMonth;
    } else if (components.weekOfMonth > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        formatter.allowedUnits = NSCalendarUnitWeekOfMonth;
    } else if (components.weekOfMonth > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
        formatter.allowedUnits = NSCalendarUnitWeekOfMonth;
    } else if (components.day > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        formatter.allowedUnits = NSCalendarUnitDay;
    } else if (components.day > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
        formatter.allowedUnits = NSCalendarUnitDay;
    } else if (components.hour > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        formatter.allowedUnits = NSCalendarUnitHour;
    } else if (components.hour > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
        formatter.allowedUnits = NSCalendarUnitHour;
    } else if (components.minute > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        formatter.allowedUnits = NSCalendarUnitMinute;
    } else if (components.minute > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
        formatter.allowedUnits = NSCalendarUnitMinute;
    } else if (components.second > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        formatter.allowedUnits = NSCalendarUnitSecond;
    } else {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
        formatter.allowedUnits = NSCalendarUnitSecond;
    }
    
    NSString *formatString = NSLocalizedString(@"%@ ago", @"Used to say how much time has passed. e.g. '2 hours ago'");
    
    return [NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components]];
}
+ (NSString *)timeAgoShortFromDate:(NSDate *)date {
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond)fromDate:date toDate:[NSDate date] options:0];
    
    if (components.year > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        formatter.allowedUnits = NSCalendarUnitYear;
    } else if (components.year > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
        formatter.allowedUnits = NSCalendarUnitYear;
    } else if (components.month > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
        formatter.allowedUnits = NSCalendarUnitMonth;
    } else if (components.month > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitMonth;
    } else if (components.weekOfMonth > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitWeekOfMonth;
    } else if (components.weekOfMonth > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitWeekOfMonth;
    } else if (components.day > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitDay;
    } else if (components.day > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitDay;
    } else if (components.hour > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitHour;
    } else if (components.hour > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitHour;
    } else if (components.minute > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitMinute;
    } else if (components.minute > 0) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitMinute;
    } else if (components.second > 1) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitSecond;
    } else {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.allowedUnits = NSCalendarUnitSecond;
    }
    
    NSString *formatString = NSLocalizedString(@"%@ ago", @"Used to say how much time has passed. e.g. '2 hours ago'");
    
    return [NSString stringWithFormat:formatString, [formatter stringFromDateComponents:components]];
}


+ (NXFolder *)createRootFolderByRepoType:(ServiceType) type
{
    NXFileBase *rootFolder = [[NXFolder alloc] init];
    rootFolder.isRoot = YES;
    rootFolder.fullPath = @"/";
    rootFolder.favoriteFileList = [[NXCustomFileList alloc] init];
    rootFolder.offlineFileList = [[NXCustomFileList alloc] init];
    rootFolder.sorceType = NXFileBaseSorceTypeRepoFile;
    rootFolder.serviceType = [NSNumber numberWithInteger:type];
    switch (type) {
        case kServiceSkyDrmBox:
        {
            rootFolder.fullServicePath = @"/";
        }
            break;
        case kServiceDropbox:
        {
            rootFolder.fullServicePath = @"";
        }
            break;
        case kServiceGoogleDrive:
        {
            rootFolder.fullServicePath = @"root";
        }
            break;
        case kServiceSharepointOnline:
        {
            rootFolder = [[NXSharePointFolder alloc] init];
            rootFolder.isRoot = YES;
            rootFolder.fullServicePath = @"/";
        }
            break;
        case kServiceOneDrive:
        {
            rootFolder.fullServicePath = @"root";
        }
            break;
        case kServiceBOX:
        {
            rootFolder.fullServicePath = @"0";
        }
            break;
        case kServiceOneDriveApplication:
        case KServiceSharepointOnlineApplication:
        {
            rootFolder.sorceType = NXFileBaseSorceTypeSharedWorkspaceFile;
            rootFolder.fullServicePath = @"/";
        }
            break;
        default:{
            rootFolder.fullServicePath = @"/";
        }
            break;
    }
    
    return (NXFolder *)rootFolder;
}

+ (NSString *)removeIllegalLettersForPath:(NSString *)path
{
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>"];
    NSString *legalPath = [[path componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    return legalPath;
}

+ (BOOL)fileItemSupportDownloadProgress:(NXFileBase *)fileItem
{
    if (fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile || fileItem.sorceType == NXFileBaseSorceTypeProject) {
        return YES;
    }
    
    if (fileItem.sorceType == NXFileBaseSorceTypeRepoFile)
    {
        if (fileItem.serviceType.integerValue == kServiceDropbox ||
            fileItem.serviceType.integerValue == kServiceOneDrive ||
            fileItem.serviceType.integerValue == kServiceSharepoint ||
            fileItem.serviceType.integerValue == kServiceSkyDrmBox ||
            fileItem.serviceType.integerValue == kServiceSharepointOnline||
            fileItem.serviceType.integerValue == kServiceGoogleDrive) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)fileItemSupportUploadloadProgress:(NXFileBase *)fileItem
{
    if (fileItem.sorceType == NXFileBaseSorceTypeMyVaultFile || fileItem.sorceType == NXFileBaseSorceTypeProject) {
        return YES;
    }
    
    if (fileItem.sorceType == NXFileBaseSorceTypeRepoFile)
    {
        if (fileItem.serviceType.integerValue == kServiceDropbox ||
            fileItem.serviceType.integerValue == kServiceOneDrive ||
            fileItem.serviceType.integerValue == kServiceSkyDrmBox) {
            return YES;
        }
    }
    return NO;
}
+ (NSString *)timeStringFrom1970TimeInterval:(NSTimeInterval)interval orDate:(NSDate *)date{
    NSDateFormatter *dateFormtter = [[NSDateFormatter alloc] init];
    [dateFormtter setDateFormat:@"dd MMM yyyy, HH:mm"];
    NSDate *modifyDate = nil;
    NSString *modifyDateString =nil;
    if (date == nil&&interval>0){
        modifyDate =  [NSDate dateWithTimeIntervalSince1970:interval];
        modifyDateString = [dateFormtter stringFromDate:modifyDate];
    } else if(date){
        modifyDateString = [dateFormtter stringFromDate:date];
    }
    return modifyDateString;
}
+ (BOOL)JudgeTheillegalCharacter:(NSString *)content withRegexExpression:(NSString*)str{

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    if (![predicate evaluateWithObject:content]) {
        return YES;
    }
    return NO;
}


+ (NSRegularExpression *)getSortRegularExpression
{
    if (regular == nil) {
        regular = [NSRegularExpression regularExpressionWithPattern:@"\\p{script=Han}" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    
    return regular;
}

+ (BOOL)IsEnglishLetterInitalCapitalAndLowercaseLetter:(NSString*)string{
    NSString *firstStr = [string substringToIndex:1];
    NSString *regex = @"[a-zA-Z]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL  isEnglisthLetter = [predicate evaluateWithObject:firstStr];
    return isEnglisthLetter;
}
+ (NSMutableDictionary *)getURLParameters:(NSString *)urlStr {
    
    // 查找参数
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    // 以字典形式将参数返回
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?&"]];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}

+ (NSString *)fileKeyForFile:(NXFileBase *)file
{
    if([file isKindOfClass:[NXOfflineFile class]]){
        NXOfflineFile *offlineFile = (NXOfflineFile *)file;
        return offlineFile.fileKey;
    }
    
    NSString *fileKey = nil;
    switch (file.sorceType) {
        case NXFileBaseSorceTypeRepoFile:
        case NXFileBaseSorceTypeSharedWorkspaceFile:
        {
           fileKey = [NSString stringWithFormat:@"%@%@%f", file.repoId, file.fullServicePath,file.lastModifiedDate && !([file isKindOfClass:[NXFolder class]])?[file.lastModifiedDate timeIntervalSince1970]:1];
           
        }
            break;
        case NXFileBaseSorceTypeMyVaultFile:
        {
            NXMyVaultFile *myVaultFile = (NXMyVaultFile *)file;
            fileKey = [NSString stringWithFormat:@"%@%@%@%f",  [NXCommonUtils currentTenant],[NXLoginUser sharedInstance].profile.userId, myVaultFile.fullServicePath, [myVaultFile.lastModifiedDate timeIntervalSince1970]];
        }
            break;
        case NXFileBaseSorceTypeShareWithMe:
        {
            NXSharedWithMeFile *share = (NXSharedWithMeFile *)file;
            fileKey = [NSString stringWithFormat:@"%@%@%@%f",  [NXCommonUtils currentTenant],[NXLoginUser sharedInstance].profile.userId, share.duid,file.lastModifiedDate && !([file isKindOfClass:[NXFolder class]])?[file.lastModifiedDate timeIntervalSince1970]:1];
        }
            break;
        case NXFileBaseSorceTypeWorkSpace:
        {
            NSString *str;
            if ([file isKindOfClass:[NXWorkSpaceFolder class]]) {
                str = file.fullServicePath;
            }else {
                str = ((NXWorkSpaceFile *)file).duid;
            }
            fileKey = [NSString stringWithFormat:@"%@%@%@%f",  [NXCommonUtils currentTenant],[NXLoginUser sharedInstance].profile.userId, str,file.lastModifiedDate && !([file isKindOfClass:[NXFolder class]])?[file.lastModifiedDate timeIntervalSince1970]:1];
        }
            break;
        case NXFileBaseSorceTypeProject:
        {
            NSString *str;
            
            str = [((NXProjectFolder*)file).projectId stringValue];
            fileKey = [NSString stringWithFormat:@"%@%@%@%@%f", [NXCommonUtils currentTenant], [NXLoginUser sharedInstance].profile.userId, str, file.fullServicePath,file.lastModifiedDate && !([file isKindOfClass:[NXFolder class]])?[file.lastModifiedDate timeIntervalSince1970]:1];
        }
            break;
        case NXFileBaseSorceTypeSharedWithProject:
        {
            NXSharedWithProjectFile *sharedFile = (NXSharedWithProjectFile *)file;
            fileKey = [NSString stringWithFormat:@"%@%@%@%@%@%f",  [NXCommonUtils currentTenant],[NXLoginUser sharedInstance].profile.userId,sharedFile.duid, sharedFile.transactionId,sharedFile.spaceId,file.lastModifiedDate && (![file isKindOfClass:[NXFolder class]])?[file.lastModifiedDate timeIntervalSince1970]:1];
        }
            break;
        default:{
            fileKey = file.localPath?:file.name;
        }
            break;
    }
    
    if (fileKey) {
        return [fileKey MD5];
    }
    
    return fileKey;
}

+ (void)addCustomCookies:(NSURL *)url withCooies:(NSArray *)cookies {
    NSMutableArray<NSHTTPCookie *> *cookiesArray = [[NSMutableArray alloc]init];
    NSArray *switchkeys = @[@"version", @"path", @"max-age", @"comment", @"domain"];
    for (NSString *cookie in cookies) {
        NSArray *cookitems = [cookie componentsSeparatedByString:@";"];
        
        NSString *name = @"";
        NSString *value = @"";
        NSString *version = @"";
        NSString *path = @"";
        NSString *comment = @"";
        NSString *maxmumAge = @"";
        NSString *domain = url.host;
        
        for (NSString *item in cookitems) {
            NSArray<NSString *> *tempArray = [item componentsSeparatedByString:@"="];
            if (tempArray.count > 1) {
                NSString *key = [tempArray[0] lowercaseString];
                key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSInteger index = [switchkeys indexOfObject:key];
                switch (index) {
                    case 0:
                        version = tempArray[1];
                        break;
                    case 1:
                        path = tempArray[1];
                        break;
                    case 2:
                        maxmumAge = tempArray[1];
                        break;
                    case 3:
                        comment = tempArray[1];
                        break;
                    case 4:
                        domain = url.host;
                        break;
                    default:
                        name = tempArray[0];
                        value = tempArray[1];
                        break;
                }
            }
        }
        
        
        NSHTTPCookie *httpCookie = nil;
        if ([maxmumAge isEqualToString:@""]) {
            httpCookie = [[NSHTTPCookie alloc]initWithProperties:@{NSHTTPCookieName:name,
                                                                   NSHTTPCookieVersion:version,
                                                                   NSHTTPCookieValue:value,
                                                                   NSHTTPCookieDiscard:@"YES",
                                                                   NSHTTPCookieComment:comment,
                                                                   NSHTTPCookiePath:path,
                                                                   NSHTTPCookieDomain:domain}];
        }else{
            httpCookie = [[NSHTTPCookie alloc]initWithProperties:@{NSHTTPCookieName:name,
                                                                   NSHTTPCookieVersion:version,
                                                                   NSHTTPCookieValue:value,
                                                                   NSHTTPCookieMaximumAge:maxmumAge,
                                                                   NSHTTPCookieComment:comment,
                                                                   NSHTTPCookiePath:path,
                                                                   NSHTTPCookieDomain:domain}];
        }
        
        [cookiesArray addObject:httpCookie];
    }
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookiesArray forURL:url mainDocumentURL:nil];
}

+ (NXRemoteViewRenderType)isRemoteViewUsingCanvasByFile:(NXFileBase *)fileBase
{
    NSString *fileExtension = [NXCommonUtils getFileExtensionByFileName:fileBase];
    
    if ([REMOTEVIEWPRINTCANVASTYPEARRAY containsObject:fileExtension.lowercaseString]) {
        return NXRemoteViewRenderTypeCanvas;
    }
    else if([REMOTEVIEWPRINTIMAGETYPEARRAY containsObject:fileExtension.lowercaseString])
    {
        return NXRemoteViewRenderTypeImage;
    }
    else
    {
        return NXRemoteViewRenderTypeUnknow;
    }
}

+(UIImage *)screenShot:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL)
    {
        return nil;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    
    if( [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [[UIApplication sharedApplication].keyWindow drawViewHierarchyInRect:[UIApplication sharedApplication].keyWindow.bounds afterScreenUpdates:NO];
    }
    else
    {
        [[UIApplication sharedApplication].keyWindow.layer renderInContext:context];
    }
    
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (BOOL)checkIsLegalFileValidityDate:(NXLFileValidateDateModel *)dateModel
{
    if(!dateModel){
        return NO;
    }
    
    if (dateModel.type == NXLFileValidateDateModelTypeNeverExpire) {
        return YES;
    }
    
    BOOL isLegal = YES;
    NSDate *serverTime = [NXTimeServerManager sharedInstance].currentServerTime;
    if (serverTime && [dateModel.endTime compare:serverTime] == NSOrderedAscending) {
        isLegal = NO;
    }
    return isLegal;
}
+(BOOL)checkNXLFileisValid:(NXLFileValidateDateModel *)dateModel{
    if(!dateModel){
        return NO;
    }
    
    if (dateModel.type == NXLFileValidateDateModelTypeNeverExpire) {
        return YES;
    }
    
    BOOL isLegal = YES;
    if (dateModel.type == NXLFileValidateDateModelTypeAbsolute) {
        NSDate *serverTime = [NXTimeServerManager sharedInstance].currentServerTime;
        if (serverTime && [dateModel.endTime compare:serverTime] == NSOrderedDescending) {
            return YES;
        }
    }
    NSDate *serverTime = [NXTimeServerManager sharedInstance].currentServerTime;
    if (serverTime &&([dateModel.startTime compare:serverTime] ==NSOrderedDescending || [dateModel.endTime compare:serverTime] == NSOrderedAscending)) {
        isLegal = NO;
    }
    return isLegal;
    
}
+ (BOOL)checkNXLFileisExpired:(NXLFileValidateDateModel *)dateModel;
{
    if (dateModel.type == NXLFileValidateDateModelTypeNeverExpire) {
        return NO;
    }
    
    BOOL isExpired = NO;
    NSDate *serverTime = [NXTimeServerManager sharedInstance].currentServerTime;
    if (serverTime && [dateModel.endTime compare:serverTime] == NSOrderedAscending) {
        isExpired = YES;
    }
    return isExpired;
}
+ (NSString *)getUserInputServerAddress
{
    NSString *libDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myPath = [libDirectory stringByAppendingPathComponent:@"SkyDRM_loginUrl.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath];
    
    NSString *serverInputServerAddress = [data objectForKey:SKYDRM_USER_INPUT_SERVER_ADDRESS_KEY];
    return serverInputServerAddress;
}

+ (void)setUserLoginStatus:(NXUserLoginStatusType)type
{
    NSString *libDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myPath = [libDirectory stringByAppendingPathComponent:@"SkyDRM_loginUrlStatus.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath];
    if (!data) {
        data = [[NSMutableDictionary alloc] init];
    }
    if (type == NXUserLoginStatusTypePersonal) {
         [data setValue:[NSNumber numberWithInt:0] forKey:SKYDRM_USER_LOGIN_STATUS_KEY];
    }
    
    if (type == NXUserLoginStatusTypeCompany) {
         [data setValue:[NSNumber numberWithInt:1] forKey:SKYDRM_USER_LOGIN_STATUS_KEY];
    }
     [data writeToFile:myPath atomically:YES];
}

+ (BOOL)isCompanyAccountLogin
{
    NSString *libDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myPath = [libDirectory stringByAppendingPathComponent:@"SkyDRM_loginUrlStatus.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath];
    
    NSNumber *loginStatus = [data objectForKey:SKYDRM_USER_LOGIN_STATUS_KEY];
    
    if (loginStatus.integerValue == 1) {
        return YES;
    }
    return NO;
}

+ (NSArray *)getUserRememberedAndManagedLoginUrlList
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSString *libDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myPath = [libDirectory stringByAppendingPathComponent:@"SkyDRM_loginUrl.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath];
    
    NSDictionary *userRememberedLoginUrlDic = [data objectForKey:SKYDRM_USER_REMEMBERED_LOGIN_URL_LIST];
    if (userRememberedLoginUrlDic.allKeys.count == 0) {
        return nil;
    }
    
    for (NSString *loginUrlKey in userRememberedLoginUrlDic.allKeys) {
        if (loginUrlKey.length > 0) {
            [list addObject:loginUrlKey];
        }
    }
    return list;
}

+ (NSString *)getUserCurrentSelectedLoginURL
{
   __block NSString *selectedLoginURL ;
    
    NSString *libDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myPath = [libDirectory stringByAppendingPathComponent:@"SkyDRM_loginUrl.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath];
    
    NSMutableDictionary *userRememberedLoginUrlDic = [data objectForKey:SKYDRM_USER_REMEMBERED_LOGIN_URL_LIST];
    if (userRememberedLoginUrlDic.allKeys.count == 0) {
        return nil;
    }
    
    [userRememberedLoginUrlDic enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSLog(@"value for key %@ is %@ ", key, value);
        if ([value isEqualToString:@"selected"]) {
            selectedLoginURL = key;
            *stop = YES;
        }
    }];
    return selectedLoginURL;
}

+ (void)updateUserLoginUrl:(NSString *)oldLoginUrl newLoginUrl:(NSString *)newLoginUrl isMakeDefault:(BOOL)makeDefault
{
    NSString *libDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myPath = [libDirectory stringByAppendingPathComponent:@"SkyDRM_loginUrl.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath];
    if (!data) {
        data = [[NSMutableDictionary alloc] init];
    }
    NSDictionary *userRememberedLoginUrlDic = [data objectForKey:SKYDRM_USER_REMEMBERED_LOGIN_URL_LIST];
    
    if (!userRememberedLoginUrlDic) {
        userRememberedLoginUrlDic = [NSDictionary new];
    }
    
    NSMutableDictionary *dic = [userRememberedLoginUrlDic mutableCopy];
    if (!oldLoginUrl && newLoginUrl.length > 0) {
        [dic setValue:@"unselected" forKey:newLoginUrl];
    }
    
    if (oldLoginUrl.length > 0 && newLoginUrl.length > 0) {
        [dic setValue:[dic valueForKey:oldLoginUrl] forKey:newLoginUrl];
        if (![oldLoginUrl isEqualToString:newLoginUrl]) {
             [dic removeObjectForKey:oldLoginUrl];
        }
        
    }
    
    if (dic.allKeys.count > 0) {
        [data setValue:dic forKey:SKYDRM_USER_REMEMBERED_LOGIN_URL_LIST];
    }
    
    [data writeToFile:myPath atomically:YES];
    if (makeDefault) {
        [self setUserRememberedAndSelectedLoginUrl:newLoginUrl];
    }
}

+ (void)removeUserRememberedLoginUrl:(NSString *)loginUrl
{
    NSString *libDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myPath = [libDirectory stringByAppendingPathComponent:@"SkyDRM_loginUrl.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath];
    NSMutableDictionary *userRememberedLoginUrlDic = [data objectForKey:SKYDRM_USER_REMEMBERED_LOGIN_URL_LIST];
    
    if (loginUrl.length > 0) {
        [userRememberedLoginUrlDic removeObjectForKey:loginUrl];
    }
    [data writeToFile:myPath atomically:YES];
}

+ (void)setUserRememberedAndSelectedLoginUrl:(NSString *)selectedLoginUrl
{
    if (!selectedLoginUrl) {
        return;
    }
    
    NSString *libDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myPath = [libDirectory stringByAppendingPathComponent:@"SkyDRM_loginUrl.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath];
    NSMutableDictionary *userRememberedLoginUrlDic = [data objectForKey:SKYDRM_USER_REMEMBERED_LOGIN_URL_LIST];
   
    if (userRememberedLoginUrlDic.allKeys.count > 0) {
        for (NSString *rememberedLoginUrlKey in userRememberedLoginUrlDic.allKeys) {
            if ([rememberedLoginUrlKey isEqualToString:selectedLoginUrl]) {
                [userRememberedLoginUrlDic setValue:@"selected" forKey:rememberedLoginUrlKey];
            }else {
                [userRememberedLoginUrlDic setValue:@"unselected" forKey:rememberedLoginUrlKey];
            }
        }
    }
    [data writeToFile:myPath atomically:YES];
}
+ (NSString *)getDefaultPresonalLoginURL {
    return DEFAULT_SKYDRM;
}

+ (BOOL)checkStringContainMultiByte:(NSString *)checkedString {
    for (NSUInteger index = 0; index < checkedString.length; ++index) {
        unichar uc = [checkedString characterAtIndex: index];
        unsigned short res = uc & 0xFF00;
        if (res != 0) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)MIMETypeFileName:(NSString *)path
                    defaultMIMEType:(NSString *)defaultType {
  NSString *result = defaultType;
  NSString *extension = [path pathExtension];
  CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
      (__bridge CFStringRef)extension, NULL);
  if (uti) {
    CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
    if (cfMIMEType) {
      result = CFBridgingRelease(cfMIMEType);
    }
    CFRelease(uti);
  }
  return result;
}
+(UIImage *)getProviderIconByRepoProviderClass:(NSString *)providerClass{
    UIImage *image = nil;
    if (!providerClass) {
        image = [UIImage imageNamed:@"Personal Account"];
    }
   
    if ([providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_PERSONAL", NULL)]) {
        image = [UIImage imageNamed:@"Personal Account"];
    }
    if ([providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_APPLICATION", NULL)]) {
        image = [UIImage imageNamed:@"Application Account"];
    }
    if ([providerClass isEqualToString:NSLocalizedString(@"UI_PROVIDERCLASS_BUSINESS", NULL)]) {
        image = [UIImage imageNamed:@"Business Account"];
    }
    return image;
}
+(UIImage *)getRepoIconByRepoType:(NSInteger)repoType {
    UIImage *image = nil;
    switch (repoType) {
        case kServiceDropbox:
            image = [UIImage imageNamed:@"dropbox - black"];
            break;
        case kServiceSharepointOnline:
        case kServiceSharepoint:
        case KServiceSharepointOnlineApplication:
            image = [UIImage imageNamed:@"sharepoint - black"];
            break;
        case kServiceOneDrive:
        case kServiceOneDriveApplication:
            image = [UIImage imageNamed:@"onedrive - black"];
            break;
        case kServiceGoogleDrive:
            image = [UIImage imageNamed:@"google-drive-color"];
            break;
        case kServiceBOX:
            image = [UIImage imageNamed:@"box - black"];
            break;
        case kServiceSkyDrmBox:
            image = [UIImage imageNamed:@"MyDrive"];
            break;
        default:
            break;
    }
    return image;
    
}
+ (BOOL)isSkyDRMForcurrentServer:(NSString *)serverAddress {
    if ([serverAddress containsString:DEFAULT_SKYDRM]) {
        return YES;
    }
    return NO;
}
+ (BOOL)isSupportWorkspace{
    BOOL workspaceEnable = YES;
    if ((buildFromSkyDRMEnterpriseTarget && [NXCommonUtils isCompanyAccountLogin])) {
        if ([NXLoginUser sharedInstance].profile.tenantPrefence) {
            if ([NXLoginUser sharedInstance].profile.tenantPrefence.workspaceType) {
                NSNumber *workspaceType = [NXLoginUser sharedInstance].profile.tenantPrefence.workspaceType;
                workspaceEnable = [workspaceType boolValue];
            }else{
                return  YES;
            }
            
        }else{
            return  NO;
        }
       
    }else{
        return NO;
    }
    return workspaceEnable;
}
+ (NSString *)getCurretnHostName {
//    NSString *host;
//    NSString *serverUrl =  [NXCommonUtils isCompanyAccountLogin] ? [NXCommonUtils getUserCurrentSelectedLoginURL] : [NXCommonUtils getDefaultPresonalLoginURL];
//    if ([serverUrl containsString:@"https://"]) {
//        host = [serverUrl stringByReplacingOccurrencesOfString:@"https://" withString:@""];
//    }else if ([serverUrl containsString:@"http://"]){
//        host = [serverUrl stringByReplacingOccurrencesOfString:@"http://" withString:@""];
//    }else{
//        host = serverUrl;
//    }
//    return host;
//    const char *hostN= [hostName UTF8String];
//      struct hostent* phot;
//      @try {
//          phot = gethostbyname(hostN);
//
//      }
//      @catch (NSException *exception) {
//          return nil;
//      }
//
//      struct in_addr ip_addr;
//      memcpy(&ip_addr, phot->h_addr_list[0], 4);
//      char ip[20] = {0};
//      inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
//
//      NSString* strIPAddress = [NSString stringWithUTF8String:ip];
//      return strIPAddress;
    return  UIDevice.currentDevice.name;
}
+ (NSString *)getCurrentIpAdress {
    return [[[self alloc] init] getLocalIPAddress:YES];
}
- (NSString *)getLocalIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}
- (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}
- (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
@end
