//
//  NXPerformPolicyEvaluationAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 15/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXPerformPolicyEvaluationAPI.h"
#import "NXCommonUtils.h"
#import "NXLRights.h"
#import "NXRMCDef.h"
@implementation NXPerformPolicyEvaluationAPIRequest
-(NSURLRequest *) generateRequestObject:(id) object {
    
    if (self.reqRequest == nil)
    {
        NSDictionary *dic = object;
        NSString *memberShipId = [dic objectForKey:MEMBER_SHIP_ID];
        NSString *resourceName = [dic objectForKey:RESOURCE_NAME];
        NSString *duid = [dic objectForKey:DUIDKEY];
        NSNumber *rights = [dic objectForKey:RIGHTS];
        NSString *userId = [dic objectForKey:USERID];
        NSNumber *evalType = [dic objectForKey:EVALTYPE];
        NSArray *categoriesArray = [dic objectForKey:CATEGORIES_ARRAY];
//        NSString *applicationName = [dic objectForKey:EVAL_NAME];
        
        NSMutableDictionary *classificationContentDic = [NSMutableDictionary new];
        for (NXClassificationCategory *categoryItem in categoriesArray) {
            if (categoryItem.name && categoryItem.selectedLabs.count >0) {
                NSMutableArray *temp = [[NSMutableArray alloc] init];
                for (NXClassificationLab *lab in categoryItem.selectedLabs) {
                    [temp addObject:lab.name];
                }
                [classificationContentDic setValue:temp.copy forKey:categoryItem.name];
            }
        }
        
        NSMutableDictionary *resourceDicContent = [NSMutableDictionary new];
        [resourceDicContent setValue:@"from" forKey:@"dimensionName"];
        [resourceDicContent setValue:@"fso" forKey:@"resourceType"];
        [resourceDicContent setValue:resourceName forKey:RESOURCE_NAME];
        if (duid && ![duid isEqualToString:@""]) {
            [resourceDicContent setValue:duid forKey:DUIDKEY];
        }
        [resourceDicContent setValue:classificationContentDic forKey:@"classification"];
        
        NSMutableDictionary *evalRequestContentDic = [NSMutableDictionary new];
        [evalRequestContentDic setValue:@"Policy body" forKey:@"adhocPolicy"];
        [evalRequestContentDic setValue:memberShipId forKey:MEMBER_SHIP_ID];
        [evalRequestContentDic setValue:@[resourceDicContent] forKey:@"resources"];
        [evalRequestContentDic setValue:rights forKey:RIGHTS];
        [evalRequestContentDic setValue:@{@"id":userId} forKey:@"user"];
        [evalRequestContentDic setValue:evalType forKey:@"evalType"];
       
//        [evalRequestContentDic setValue:@{} forKey:@"host"];
//        [evalRequestContentDic setValue:@{} forKey:@"application"];
//        NSString *bundlePath = [NSBundle mainBundle].bundlePath;
//        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
//        NSString *appCurName = [infoDic objectForKey:@"CFBundleDisplayName"];
        [evalRequestContentDic setValue:@{@"name":APPLICATION_NAME,@"path":APPLICATION_PATH,@"attributes":@{@"publisher":@[APPLICATION_PUBLISHER,@"v1"],@"licensed":@[@"yes"]}} forKey:@"application"];
        [evalRequestContentDic setValue:@{@"ipAddress":[NXCommonUtils getCurrentIpAdress],@"attributes":@{@"hostname":@[[NXCommonUtils getCurretnHostName]]}} forKey:@"host"];
//        [evalRequestContentDic setValue:@{@"ipAddress":@"10.63.0.208",@"attributes":@{@"hostname":@[@"rms.nextlabs.com"]}} forKey:@"host"];
//        [evalRequestContentDic setValue:@{@"environments":@[@{@"name":@"environment",@"attributes":@{@"connection_type":@[@"console"]}}]} forKey:@"application"];
        NSDictionary *parametersDic = @{@"parameters":@{@"evalRequest":evalRequestContentDic}};
        
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:parametersDic options:NSJSONWritingPrettyPrinted error:&error];
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@/rs/policyEval",[NXCommonUtils currentRMSAddress]]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError* error) {
        NXPerformPolicyEvaluationAPIResponse *response=[[NXPerformPolicyEvaluationAPIResponse alloc]init];
        NSData *backData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (backData) {
            [response analysisResponseStatus:backData];
            NSDictionary *returnDic =[NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = returnDic[@"results"];
            if (resultsDic.count > 0) {
                response.rights = resultsDic[@"rights"];
                response.evaluationRight = [[NXLRights alloc] init];
                [response.evaluationRight setRights:response.rights.longValue];
                
                response.obligations = resultsDic[@"obligations"];
                if (response.obligations.count > 0) {
                    NSDictionary *overlayInfoDict = nil;
                    for (NSDictionary *ob in response.obligations) {
                        if ([ob[@"name"] isEqualToString:@"OB_OVERLAY"]) {
                            overlayInfoDict = ob;
                            break;
                        }
                    }
                    
                    if (overlayInfoDict) {
                        NSArray *attributes = overlayInfoDict[@"attributes"];
                        NSString *waterMarkString = nil;
                        for (NSDictionary *attribute in attributes) {
                            if ([attribute[@"name"] isEqualToString:@"Text"]) {
                                waterMarkString = attribute[@"value"];
                                break;
                            }
                        }
                        if (waterMarkString) {
                            [response.evaluationRight setWatermarkString:waterMarkString];
                        }
                    }
                }
                response.adhocObligations = resultsDic[@"adhocObligations"];
            }
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXPerformPolicyEvaluationAPIResponse
-(instancetype)init
{
    self = [super init];
    if (self) {
        _obligations = [[NSArray alloc] init];
        _adhocObligations = [[NSArray alloc] init];
    }
    return self;
}
@end

