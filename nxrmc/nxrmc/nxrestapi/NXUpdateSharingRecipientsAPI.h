//
//  NXUpdateSharingRecipientsAPI.h
//  nxrmc
//
//  Created by Eren (Teng) Shi on 7/5/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXSuperRESTAPI.h"

@interface NXUpdateSharingRecipientsReqModel : NSObject
- (instancetype)initWithFile:(NXMyVaultFile *)file addedRecipients:(NSArray *)addedRecipients removedRecipients:(NSArray *)removedRecipients comment:(NSString *)comment;
@property(nonatomic, strong) NSArray *addedRecipients;
@property(nonatomic, strong) NSArray *removedRecipients;
@property(nonatomic, strong) NXMyVaultFile *file;
@property(nonatomic, strong) NSString *comment;
@end

@interface NXUpdateSharingRecipientsRequest : NXSuperRESTAPIRequest

@end

@interface NXUpdateSharingRecipientsResponse : NXSuperRESTAPIResponse
@property(nonatomic, strong) NSArray *addedRecipients;
@property(nonatomic, strong) NSArray *removedRecipients;
@end
