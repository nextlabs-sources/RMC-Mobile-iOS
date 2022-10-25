//
//  NXDropboxFileListAPI.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 07/12/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXDropboxFileListAPI.h"
#import "NXCommonUtils.h"

@implementation NXDropboxFileItem
@end

@implementation NXDropboxFileListAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSURL *apiURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://api.dropbox.com/2/files/list_folder"]];
        NSError *error;
        NSString *path = object;
        NSDictionary *jDict = @{@"path":path,@"include_media_info":[NSNumber numberWithBool:false],@"include_deleted":[NSNumber numberWithBool:false],@"include_has_explicit_shared_members":[NSNumber numberWithBool:false],@"recursive":[NSNumber numberWithBool:false]};
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jDict options:NSJSONWritingPrettyPrinted error:&error];
        
        if (self.cursor) {
            apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://api.dropboxapi.com/2/files/list_folder/continue"]];
            NSDictionary *jdict = @{@"cursor":self.cursor};
            bodyData = [NSJSONSerialization dataWithJSONObject:jdict options:NSJSONWritingPrettyPrinted error:&error];
        }

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:bodyData];
        self.reqRequest=request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXDropboxFileListAPIResponse *apiResponse = [[NXDropboxFileListAPIResponse alloc]init];
        NSData *resultData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (resultData) {
            [apiResponse analysisResponseStatus:resultData];
            if (!error) {
                NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
                NSArray *filseArray = returnDic[@"entries"];
                
                //            ".tag" = file;
                //            "client_modified" = "2017-07-20T01:53:58Z";
                //            "content_hash" = 47682c0d9902f5ea9e0162f09c112d6ed85a90a9d8afaa00a5c207d3bfa231c6;
                //            id = "id:ASkexhTVjqAAAAAAAAAAGQ";
                //            name = "Screenshot-2017-07-19-08-01-34.jpg.nxl";
                //            "path_display" = "/Screenshot-2017-07-19-08-01-34.jpg.nxl";
                //            "path_lower" = "/screenshot-2017-07-19-08-01-34.jpg.nxl";
                //            rev = 195926bb90;
                //            "server_modified" = "2017-07-20T01:53:59Z";
                //            size = 54272;
                
                
                for (NSDictionary *fileItemDic in filseArray) {
                    @autoreleasepool {
                        if (fileItemDic.count > 0) {
                            NXDropboxFileItem *item = [[NXDropboxFileItem alloc] init];
                            
                            item.id_ = fileItemDic[@"id"];
                            item.name = fileItemDic[@"name"];
                            item.tag = fileItemDic[@".tag"];
                            item.size = fileItemDic[@"size"];
                            item.serverModified = [self deserialize:fileItemDic[@"server_modified"] dateFormat:@"%Y-%m-%dT%H:%M:%SZ"];
                            item.pathDisplay = fileItemDic[@"path_display"];
                            item.clientModified = [self deserialize:fileItemDic[@"client_modified"] dateFormat:@"%Y-%m-%dT%H:%M:%SZ"];
                            [apiResponse.files addObject:item];
                        }
                    }
                }
                
                apiResponse.hasMore = returnDic[@"has_more"];
                if (apiResponse.hasMore) {
                    apiResponse.cursor = returnDic[@"cursor"];
                }
//                NSLog(@"%@",filseArray);
            }
            else if (error.code == 401)
            {
               apiResponse.isAccessTokenExpireError = YES;
            }
        }
        return apiResponse;
    };
    return analysis;
}

- (NSDate *)deserialize:(NSString *)value dateFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:[self convertFormat:dateFormat]];
    
    return [formatter dateFromString:value];
}

