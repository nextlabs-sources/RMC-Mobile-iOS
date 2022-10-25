//
//  NXRights.m
//  nxrmc
//
//  Created by Kevin on 16/6/21.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXLRights.h"

@interface NXLRights ()
{
    long    _rights;
    long    _obs;
    NSDictionary* _dictRights;
    NSDictionary* _dictObligations;
}
@end

@implementation NXLRights

- (id)init
{
    if (self = [super init]) {
        _rights = 0;
        _obs = 0;
        _dictRights = @{
                        [NSNumber numberWithLong:NXLRIGHTVIEW]: @"VIEW",
                        [NSNumber numberWithLong:NXLRIGHTEDIT]: @"EDIT",
                        [NSNumber numberWithLong:NXLRIGHTPRINT]: @"PRINT",
                        [NSNumber numberWithLong:NXLRIGHTCLIPBOARD]: @"CLIPBOARD",
                        [NSNumber numberWithLong:NXLRIGHTSAVEAS]: @"SAVEAS",
                        [NSNumber numberWithLong:NXLRIGHTDECRYPT]: @"DECRYPT",
                        [NSNumber numberWithLong:NXLRIGHTSCREENCAP]: @"SCREENCAP",
                        [NSNumber numberWithLong:NXLRIGHTSEND]: @"SEND",
                        [NSNumber numberWithLong:NXLRIGHTCLASSIFY]: @"CLASSIFY",
                        [NSNumber numberWithLong:NXLRIGHTSHARING]: @"SHARE",
                        [NSNumber numberWithLong:NXLRIGHTSDOWNLOAD]: @"DOWNLOAD",
                        };
        _dictObligations = @{
                             [NSNumber numberWithLong:NXLOBLIGATIONWATERMARK]: @"WATERMARK",
                             };
    }
    
    return self;
}

- (id)initWithRightsObs:(NSArray *)rights obligations:(NSArray *)obs
{
    if (self = [self init]) {
        [_dictRights enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString* value = (NSString*)obj;
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF == %@", value];
            NSArray* temp = [rights filteredArrayUsingPredicate:predicate];
            if (temp.count > 0 ) {
                _rights |= [key longValue];
            }
        }];
        
        
        [obs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary* ob = (NSDictionary*)obj;
            NSString* obValue = [ob objectForKey:@"name"];
           
            [_dictObligations enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obValue isEqualToString:(NSString*)obj]) {
                    _obs |= [key longValue];
                    *stop = YES;
                }
            }];
        }];
    }
    
    return self;
}

- (BOOL)ViewRight
{
    return (_rights & NXLRIGHTVIEW) != 0 ? YES : NO;
}

- (BOOL)ClassifyRight
{
    return (_rights & NXLRIGHTCLASSIFY) != 0 ? YES : NO;
}

- (BOOL)EditRight
{
    return (_rights & NXLRIGHTEDIT) != 0 ? YES : NO;
}

- (BOOL)PrintRight
{
    return (_rights & NXLRIGHTPRINT) != 0 ? YES : NO;
}

- (BOOL)SharingRight
{
    return (_rights & NXLRIGHTSHARING) != 0 ? YES : NO;
}

- (BOOL)DownloadRight
{
    return (_rights & NXLRIGHTSDOWNLOAD) != 0 ? YES : NO;
}

- (BOOL)getRight:(NXLRIGHT)right {
    return (_rights & right) != 0 ? YES : NO;
}

- (BOOL)getObligation:(NXLOBLIGATION)ob
{
    return (_obs & ob) != 0 ? YES: NO;
}

- (void)setRight:(NXLRIGHT)right value:(BOOL)hasRight
{
    if (hasRight) {
        _rights |= right;
    } else {
        _rights &= ~(right);
    }
}

- (void)setObligation:(NXLOBLIGATION)ob value:(BOOL)hasOb
{
    if (hasOb) {
        _obs |= ob;
    }
    else
    {
        _obs &= ~(ob);
    }
}

- (void)setRights:(long)rights
{
    _rights = rights;
}

- (void)setAllRights
{
    _rights = 0xFFFFFFFF;
}

- (void)setNoRights {
    _rights = 0x00000000;
}

- (long) getRights
{
    return _rights;
}

- (NSArray*)getNamedRights
{
    NSMutableArray* namedRights = [NSMutableArray array];
    if (_rights & NXLRIGHTVIEW) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTVIEW]]];
    }
    if (_rights & NXLRIGHTEDIT) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTEDIT]]];
    }
    if (_rights & NXLRIGHTPRINT) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTPRINT]]];
    }
    if (_rights & NXLRIGHTCLIPBOARD) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTCLIPBOARD]]];
    }
    if (_rights & NXLRIGHTSAVEAS) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSAVEAS]]];
    }
    if (_rights & NXLRIGHTDECRYPT) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTDECRYPT]]];
    }
    if (_rights & NXLRIGHTSCREENCAP) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSCREENCAP]]];
    }
    if (_rights & NXLRIGHTSEND) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSEND]]];
    }
    if (_rights & NXLRIGHTCLASSIFY) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTCLASSIFY]]];
    }
    if (_rights & NXLRIGHTSHARING) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSHARING]]];
    }
    if (_rights & NXLRIGHTSDOWNLOAD){
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSDOWNLOAD]]];
    }
    return namedRights;
}

- (NSArray*) getNamedObligations
{
    NSMutableArray* namedObligations = [NSMutableArray array];
    if (_obs & NXLOBLIGATIONWATERMARK) {
        NSDictionary* ob = @{@"name":[_dictObligations objectForKey:[NSNumber numberWithLong:NXLOBLIGATIONWATERMARK]]};
        [namedObligations addObject:ob];
    }
    return namedObligations;
}


+ (NSArray *)getSupportedContentRights
{
    return @[  @{@"View":[NSNumber numberWithLong:NXLRIGHTVIEW]},
               @{@"Edit":[NSNumber numberWithLong:NXLRIGHTEDIT]},
               @{@"Print":[NSNumber numberWithLong:NXLRIGHTPRINT]},
         /*      @{@"Clipboard":[NSNumber numberWithLong:RIGHTCLIPBOARD]},
               @{@"Save As": [NSNumber numberWithLong:RIGHTSAVEAS]},
               @{@"Decrypt": [NSNumber numberWithLong:RIGHTDECRYPT]},
               @{@"Screen Capture": [NSNumber numberWithLong:RIGHTSCREENCAP]},
               @{@"Send": [NSNumber numberWithLong:RIGHTSEND]},
               @{@"Classify": [NSNumber numberWithLong:RIGHTCLASSIFY]},*/
              
             ];
}

+ (NSArray *)getSupportedCollaborationRights
{
    return @[
              @{@"Share": [NSNumber numberWithLong:NXLRIGHTSHARING]},
              @{@"Download": [NSNumber numberWithLong:NXLRIGHTSDOWNLOAD]},
             ];
}

+ (NSArray*) getSupportedObs
{
    return @[@{@"Watermark/Overlay": [NSNumber numberWithLong:NXLOBLIGATIONWATERMARK]}];
}

@end

