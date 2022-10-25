//
//  NXClassificationLab.h
//  nxrmc
//
//  Created by Eren on 14/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXClassificationLab : NSObject<NSCoding>
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign, getter=isDefaultLab) BOOL defaultLab;
@end
