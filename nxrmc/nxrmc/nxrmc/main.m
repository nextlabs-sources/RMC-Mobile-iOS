//
//  main.m
//  nxrmc
//
//  Created by Kevin on 15/4/28.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <dlfcn.h>

int main(int argc, char * argv[]) {
#ifndef DEBUG
// Deny Remote debug, in case code reverse
#ifdef __arm__
    asm volatile(
                 "mov r0,#31\n"
                 "mov r1,#0\n"
                 "mov r2,#0\n"
                 "mov r12,#26\n" // ptrace
                 "svc #80\n"
                 );
    #endif
    #ifdef __arm64__
    asm volatile(
                 "mov x0,#26\n"
                 "mov x1,#31\n"
                 "mov x2,#0\n"
                 "mov x3,#0\n"
                 "mov x16,#0\n" // syscall
                 "svc #128\n"
                 );
    #endif
#endif
    @autoreleasepool {
          return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
