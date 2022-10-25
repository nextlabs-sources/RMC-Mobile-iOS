//
//  NXDocunmentFilesTransfer.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/3/31.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXOriginalFilesTransfer.h"
#import "NXFile.h"
#import <UIKit/UIKit.h>
@interface NXOriginalFilesTransfer ()<UIDocumentPickerDelegate>
@property(nonatomic, strong)NSMutableArray *excludeActivityTypes;
@property(nonatomic, strong)UIViewController *currentVC;
@property(nonatomic, strong)NSString *localTmpPath;
@property(nonatomic, assign)BOOL allowsMultipleSelection;
@end
 static NXOriginalFilesTransfer *_filesTransfer = nil;
@implementation NXOriginalFilesTransfer
+ (instancetype)sharedIInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _filesTransfer = [[self alloc] init];
    });
    return _filesTransfer;
    
}
- (NSString *)localTmpPath{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *tmpPath = [docPath stringByAppendingPathComponent:@"Files"];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return tmpPath;
}
-(NSMutableArray *)excludeActivityTypes{
    if (!_excludeActivityTypes) {
        _excludeActivityTypes = [NSMutableArray arrayWithArray:@[UIActivityTypePostToFacebook,
                                                                        UIActivityTypePostToTwitter,
                                                                        UIActivityTypePostToWeibo,
                                                                        UIActivityTypeMessage,
                                                                        UIActivityTypeMail,
                                                                        UIActivityTypePrint,
                                                                        UIActivityTypeCopyToPasteboard,
                                                                        UIActivityTypeAssignToContact,
                                                                        UIActivityTypeSaveToCameraRoll,
                                                                        UIActivityTypeAddToReadingList,
                                                                        UIActivityTypePostToFlickr,
                                                                        UIActivityTypePostToVimeo,
                                                                        UIActivityTypePostToTencentWeibo,
                                                                        UIActivityTypeAirDrop,
                                                                        UIActivityTypeOpenInIBooks]];
        if (@available(iOS 11.0, *)) {
            [_excludeActivityTypes addObject:UIActivityTypeMarkupAsPDF];
            
        }
    }
  
    return _excludeActivityTypes;

}
- (BOOL)saveFile:(NXFileBase *)fileItem toOriginalFilesFromVC:(UIViewController *)VC withCompletion:(savedcompletionWithItemsHandler)completion {
    if (!fileItem.localPath) {
      return NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      NSURL *shareUrl = [NSURL fileURLWithPath:fileItem.localPath];
         
         NSArray *activityItems = @[shareUrl];
         UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                                                         initWithActivityItems:activityItems
                                                                         applicationActivities:nil];
         activityVC.excludedActivityTypes = self.excludeActivityTypes;
         activityVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
         activityVC.completionWithItemsHandler = ^(UIActivityType   activityType,BOOL completed,
                                                                            NSArray *  returnedItems,
                                                                            NSError *  activityError) {
             if (completion) {
                 completion(activityType,completed,returnedItems,activityError);
             }
            
         };
         [VC presentViewController:activityVC animated:YES completion:nil];
        
    
    });
   
    return YES;
}
- (void)importOneLocalfileFromVC:(UIViewController *)VC {
    self.currentVC = VC;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDocumentPickerViewController *pickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data",@"public.source-code",@"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt",@"public.archive",@"public.movie"] inMode:UIDocumentPickerModeImport];
        pickerVC.delegate = self;
        if (@available(iOS 11.0, *)) {
            pickerVC.allowsMultipleSelection = NO;
            self.allowsMultipleSelection = NO;
        } else {
            // Fallback on earlier versions
        }
        if (@available(iOS 13.0, *)) {
            pickerVC.shouldShowFileExtensions = YES;
        } else {
            // Fallback on earlier versions
        }
        pickerVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [VC presentViewController:pickerVC animated:YES completion:nil];
    });
    
}
- (void)importOriginalFilesDocumentFromVC:(UIViewController *)VC {
    self.currentVC = VC;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDocumentPickerViewController *pickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data",@"public.source-code", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt",@"public.archive",@"public.movie"] inMode:UIDocumentPickerModeImport];
        pickerVC.delegate = self;
        if (@available(iOS 11.0, *)) {
            pickerVC.allowsMultipleSelection = YES;
            self.allowsMultipleSelection = YES;
        } else {
            // Fallback on earlier versions
        }
        if (@available(iOS 13.0, *)) {
            pickerVC.shouldShowFileExtensions = YES;
        } else {
            // Fallback on earlier versions
        }
        pickerVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [VC presentViewController:pickerVC animated:YES completion:nil];
    });
}
- (void)importShareOriginalFilesDocumentFromVC:(UIViewController *)VC {
    self.currentVC = VC;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDocumentPickerViewController *pickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.source-code", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt",@"public.archive",@"public.movie"] inMode:UIDocumentPickerModeImport];
        pickerVC.delegate = self;
        if (@available(iOS 11.0, *)) {
            pickerVC.allowsMultipleSelection = NO;
            self.allowsMultipleSelection = NO;
        } else {
            // Fallback on earlier versions
        }
        if (@available(iOS 13.0, *)) {
            pickerVC.shouldShowFileExtensions = YES;
        } else {
            // Fallback on earlier versions
        }
        pickerVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [VC presentViewController:pickerVC animated:YES completion:nil];
    });
}
- (void)importProtectNXLFilesDocumentFromVC:(UIViewController *)VC {
    self.currentVC = VC;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDocumentPickerViewController *pickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"com.skydrm.rmc-entprise.nxl"] inMode:UIDocumentPickerModeImport];
        pickerVC.delegate = self;
        if (@available(iOS 11.0, *)) {
            pickerVC.allowsMultipleSelection = NO;
            self.allowsMultipleSelection = NO;
        } else {
            // Fallback on earlier versions
        }
        if (@available(iOS 13.0, *)) {
            pickerVC.shouldShowFileExtensions = YES;
        } else {
            // Fallback on earlier versions
        }
        pickerVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [VC presentViewController:pickerVC animated:YES completion:nil];
    });
}

