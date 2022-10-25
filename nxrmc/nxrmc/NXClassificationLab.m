//
//  NXClassificationLab.m
//  nxrmc
//
//  Created by Eren on 14/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXClassificationLab.h"

@implementation NXClassificationLab
#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:[NSNumber numberWithBool:_defaultLab] forKey:@"defaultLab"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.defaultLab = [aDecoder decodeObjectForKey:@"defaultLab"];
    }
    return self;
}
@end
