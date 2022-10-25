//
//  NXGetClassificationProfileAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 15/03/2018.
//  Copyright © 2018 nextlabs. All rights reserved.
//

#import "NXGetClassificationProfileAPI.h"
#import "NSString+Utility.h"

@implementation NXGetClassificationProfileAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        if (object) {
            NSString *tokenGroupName = object;
            tokenGroupName = [tokenGroupName toHTTPURLString];
            NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/classification/%@",[NXCommonUtils currentRMSAddress],tokenGroupName]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            self.reqRequest = request;
        }
    }
    return self.reqRequest;
}

/**
 Produces: application/json
 
 {
 "statusCode": 200,
 "message": "OK",
 "serverTime": 1484060079827,
 "results": {
 "maxCategoryNum": 5,
 "maxLabelNum": 10,
 "categories":[
         {
             "name": "Sensitivity",
             "multiSelect": true,
             "mandatory": true,
             "labels": [
                 {
                 "name": "Non-Business",
                 "default":true
                 },
                 {
                 "name": "General Business"
                 },
                 {
                 "name": "Confidential"
                 }
             ]
         },
     {
         "name": "Project",
         "multi-select": false,
         "mandatory": true,
         "labels": [
             {
             "name": "Project"
             }
         ]
      }
     ]
    }
 }
 */

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        NXGetClassificationProfileAPIResponse *response = [[NXGetClassificationProfileAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [response analysisResponseStatus:resultData];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultsDic = dic[@"results"];
            NSArray *categoriesArray = resultsDic[@"categories"];
            NSMutableArray *categoriesArr = [NSMutableArray array];
            
            for (NSDictionary *categoriesItemsDic in categoriesArray) {
                NXClassificationCategory *category = [[NXClassificationCategory alloc] init];
                NSNumber *multiselect = categoriesItemsDic[@"multiSelect"];
                NSNumber *mandatory = categoriesItemsDic[@"mandatory"];
                category.name = categoriesItemsDic[@"name"];
                category.multiSelect = multiselect.boolValue;
                category.mandatory = mandatory.boolValue;
                
                NSArray *labelsArray = categoriesItemsDic[@"labels"];
                NSMutableArray *labelsArr = [NSMutableArray new];
                if (labelsArray.count > 0) {
                    for (NSDictionary *labelsItemDic in labelsArray) {
                        NXClassificationLab *lab = [[NXClassificationLab alloc] init];
                        NSNumber *isDefault = labelsItemDic[@"default"];
                        lab.name = labelsItemDic[@"name"];
                        lab.defaultLab = isDefault.boolValue;
                        [labelsArr addObject:lab];
                    }
                }
                category.labs = [labelsArr copy];
                [categoriesArr addObject:category];
            }
            response.returndCategoriesArray = categoriesArr;
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXGetClassificationProfileAPIResponse

-(NSMutableArray*)returndCategoriesArray {
    if (!_returndCategoriesArray) {
        _returndCategoriesArray = [[NSMutableArray alloc] init];
    }
    return _returndCategoriesArray;
}

@end