- (void)exportFile:(NXFileBase *)fileItem toOriginalFilesFromVC:(UIViewController *)VC {
    self.currentVC = VC;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *shareUrl = [NSURL fileURLWithPath:fileItem.localPath];
        UIDocumentPickerViewController *documentVC = [[UIDocumentPickerViewController alloc] initWithURL:shareUrl inMode:UIDocumentPickerModeExportToService];
        documentVC.delegate = self;
        if (@available(iOS 13.0, *)) {
            documentVC.shouldShowFileExtensions = YES;
        } else {
            // Fallback on earlier versions
        }
        documentVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [VC presentViewController:documentVC animated:YES completion:nil];
        
    });
}
- (void)exportMultipleFiles:(NSArray *)fileItems toOriginalFilesFromVC:(UIViewController *)VC {
    self.currentVC = VC;
    NSMutableArray *urlArray = [NSMutableArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NXFileBase *fileModel in fileItems) {
            NSURL *shareUrl = [NSURL fileURLWithPath:fileModel.localPath];
            [urlArray addObject:shareUrl];
        }
        if (@available(iOS 11.0, *)) {
            UIDocumentPickerViewController *documentVC = [[UIDocumentPickerViewController alloc] initWithURLs:urlArray inMode:UIDocumentPickerModeExportToService];
            documentVC.delegate = self;
            if (@available(iOS 13.0, *)) {
                documentVC.shouldShowFileExtensions = YES;
            } else {
                // Fallback on earlier versions
            }
            documentVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [VC presentViewController:documentVC animated:YES completion:nil];
        } else {
            // Fallback on earlier versions
        }
        
    });
}
#pragma mark ------> delegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
   
     if (controller.documentPickerMode == UIDocumentPickerModeImport) {
         NSMutableArray *fileArray = [NSMutableArray array];
         for (NSURL *url in urls) {
             if ([url isFileURL]) {
                 NSFileManager *fileManager = [NSFileManager defaultManager];
                 if ([fileManager fileExistsAtPath:url.path]) {
                     NSData *fileData = [fileManager contentsAtPath:url.path];
                     if (fileData && fileData.length > 0) {
                         NSString *fileName = [url.path lastPathComponent];
                         NSString *filePath = [self.localTmpPath stringByAppendingPathComponent:fileName];
                         if ([fileManager createFileAtPath:filePath contents:fileData attributes:nil]) {
                             NXFile *fileItem = [[NXFile alloc] init];
                             fileItem.name = [self removeTheNumericSuffixAfterTheFileFormat:fileName];
                             fileItem.localPath = filePath;
                             fileItem.fullPath = filePath;
                             fileItem.fullServicePath = filePath;
                             fileItem.repoId = @"Files";
                             fileItem.serviceAlias = @"Files";
                             fileItem.size = fileData.length;
                             fileItem.sorceType = NXFileBaseSorceTypeLocalFiles;
                             [fileArray addObject:fileItem];
                             if (!self.allowsMultipleSelection && self.improtFileCompletion) {
                                 self.improtFileCompletion(self.currentVC,fileItem,fileData, nil);
                             }
                             
                         }
                     }else{
                         NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:261 userInfo:@{NSLocalizedDescriptionKey:@"Fail to import file,please try again."}];
                         if (!self.allowsMultipleSelection && self.improtFileCompletion) {
                             self.improtFileCompletion(self.currentVC,nil,nil, error);
                         }
                     }
                    
                 }
                
             }else{
                 NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:261 userInfo:@{NSLocalizedDescriptionKey:@"Fail to read file"}];
                 if (!self.allowsMultipleSelection && self.improtFileCompletion) {
                     self.improtFileCompletion(self.currentVC,nil, nil, error);
                 }
             }
             
         }
         
             if (self.allowsMultipleSelection && self.improtMultipleFileCompletion) {
                 self.improtMultipleFileCompletion(self.currentVC,fileArray, nil);
             }
        
    
     }else if (controller.documentPickerMode == UIDocumentPickerModeExportToService){
         
         if (self.exprotFileCompletion) {
             self.exprotFileCompletion(self.currentVC, urls.firstObject, nil);
         }
         if (self.exprotMultipleFilesCompletion) {
             self.exprotMultipleFilesCompletion(self.currentVC, urls, nil);
         }
     }
}
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if (self.cancelCompletion) {
        self.cancelCompletion(self.currentVC);
    }
    
}
- (void)deleteTheLocalFilesPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.localTmpPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.localTmpPath error:nil];
    }
}


- (NSString *)removeTheNumericSuffixAfterTheFileFormat:(NSString *)fileName {
    NSString *realName = fileName;
    if ([realName containsString:@".nxl"]) {
        realName = [realName stringByDeletingPathExtension];
        NSArray *stringArray = [realName componentsSeparatedByString:@"."];
        NSString *fileExtension = stringArray.lastObject;
        if ([fileExtension containsString:@" "]) {
            realName = [realName stringByReplacingOccurrencesOfString:fileExtension withString:@""];
            NSRange range = [fileExtension rangeOfString:@" "];
            NSRange newRange = NSMakeRange(range.location, fileExtension.length-range.location);
            fileExtension = [fileExtension stringByReplacingCharactersInRange:newRange withString:@""];
            
            realName = [realName stringByAppendingFormat:@"%@", fileExtension];
        }
        realName = [realName stringByAppendingPathExtension:@"nxl"];
    }
    return realName;
}
@end
