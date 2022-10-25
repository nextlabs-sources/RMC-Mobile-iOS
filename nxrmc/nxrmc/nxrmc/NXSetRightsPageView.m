//
//  NXSetRightsPageView.m
//  nxrmc
//
//  Created by Tim (Xinyin) Liu on 16/3/18.
//  Copyright © 2018年 nextlabs. All rights reserved.
//

#import "NXSetRightsPageView.h"
#import "Masonry.h"
#import "NXClassificationSelectView.h"
#import "NXRightsSelectView.h"
#import "NXClassificationLab.h"
#import "NXClassificationCategory.h"
#import "NXRMCUIDef.h"
#import "NXLoginUser.h"
#import "NXCommonUtils.h"
#import "NXLRights.h"
@interface NXSetRightsPageView ()<NXRightsSelectViewDelegate>
@property(nonatomic, strong) UISegmentedControl *sortSetment;
@property(nonatomic, strong) NSArray *segmentItems;
@property(nonatomic, strong) NXRightsSelectView *digitalView;
@property(nonatomic, strong) NXClassificationSelectView *classificationView;

@end
@implementation NXSetRightsPageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.segmentItems = @[@" Digital Rights",@" Documnet Classification"].copy;
        self.currentType = NXSetRightsTypeDigital;
        [self commonInit];
    }
    return self;
}
- (NXRightsSelectView *)digitalView {
    if (!_digitalView) {
        _digitalView = [[NXRightsSelectView alloc]init];
        [self addSubview:_digitalView];
        NXLRights *rights = [[NXLRights alloc] init];
        [rights setRight:NXLRIGHTVIEW value:YES];
        [rights setFileValidateDate:[NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate];
        [_digitalView setIsToProject:YES];
        _digitalView.rights = rights;
        _digitalView.enabled = YES;
        _digitalView.delegate = self;
        WeakObj(self);
        _digitalView.fileValidityChagedBlock = ^(NXLFileValidateDateModel *model) {
            StrongObj(self);
            [self.digitalSelectRights setFileValidateDate:model];
        };
    }
    return _digitalView;
}
- (void)setClassificationCategoryArray:(NSArray<NXClassificationCategory *> *)classificationCategoryArray {
    _classificationCategoryArray = classificationCategoryArray;
    self.classificationView.classificationCategoryArray = classificationCategoryArray;
   
}
- (NXClassificationSelectView *)classificationView {
    if (!_classificationView) {
        _classificationView = [[NXClassificationSelectView alloc]init];
        _classificationView.classificationCategoryArray = self.classificationCategoryArray;
        [self addSubview:_classificationView];
    }
    return _classificationView;
}
- (void)commonInit {
    UISegmentedControl *sortSetment = [[UISegmentedControl alloc]initWithItems:self.segmentItems];
    
    sortSetment.selectedSegmentIndex = self.currentType;
    
    sortSetment.tintColor = RMC_MAIN_COLOR;
    [sortSetment addTarget:self action:@selector(handleSegmentControlAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:sortSetment];
    self.sortSetment = sortSetment;
    [sortSetment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@40);
    }];
    if (self.currentType == NXSetRightsTypeDigital) {
        [self.digitalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(sortSetment.mas_bottom).offset(5);
            make.left.right.equalTo(self);
            make.bottom.equalTo(self).mas_offset(-10);
        }];
    }
}
- (void)handleSegmentControlAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == self.currentType) {
        return;
    }else {
         self.currentType = sender.selectedSegmentIndex;
        switch (sender.selectedSegmentIndex) {
            case NXSetRightsTypeDigital:
                 {
                     [self bringSubviewToFront:self.digitalView];
                    [self.digitalView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(self.sortSetment.mas_bottom).offset(5);
                        make.left.right.equalTo(self);
                        make.bottom.equalTo(self).mas_offset(-10);
                    }];
    
                }
                break;
                case NXSetRightsTypeClassification:
                {
                    [self bringSubviewToFront:self.classificationView];
                    [self.classificationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                            make.top.equalTo(self.sortSetment.mas_bottom).offset(5);
                            make.left.right.equalTo(self);
                            make.bottom.equalTo(self).mas_offset(-10);

                    }];
                }
                break;
            default:
                break;
        }
        if ([self.delegate respondsToSelector:@selector(nxsetRightspageView:didChangeType:)]) {
            [self.delegate nxsetRightspageView:self didChangeType:sender.selectedSegmentIndex];
        }
    }
}

#pragma mark - NXRightsSelectViewDelegate

- (void)rightsSelectView:(NXRightsSelectView *)selectView didRightsSelected:(NXLRights *)rights {
    if (self.digitalSelectRights.getVaildateDateModel) {
        [rights setFileValidateDate:self.digitalSelectRights.getVaildateDateModel];
    }
    self.digitalSelectRights = rights;
}

- (void)rightsSelectView:(NXRightsSelectView *)selectView didHeightChanged:(CGFloat)height {
//    [self viewDidLayoutSubviews];
}


//- (void)commonInit1 {
//    UIButton *digitalRightsBtn = [[UIButton alloc]init];
//    [digitalRightsBtn setTitle:@"Digital Rights" forState:UIControlStateNormal];
//    [digitalRightsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    digitalRightsBtn.selected = YES;
//    [digitalRightsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [digitalRightsBtn addTarget:self action:@selector(selectDigitalRights:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:digitalRightsBtn];
//    UIButton *classificationBtn = [[UIButton alloc]init];
//    [classificationBtn setTitle:@"Document Classification" forState:UIControlStateNormal];
//    [classificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [classificationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [classificationBtn addTarget:self action:@selector(selectClassificationRights:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:classificationBtn];
//
//    [digitalRightsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.equalTo(self);
//        make.height.equalTo(@40);
//        make.width.equalTo(self).multipliedBy(0.4);
//    }];
//    [classificationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.height.equalTo(digitalRightsBtn);
//        make.left.equalTo(digitalRightsBtn.mas_right);
//        make.right.equalTo(self);
//    }];
//}
//- (void)selectDigitalRights:(UIButton *)sender {
//    sender.backgroundColor = RMC_MAIN_COLOR;
//}
//- (void)selectClassificationRights:(UIButton *)sender {
//    sender.backgroundColor = RMC_MAIN_COLOR;
//}
@end
