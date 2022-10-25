//
//  DetailViewController.h
//  nxrmc_hd
//
//  Created by EShi on 7/21/15.
//  Copyright (c) 2015 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXFileBase;
@class NXBoundService;
@class DetailViewController;

@protocol DetailViewControllerDelegate <NSObject>
@optional
- (void)detailViewController:(DetailViewController *)detailVC SwipeToPreFileFrom:(NXFileBase *)file;
- (void)detailViewController:(DetailViewController *)detailVC SwipeToNextFileFrom:(NXFileBase *)file;
- (void)afterOpenFile;
@end

@interface DetailViewController : UIViewController<UISplitViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NXFileBase* curFile;
@property (nonatomic, strong) NSString *curNXLFileOwner;
@property (nonatomic, strong) NSString *curNXLFileDUID;
@property (nonatomic, weak) NXBoundService* curService;
@property (nonatomic, weak) id<DetailViewControllerDelegate> delegate;

- (void)openFile:(NXFileBase *)file;
- (void)openFileForPreview:(NXFileBase *)file;
-(void) showAutoDismissLabel:(NSString *) labelContent;
@end


