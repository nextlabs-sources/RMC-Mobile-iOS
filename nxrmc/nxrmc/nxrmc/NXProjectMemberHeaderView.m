//
//  NXProjectMemberHeaderView.m
//  nxrmc
//
//  Created by helpdesk on 23/3/17.
//  Copyright © 2017年 nextlabs. All rights reserved.
//
#define HEADERVIEWWIDTH 30
#define MAXCOUNT 6
#import "NXProjectMemberHeaderView.h"
#import "Masonry.h"
#import "HexColor.h"
#import "UIView+UIExt.h"
#import "NXProjectMemberModel.h"
#import "NXPendingProjectInvitationModel.h"

@interface NXProjectMemberHeaderView ()
@end
@implementation NXProjectMemberHeaderView
- (instancetype)initWithFrame:(CGRect)frame withItems:(NSArray *)items andMaxCount:(NSInteger)maxCount {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitWithItems:items];
        _items = items;
        self.backgroundColor = [UIColor whiteColor];
        _maxCount = maxCount;
    }
    return self;
}
- (void)setItems:(NSArray *)items {
    _items = items;
    [self commonInitWithItems:items];
}
- (void)setMaxCount:(NSInteger)maxCount{
    _maxCount = maxCount;
    [self commonInitWithItems:_items];
}
- (void)setSizeWidth:(CGFloat)sizeWidth {
    _sizeWidth = sizeWidth;
    [self commonInitWithItems:_items];
}
- (void)commonInitWithItems:(NSArray *)items {
    if (!items) {
        return;
    }
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    NSInteger maxCount;
    if (!self.maxCount) {
        self.maxCount = MAXCOUNT;
    }
    if (!self.sizeWidth) {
        self.sizeWidth = HEADERVIEWWIDTH;
    }
    if (items.count>self.maxCount) {
        maxCount = self.maxCount;
    }else {
        maxCount = items.count;
    }
        UILabel *lastLabel = nil;
        for (int i = 0; i<maxCount; i++) {
            id item = items[i];
            NSString *itemStr = @"";
            if ([item isKindOfClass:[NXProjectMemberModel class]]) {
                itemStr = ((NXProjectMemberModel *)item).displayName;
            }else if([item isKindOfClass:[NXPendingProjectInvitationModel class]]){
                itemStr = ((NXPendingProjectInvitationModel *)item).displayName;
            }else if([item isKindOfClass:[NSString class]]){
                itemStr = item;
            }
            UILabel *memberLabel = [[UILabel alloc]init];
            if (items.count>=self.maxCount && i == self.maxCount-1) {
                memberLabel.text = [NSString stringWithFormat:@"+%ld",items.count-self.maxCount+1];
            }else{
                memberLabel.lineBreakMode = NSLineBreakByClipping;
                if (itemStr && ![itemStr isEqualToString:@""]) {
                    memberLabel.text = [self getHeaderViewTextWith:itemStr];
                }
            }
            memberLabel.textAlignment = NSTextAlignmentCenter;
            NSDictionary *colorDic = [self getBgcolorAndTextColorWith:memberLabel.text];
            memberLabel.backgroundColor = [HXColor colorWithHexString:colorDic[@"backgroundColor"]];
            memberLabel.textColor = [HXColor colorWithHexString:colorDic[@"color"]];
            [memberLabel cornerRadian:self.sizeWidth/2];
            [self addSubview:memberLabel];
            if (i == 0) {
                [memberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self);
                    make.left.equalTo(self).offset(5);
                    make.height.equalTo(@(self.sizeWidth));
                    make.width.equalTo(@(self.sizeWidth));
                }];
            }else {
                [memberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self);
                    make.left.equalTo(lastLabel.mas_right).offset(5);
                    make.height.equalTo(@(self.sizeWidth));
                    make.width.equalTo(@(self.sizeWidth));
                }];
            }
            lastLabel = memberLabel;
        }
        
   
}
- (NSDictionary *)getBgcolorAndTextColorWith:(NSString *)nameStr {
    NSDictionary *colorDic;
    NSString *str = [nameStr substringToIndex:1];
    str = [str lowercaseString];
    NSDictionary *colorsDictionary = @{@"a":@{@"backgroundColor":@"#DD212B",@"color":@"#FFFFFF"},
                                @"b":@{@"backgroundColor":@"#FDCB8A",@"color":@"#8F9394"},
                                @"c":@{@"backgroundColor":@"#98C44A",@"color":@"#FFFFFF"},
                                @"d":@{@"backgroundColor":@"#1A5279",@"color":@"#FFFFFF"},
                                @"e":@{@"backgroundColor":@"#EF6645",@"color":@"#FFFFFF"},
                                @"f":@{@"backgroundColor":@"#72CAC1",@"color":@"#FFFFFF"},
                                @"g":@{@"backgroundColor":@"#B7DCAF",@"color":@"#8F9394"},
                                @"h":@{@"backgroundColor":@"#705A9E",@"color":@"#FFFFFF"},
                                @"i":@{@"backgroundColor":@"#FCDA04",@"color":@"#8F9394"},
                                @"j":@{@"backgroundColor":@"#ED1D7C",@"color":@"#FFFFFF"},
                                @"k":@{@"backgroundColor":@"#F7AAA5",@"color":@"#FFFFFF"},
                                @"l":@{@"backgroundColor":@"#4AB9E6",@"color":@"#FFFFFF"},
                                @"m":@{@"backgroundColor":@"#603A18",@"color":@"#FFFFFF"},
                                @"n":@{@"backgroundColor":@"#88B8BC",@"color":@"#FFFFFF"},
                                @"o":@{@"backgroundColor":@"#ECA81E",@"color":@"#FFFFFF"},
                                @"p":@{@"backgroundColor":@"#DAACD0",@"color":@"#FFFFFF"},
                                @"q":@{@"backgroundColor":@"#6D6E73",@"color":@"#FFFFFF"},
                                @"r":@{@"backgroundColor":@"#9D9FA2",@"color":@"#FFFFFF"},
                                @"s":@{@"backgroundColor":@"#B5E3EE",@"color":@"#8F9394"},
                                @"t":@{@"backgroundColor":@"#90633D",@"color":@"#FFFFFF"},
                                @"u":@{@"backgroundColor":@"#BDAE9E",@"color":@"#FFFFFF"},
                                @"v":@{@"backgroundColor":@"#C8B58E",@"color":@"#FFFFFF"},
                                @"w":@{@"backgroundColor":@"#F8BDD2",@"color":@"#FFFFFF"},
                                @"x":@{@"backgroundColor":@"#FED968",@"color":@"#8F9394"},
                                @"y":@{@"backgroundColor":@"#F69679",@"color":@"#FFFFFF"},
                                @"z":@{@"backgroundColor":@"#EE6769",@"color":@"#FFFFFF"},
                                @"0":@{@"backgroundColor":@"#D3E050",@"color":@"#8F9394"},
                                @"1":@{@"backgroundColor":@"#D8EBD5",@"color":@"#8F9394"},
                                @"2":@{@"backgroundColor":@"#F27EA9",@"color":@"#8F9394"},
                                @"3":@{@"backgroundColor":@"#1782C0",@"color":@"#8F9394"},
                                @"4":@{@"backgroundColor":@"#CDECF9",@"color":@"#8F9394"},
                                @"5":@{@"backgroundColor":@"#FDE9E6",@"color":@"#8F9394"},
                                @"6":@{@"backgroundColor":@"#FCED95",@"color":@"#8F9394"},
                                @"7":@{@"backgroundColor":@"#F99D21",@"color":@"#8F9394"},
                                @"8":@{@"backgroundColor":@"#F9A85D",@"color":@"#8F9394"},
                                @"9":@{@"backgroundColor":@"#BCE2D7",@"color":@"#8F9394"}
                                };
   
    if([colorsDictionary.allKeys containsObject:str]){
        colorDic = [colorsDictionary valueForKey:str];
    } else {
        colorDic = @{@"backgroundColor":@"#333333",@"color":@"#FFFFFF"};
    }
    return colorDic;
}
- (NSString*)getHeaderViewTextWith:(NSString *)str {
    NSString *resultStr = nil;
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *strArrs = [str componentsSeparatedByString:@" "];
    if (strArrs.count == 1) {
        NSString *allStr = strArrs.firstObject;
         resultStr = [allStr substringToIndex:1];
    } else if (strArrs.count>1){
        NSString *firstPartStr = strArrs.firstObject;
        NSString *firstStr = [firstPartStr substringToIndex:1];
        NSString *lastPastStr = strArrs.lastObject;
        NSString *lastStr = [lastPastStr substringToIndex:1];
        resultStr = [NSString stringWithFormat:@"%@%@",firstStr,lastStr];
    }
//    NSMutableString * nameStr = [[NSMutableString alloc]init];
//    NSString *firstStr = [str substringToIndex:1];
//    [nameStr appendString:firstStr];
//    for (int i =1; i<str.length; i++) {
//         char commitChar = [str characterAtIndex:i];
//       if (commitChar>64&&commitChar<91) {
//            NSString *bigChar = [NSString stringWithFormat:@"%c",commitChar];
//             [nameStr appendString:bigChar];
//        }
//    }
//    if (nameStr.length>2) {
//        resultStr = [nameStr substringToIndex:2];
//    } else {
//        resultStr = nameStr;
//    }
    resultStr = [resultStr uppercaseString];
    return resultStr;
}
@end
