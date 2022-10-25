//
//  NXLocalContactsVC.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/4/25.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXEmailContact : NSObject
@property(nonatomic, strong)NSString *fullName;
@property(nonatomic, strong)NSArray *emails;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end
@protocol NXLocalContactsVCDelegate <NSObject>
@optional
- (void)selectedEmail:(NSString *)emailStr;
- (void)cancelSelctedEmail;
@end
@interface NXLocalContactsVC : UIViewController
@property(nonatomic, assign)id<NXLocalContactsVCDelegate>delegate;
@end

