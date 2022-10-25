//
//  NXClassificationCategory.h
//  nxrmc
//
//  Created by Eren on 14/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXClassificationLab.h"

@interface NXClassificationCategory : NSObject<NSCoding>
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign, getter=isMultiSelect) BOOL multiSelect;
@property(nonatomic, assign, getter=isMandatory) BOOL mandatory;
@property(nonatomic, strong) NSArray<NXClassificationLab *> *labs;
@property(nonatomic, strong) NSMutableArray<NXClassificationLab *> *selectedLabs;
@property(nonatomic, strong) NSMutableArray *selectedItemPostions;
@end
