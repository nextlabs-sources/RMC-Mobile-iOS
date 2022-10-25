//
//  NSString+AES256.h
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 2018/8/9.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AES256)
- (NSString *)AES256ParmEncryptWithKey:(NSString *)key;
- (NSString *)AES256ParmDecryptWithKey:(NSString *)key;
@end
