//
//  NXPrintInteractionController.h
//  PrintWebView
//
//  Created by nextlabs on 7/24/15.
//
//

#import <UIKit/UIKit.h>
#import "NXOverlayTextInfo.h"

@interface NXPrintInteractionController : NSObject

@property (nonatomic, assign, readonly) UIPrintInteractionController *printer;

@property (nonatomic, weak) id<UIPrintInteractionControllerDelegate> delegate;

+ (NXPrintInteractionController *)sharedInstance;
- (BOOL)printObject:(id)printObj withOverlay:(NXOverlayTextInfo *)obligation;
@end
