//
//  NXFileItemCellDelegate.h
//  nxrmc
//
//  Created by nextlabs on 12/29/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NXFileItemCellDelegate <NSObject>

- (void)nxfileItemWillEndSwiping:(id)cell;
- (void)nxfileItemWillBeginSwiping:(id)cell;

@end
