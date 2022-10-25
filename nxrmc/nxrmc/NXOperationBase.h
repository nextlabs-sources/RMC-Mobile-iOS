//
//  NXOperationBase.h
//  nxrmc
//
//  Created by EShi on 1/22/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXOperationBase : NSOperation

// must called by subcalss when it's work finished
-(void)finish:(NSError *) error;

// need overwrite by subclasses
/**
 Purpose: called when operation started, do really task logic
 
 @param error The error return if there is any error during task logic.
 */
- (void)executeTask:(NSError **)error;

/**
 Purpose: called when operation finished, do yourself work end
 
 @param error The error happened when doing operation logic.
 */
- (void)workFinished:(NSError *)error;

/**
 Purpose: called when operation to be canceled, do yourself work cancel
 
 @param error The error stand for cancell error.
 */
- (void)cancelWork:(NSError *)cancelError;
@end
