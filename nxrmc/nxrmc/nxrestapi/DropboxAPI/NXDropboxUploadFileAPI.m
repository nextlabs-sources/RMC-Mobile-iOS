//
//  NXDropboxUploadFileAPI.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 2020/5/7.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXDropboxUploadFileAPI.h"
#import "NXDropboxFileListAPI.h"
@interface NXDropboxUploadFileAPIRequest ()
@end
@implementation NXDropboxUploadFileAPIRequest
- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSString *filePath = object[@"path"];
        NSData *fileData = object[@"fileData"];
       
        if (fileData && filePath) {
            NSDictionary *jDict = @{@"path":filePath,@"mode":@"overwrite",@"autorename":[NSNumber numberWithBool:false],@"mute":[NSNumber numberWithBool:false],@"strict_conflict":[NSNumber numberWithBool:false]};
            NSData *bodyData =  [self jsonDataWithJsonObj:jDict];
            NSString *headerStr = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
                  
            NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://content.dropboxapi.com/2/files/upload"]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
            [request setValue:headerStr forHTTPHeaderField:@"Dropbox-API-Arg"];
            [request setHTTPBody:fileData];
            self.reqRequest = request;
            
        }
       
            
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
  
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXDropboxUploadFileAPIResponse *apiResponse = [[NXDropboxUploadFileAPIResponse alloc]init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData = (NSData*)returnData;
           
        }
        
        if (contentData)
        {
            NSError *error;
            NSDictionary *fileItemDic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableLeaves error:&error];
          
            [apiResponse analysisResponseStatus:contentData];
            if (!error) {
                NXDropboxFileItem *item = [[NXDropboxFileItem alloc] init];
                                           
                item.id_ = fileItemDic[@"id"];
                item.name = fileItemDic[@"name"];
                item.size = fileItemDic[@"size"];
                item.pathDisplay = fileItemDic[@"path_display"];
                item.serverModified = [self deserialize:fileItemDic[@"server_modified"] dateFormat:@"%Y-%m-%dT%H:%M:%SZ"];
                item.clientModified = [self deserialize:fileItemDic[@"client_modified"] dateFormat:@"%Y-%m-%dT%H:%M:%SZ"];
                apiResponse.fileItem = item;
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

- (NSData *)jsonDataWithJsonObj:(id)jsonObj {
    if (!jsonObj) {
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&error];
    
    if (!jsonData) {
        NSLog(@"Error serializing dictionary: %@", error.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
}
@end
@implementation NXDropboxUploadFileAPIResponse

@end
@implementation NXDropboxUploadFileStartAPIRequest
- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        NSURL *apiURL=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://content.dropboxapi.com/2/files/upload_session/start"]];
        NSDictionary *jDict = @{@"close":[NSNumber numberWithBool:false]};
        NSData *bodyData =  [self jsonDataWithJsonObj:jDict];
        NSString *headerStr = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
        [request setValue:headerStr forHTTPHeaderField:@"Dropbox-API-Arg"];
        self.reqRequest = request;
                
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
  
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXDropboxUploadFileStartAPIResponse *apiResponse = [[NXDropboxUploadFileStartAPIResponse alloc]init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData = (NSData*)returnData;
           
        }
        
        if (contentData)
        {
            NSError *error;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableLeaves error:&error];
          
            apiResponse.session_id = result[@"session_id"];

        }
        
        return apiResponse;
        
    };
   
    return analysis;
}

- (NSData *)jsonDataWithJsonObj:(id)jsonObj {
    if (!jsonObj) {
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&error];
    
    if (!jsonData) {
        NSLog(@"Error serializing dictionary: %@", error.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
}

@end
@implementation NXDropboxUploadFileStartAPIResponse

@end
@implementation NXDropboxUploadFileAppendAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)object;
            NSString *session_id = dict[@"session_id"];
            NSData *fileData = dict[@"fileData"];
           
            NSURL *apiURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://content.dropboxapi.com/2/files/upload_session/append_v2"]];
            NSDictionary *jDict = @{@"cursor":@{@"session_id":session_id,@"offset":[NSNumber numberWithInteger:0]},@"close":[NSNumber numberWithBool:false]};
            NSData *bodyData =  [self jsonDataWithJsonObj:jDict];
            NSString *headerStr = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
                           NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
            [request setValue:headerStr forHTTPHeaderField:@"Dropbox-API-Arg"];
            [request setHTTPBody:fileData];
            self.reqRequest = request;
                
        }
       
        
       
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXDropboxUploadFileAppendAPIResponse *apiResponse = [[NXDropboxUploadFileAppendAPIResponse alloc]init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData = (NSData*)returnData;
        }
        
        if (contentData)
        {
            [apiResponse analysisResponseStatus:contentData];
            if (!error) {
                 apiResponse.rmsStatuCode = 200;
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
- (NSData *)jsonDataWithJsonObj:(id)jsonObj {
    if (!jsonObj) {
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&error];
    
    if (!jsonData) {
        NSLog(@"Error serializing dictionary: %@", error.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
}
@end
@implementation NXDropboxUploadFileAppendAPIResponse

@end
@implementation NXDropboxUploadFileFinishAPIRequest

- (NSURLRequest*)generateRequestObject:(id)object {
    if (self.reqRequest==nil) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)object;
            NSString *session_id = dict[@"session_id"];
            NSData *fileData = dict[@"fileData"];
            NSString *path = dict[@"path"];
            NSDictionary *jDict = @{@"cursor":@{@"session_id":session_id,@"offset":[NSNumber numberWithInteger:fileData.length]},@"commit":@{@"path":path,@"mode":@"overwrite",@"autorename":[NSNumber numberWithBool:false],@"mute":[NSNumber numberWithBool:false],@"strict_conflict":[NSNumber numberWithBool:false]}};
                NSData *bodyData =  [self jsonDataWithJsonObj:jDict];
                NSString *headerStr = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
                
                NSURL *apiURL = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://content.dropboxapi.com/2/files/upload_session/finish"]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
                [request setValue:headerStr forHTTPHeaderField:@"Dropbox-API-Arg"];
//                [request setHTTPBody:fileData];
                self.reqRequest = request;
                
            
        
            
        }
        
       
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error)
    {
        NXDropboxUploadFileFinishAPIResponse *apiResponse = [[NXDropboxUploadFileFinishAPIResponse alloc]init];
        NSData *contentData = nil;
        
        if ([returnData isKindOfClass:[NSString class]])
        {
            contentData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            contentData =(NSData*)returnData;
        }
        
        if (contentData)
        {
             [apiResponse analysisResponseStatus:contentData];
            NSError *error1;
            NSDictionary *fileItemDic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableLeaves error:&error1];
           
            if (!error1) {
                NXDropboxFileItem *item = [[NXDropboxFileItem alloc] init];
                                           
                item.id_ = fileItemDic[@"id"];
                item.name = fileItemDic[@"name"];
                item.size = fileItemDic[@"size"];
                item.pathDisplay = fileItemDic[@"path_display"];
                item.serverModified = [self deserialize:fileItemDic[@"server_modified"] dateFormat:@"%Y-%m-%dT%H:%M:%SZ"];
                item.clientModified = [self deserialize:fileItemDic[@"client_modified"] dateFormat:@"%Y-%m-%dT%H:%M:%SZ"];
                apiResponse.fileItem = item;
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

- (NSData *)jsonDataWithJsonObj:(id)jsonObj {
    if (!jsonObj) {
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&error];
    
    if (!jsonData) {
        NSLog(@"Error serializing dictionary: %@", error.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
}
@end
@implementation NXDropboxUploadFileFinishAPIResponse



@end
