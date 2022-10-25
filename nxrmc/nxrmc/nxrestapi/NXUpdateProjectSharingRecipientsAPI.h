//
//  NXUpdateProjectSharingRecipientsAPI.h
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2019/12/10.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"
@interface NXUpdateSharingRecipientsModel : NSObject
- (instancetype)initWithFile:(NXFileBase *)file addedRecipients:(NSArray *)addedRecipients removedRecipients:(NSArray *)removedRecipients comment:(NSString *)comment;
@property(nonatomic, strong) NSArray *addedRecipients;
@property(nonatomic, strong) NSArray *removedRecipients;
@property(nonatomic, strong) NXFileBase *file;
@property(nonatomic, strong) NSString *comment;
@end


@interface NXUpdateProjectSharingRecipientsRequest : NXSuperRESTAPIRequest

@end

@interface NXUpdateProjectSharingRecipientsAPIResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSArray *addedRecipients;
@property(nonatomic, strong) NSArray *removedRecipients;
@property(nonatomic, strong) NSArray *alreadySharingRecpipents;
@end