- (NSString *)convertFormat:(NSString *)format {
    NSCharacterSet *alphabeticSet =
    [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSMutableString *newFormat = [@"" mutableCopy];
    BOOL inQuotedText = NO;
    
    NSUInteger len = [format length];
    
    NSUInteger i = 0;
    while (i < len) {
        char ch = [format characterAtIndex:i];
        if (ch == '%') {
            if (i >= len - 1) {
                return nil;
            }
            i++;
            ch = [format characterAtIndex:i];
            NSString *token = [NSString stringWithFormat:@"%%%c", ch];
            if (inQuotedText) {
                [newFormat appendString:@"'"];
                inQuotedText = NO;
            }
            [newFormat appendString:[self formatDateToken:token]];
        } else {
            if ([alphabeticSet characterIsMember:ch]) {
                if (!inQuotedText) {
                    [newFormat appendString:@"'"];
                    inQuotedText = YES;
                }
            } else if (ch == '\'') {
                [newFormat appendString:@"'"];
            }
            [newFormat appendString:[NSString stringWithFormat:@"%c", ch]];
        }
        i++;
    }
    if (inQuotedText) {
        [newFormat appendString:@"'"];
    }
    
    return newFormat;
}

- (NSString *)formatDateToken:(NSString *)token {
    NSString *result = @"";
    
    if ([token isEqualToString:@"%a"]) { // Weekday as locale's abbreviated name.
        result = @"EEE";
    } else if ([token isEqualToString:@"%A"]) { // Weekday as locale's full name.
        result = @"EEE";
    } else if ([token isEqualToString:@"%w"]) { // Weekday as a decimal number, where 0 is Sunday and 6 is Saturday. 0, 1,
        // ..., 6
        result = @"ccccc";
    } else if ([token isEqualToString:@"%d"]) { // Day of the month as a zero-padded decimal number. 01, 02, ..., 31
        result = @"dd";
    } else if ([token isEqualToString:@"%b"]) { // Month as locale's abbreviated name.
        result = @"MMM";
    } else if ([token isEqualToString:@"%B"]) { // Month as locale's full name.
        result = @"MMMM";
    } else if ([token isEqualToString:@"%m"]) { // Month as a zero-padded decimal number. 01, 02, ..., 12
        result = @"MM";
    } else if ([token isEqualToString:@"%y"]) { // Year without century as a zero-padded decimal number. 00, 01, ..., 99
        result = @"yy";
    } else if ([token isEqualToString:@"%Y"]) { // Year with century as a decimal number. 1970, 1988, 2001, 2013
        result = @"yyyy";
    } else if ([token isEqualToString:@"%H"]) { // Hour (24-hour clock) as a zero-padded decimal number. 00, 01, ..., 23
        result = @"HH";
    } else if ([token isEqualToString:@"%I"]) { // Hour (12-hour clock) as a zero-padded decimal number. 01, 02, ..., 12
        result = @"hh";
    } else if ([token isEqualToString:@"%p"]) { // Locale's equivalent of either AM or PM.
        result = @"a";
    } else if ([token isEqualToString:@"%M"]) { // Minute as a zero-padded decimal number. 00, 01, ..., 59
        result = @"mm";
    } else if ([token isEqualToString:@"%S"]) { // Second as a zero-padded decimal number. 00, 01, ..., 59
        result = @"ss";
    } else if ([token isEqualToString:@"%f"]) { // Microsecond as a decimal number, zero-padded on the left. 000000,
        // 000001, ..., 999999
        result = @"SSSSSS";
    } else if ([token isEqualToString:@"%z"]) { // UTC offset in the form +HHMM or -HHMM (empty string if the the object
        // is naive). (empty), +0000, -0400, +1030
        result = @"Z";
    } else if ([token isEqualToString:@"%Z"]) { // Time zone name (empty string if the object is naive). (empty), UTC,
        // EST, CST
        result = @"z";
    } else if ([token isEqualToString:@"%j"]) { // Day of the year as a zero-padded decimal number. 001, 002, ..., 366
        result = @"DDD";
    } else if ([token isEqualToString:@"%U"]) { // Week number of the year (Sunday as the first day of the week) as a zero
        // padded decimal number. All days in a new year preceding the first
        // Sunday are considered to be in week 0. 00, 01, ..., 53 (6)
        result = @"ww";
    } else if ([token isEqualToString:@"%W"]) { // Week number of the year (Monday as the first day of the week) as a
        // decimal number. All days in a new year preceding the first Monday are
        // considered to be in week 0. 00, 01, ..., 53 (6)
        result = @"ww";
    } else if ([token isEqualToString:@"%c"]) { // Locale's appropriate date and time representation.
        result = @"";                            // unsupported
    } else if ([token isEqualToString:@"%x"]) { // Locale's appropriate date representation.
        result = @"";                            // unsupported
    } else if ([token isEqualToString:@"%X"]) { // Locale's appropriate time representation.
        result = @"";                            // unsupported
    } else if ([token isEqualToString:@"%%"]) { // A literal '%' character.
        result = @"";
    } else if ([token isEqualToString:@"%"]) {
        result = @"";
    } else {
        result = @"";
    }
    
    return result;
}


@end

@implementation NXDropboxFileListAPIResponse

- (id)init
{
    self = [super init];
    if (self) {
        _files = [[NSMutableArray alloc] init];
    }
    return self;
}

@end

