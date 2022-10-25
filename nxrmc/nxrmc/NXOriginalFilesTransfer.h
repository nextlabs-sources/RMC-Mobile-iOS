//
//  NXOriginalFilesTransfer.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/3/31.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NXFile, UIViewController, NXFileBase;
typedef NSString * UIActivityType NS_TYPED_EXTENSIBLE_ENUM;
typedef void(^savedcompletionWithItemsHandler)(NSString *activityType,BOOL completed,NSArray *  returnedItems,NSError *  activityError);
typedef void(^exprotFileCompletion)(UIViewController *currentVC,NSURL *fileUrl,NSError *error);
typedef void(^exprotMultipleFilesCompletion)(UIViewController *currentVC,NSArray *fileUrls,NSError *error);
typedef void(^improtFileCompletion)(UIViewController *currentVC,NXFile *fileItem,NSData *fileData,NSError *error);
typedef void(^improtMultipleFileCompletion)(UIViewController *currentVC,NSArray *fileArray,NSError *error);
typedef void(^cancelDocumentPickerCompletion)(UIViewController *currentVC);
@interface NXOriginalFilesTransfer : NSObject
@property(nonatomic, copy) improtFileCompletion improtFileCompletion;
@property(nonatomic, copy) improtMultipleFileCompletion improtMultipleFileCompletion;
@property(nonatomic, copy) exprotFileCompletion exprotFileCompletion;
@property(nonatomic, copy) exprotMultipleFilesCompletion exprotMultipleFilesCompletion;
@property(nonatomic, copy) cancelDocumentPickerCompletion cancelCompletion;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;
+ (instancetype)sharedIInstance;
- (BOOL)saveFile:(NXFileBase *)fileItem toOriginalFilesFromVC:(UIViewController *)VC withCompletion:(savedcompletionWithItemsHandler)completion;
//- (BOOL)saveFiles:(NSArray *)fileItems toOriginalFilesFromVC:(UIViewController *)VC withCompletion:(savedcompletionWithItemsHandler)completion;
- (void)importOneLocalfileFromVC:(UIViewController *)VC;
- (void)importOriginalFilesDocumentFromVC:(UIViewController *)VC;
- (void)importShareOriginalFilesDocumentFromVC:(UIViewController *)VC;
- (void)importProtectNXLFilesDocumentFromVC:(UIViewController *)VC;
- (void)exportFile:(NXFileBase *)fileItem toOriginalFilesFromVC:(UIViewController *)VC;
- (void)exportMultipleFiles:(NSArray *)fileItems toOriginalFilesFromVC:(UIViewController *)VC;
- (void)deleteTheLocalFilesPath;
@end

