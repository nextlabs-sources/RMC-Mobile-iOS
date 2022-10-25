//
//  NXProjectBaseVC.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/8/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectBaseVC.h"

#import "NXRMCDef.h"

@interface NXProjectBaseVC ()

@end

@implementation NXProjectBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseProjectModelUpdated:) name:NOTIFICATION_PROJECT_MEMBER_UPDATED object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
- (void)responseProjectModelUpdated:(NSNotification *)notification {
//    assert(1); // the sub class must override this method. 
}

@end
