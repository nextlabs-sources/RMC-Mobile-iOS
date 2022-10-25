//
//  NXPrintInteractionController.m
//  PrintWebView
//
//  Created by nextlabs on 7/24/15.
//
//

#import "NXPrintInteractionController.h"
#import "NXPrintPageRenderer.h"

static NXPrintInteractionController *sharedInstance = nil;

@interface NXPrintInteractionController()<UIPrintInteractionControllerDelegate>
@end

@implementation NXPrintInteractionController

+ (NXPrintInteractionController *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    _printer = [UIPrintInteractionController sharedPrintController];
    _printer.accessibilityValue = @"NXPRINTINTERACTION_CONTROLLER";
    return self;
}
- (BOOL)printObject:(id)printObj withOverlay:(NXOverlayTextInfo *)obligation
{
    if ([printObj isKindOfClass:[UIImage class]] || [printObj isKindOfClass:[UIViewPrintFormatter class]]) {
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        _printer.printInfo = printInfo;
        
        NXPrintPageRenderer *pageRenderer = nil;
        if ([printObj isKindOfClass:[UIImage class]]) {
            pageRenderer = [[NXPrintPageRenderer alloc] initWithObligation:obligation image:(UIImage *)printObj];
        }else if([printObj isKindOfClass:[UIViewPrintFormatter class]])
        {
            pageRenderer = [[NXPrintPageRenderer alloc] initWithObligation:obligation printFormat:(UIViewPrintFormatter *)printObj];
        }
        _printer.printPageRenderer = pageRenderer;
        _printer.delegate = self;
        
        return YES;
    }
    
    return NO;
    
}

#pragma mark - UIPrintInteractionControllerDelegate

- (void)printInteractionControllerWillStartJob:(UIPrintInteractionController *)printInteractionController {
    if (_delegate) {
        [self.delegate printInteractionControllerWillStartJob:printInteractionController];
    }
}
- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController {
    if (_delegate) {
        [self.delegate printInteractionControllerDidFinishJob:printInteractionController];
    }
}
@end
