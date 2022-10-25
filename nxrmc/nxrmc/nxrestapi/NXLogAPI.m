//
//  NXLogAPI.m
//  nxrmc
//
//  Created by nextlabs on 7/14/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLogAPI.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "CHCSVParser.h"
#import "NXLProfile.h"
#import "NSData+zip.h"

@implementation NXLogAPIRequestModel
-(instancetype) init
{
    self = [super init];
    if (self) {
        _duid = @"";
        _owner = @"";
        _repositoryId = @"";
        _filePathId = @"";
        _fileName = @"";
        _filePath = @"";
        _activityData = @"";
    }
    
    return self;
    
}
@end

@implementation NXLogAPI

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    
    if (object && [object isKindOfClass:[NXLogAPIRequestModel class]]) {
        if (self.reqRequest == nil && object && [object isKindOfClass:[NXLogAPIRequestModel class]]) {
            NXLogAPIRequestModel *requestModel = (NXLogAPIRequestModel *)object;
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *filePath = [paths[0] stringByAppendingPathComponent:@"tempFile.csv"];
            NSString *encodedString = [UIDevice currentDevice].name;
//                           if (@available(iOS 9.0, *)) {
//                               NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
//                               NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
//                               encodedString = [[UIDevice currentDevice].name stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
//                           }else {
//                               encodedString = (NSString *)
//                               CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                                         (CFStringRef)[UIDevice currentDevice].name,
//                                                                                         NULL,
//                                                                                         (CFStringRef)@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ",
//                                                                                         kCFStringEncodingUTF8));
//                           }
            CHCSVWriter *csvWriter=[[CHCSVWriter alloc]initForWritingToCSVFile:filePath];
            
            [csvWriter writeField:requestModel.duid];
            [csvWriter writeField:requestModel.owner?:@""];
            [csvWriter writeField:[NXLoginUser sharedInstance].profile.userId];
            [csvWriter writeField:requestModel.operation];
            [csvWriter writeField:encodedString];
            [csvWriter writeField:[NXCommonUtils getPlatformId]];
            [csvWriter writeField:requestModel.repositoryId];
            [csvWriter writeField:requestModel.filePathId];
            [csvWriter writeField:requestModel.fileName];
            [csvWriter writeField:requestModel.filePath];
            [csvWriter writeField:APPLICATION_NAME];
            [csvWriter writeField:APPLICATION_PATH];
            [csvWriter writeField:APPLICATION_PUBLISHER];
            [csvWriter writeField:requestModel.accessResult];
            [csvWriter writeField:requestModel.accessTime];
            [csvWriter writeField:requestModel.activityData];
            [csvWriter finishLine];
            [csvWriter closeStream];
            
            NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
            NSData *gzCompressedData = [data gzip];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if([fileManager fileExistsAtPath:filePath])
            {
                if ([fileManager removeItemAtPath:filePath error:NULL]) {
                    NSLog(@"remove tempfile successfully");
                }
            }
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",str);
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [NXCommonUtils currentRMSAddress], @"rs/log/v2/activity"]]];
            [request setHTTPMethod:@"PUT"];
            [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Consume"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
            [request setValue:@"text/csv" forHTTPHeaderField:@"Consume"];
            
            [request setHTTPBody:gzCompressedData];
            
            [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
            
            self.reqRequest = request;
        }
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXLogAPIResponse *model = [[NXLogAPIResponse alloc]init];
        [model analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  model;
    };
    return analysis;
}

@end


@implementation NXLogAPIResponse

- (void)analysisResponseStatus:(NSData *)responseData {
    [self parseLogResponseJsonData: responseData];
}

- (void)parseLogResponseJsonData:(NSData *)data {
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"parse data failed:%@", error.localizedDescription);
        return;
    }
    if ([result objectForKey:@"statusCode"]) {
        self.rmsStatuCode = [[result objectForKey:@"statusCode"] integerValue];
    }
    
    if ([result objectForKey:@"message"]) {
        self.rmsStatuMessage = [result objectForKey:@"message"];
    }
}

@end
