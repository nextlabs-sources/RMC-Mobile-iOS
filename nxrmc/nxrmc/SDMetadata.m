//
//  SDMetadata.m
//  nxrmc
//
//  Created by nextlabs on 10/24/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "SDMetadata.h"
#import "NXMyDriveFileListAPI.h"
#import "NXMyDriveFileUploadAPI.h"
@implementation SDMetadata

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _isDirectory = [[aDecoder decodeObjectForKey:@"isDirectory"] boolValue];
        _fileSize = [[aDecoder decodeObjectForKey:@"fileSize"] longLongValue];
        _lastmodifiedDate = [aDecoder decodeObjectForKey:@"lastmodifiedDate"];
        _filename = [aDecoder decodeObjectForKey:@"filename"];
        _path = [aDecoder decodeObjectForKey:@"path"];
        _fileID = [aDecoder decodeObjectForKey:@"fileID"];
        _contents = [aDecoder decodeObjectForKey:@"contents"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithBool:_isDirectory] forKey:@"isDirectory"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:_fileSize] forKey:@"fileSize"];
    [aCoder encodeObject:_lastmodifiedDate forKey:@"lastmodifiedDate"];
    [aCoder encodeObject:_filename forKey:@"filename"];
    [aCoder encodeObject:_path forKey:@"path"];
    [aCoder encodeObject:_fileID forKey:@"fileID"];
    [aCoder encodeObject:_contents forKey:@"contents"];
}

- (instancetype)initWithItem:(NXMyDriveFileItem *)item {
    self=[super init];
    if (self) {
        self.path=item.pathDisplay;
        self.fileID=item.pathId;
        self.filename=item.name;
        self.fileSize=item.size.longLongValue;
        long long publishLong =[item.lastModified longLongValue];
        NSInteger minSecondsToSecond = 1000;
        publishLong = publishLong/minSecondsToSecond;
        NSDateFormatter *formatter =[[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
//        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
        self.lastmodifiedDate=publishLong?[NSDate dateWithTimeIntervalSince1970:publishLong]:nil;

        if (item.folder) {
            self.isDirectory=YES;
        }else {
            self.isDirectory=NO;
        }
        
    }
    return self;
}
- (instancetype)initWithUploadItem:(NXMyDriveUploadFileItem*)item {
    self =[super init];
    if (self) {
        self.path=item.pathDisplay;
        self.fileID=item.pathId;
        self.filename=item.name;
        self.fileSize=item.size.longLongValue;
        self.isDirectory=NO;
        NSDateFormatter *formatter =[[NSDateFormatter alloc]init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
//        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
        self.lastmodifiedDate=[NSDate dateWithTimeIntervalSince1970:item.lastModified];
    }
    return  self;
}
@end
