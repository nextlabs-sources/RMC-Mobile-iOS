//
//  NXPreferencesViewController.m
//  nxrmc
//
//  Created by Stepanoval (Xinxin) Huang on 13/11/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXPreferencesViewController.h"
#import "Masonry.h"
#import "NXFileValidityDateChooseViewController.h"
#import "NXRMCDef.h"
#import "NXLoginUser.h"
#import "MBProgressHUD.h"
#import "NXCommonUtils.h"
#import "NXMBManager.h"
#import "NXWaterMarkView.h"
#import "NXLFileValidateDateModel.h"
@interface NXPreferencesViewController ()<NXWaterMarkViewDelegate>

@property (nonatomic, weak) UILabel *descriptionLabel;
@property (nonatomic, weak) UILabel *fileValidityTypeLabel;
@property (nonatomic, weak) UIButton *saveBtn;
@property (nonatomic, weak) NXWaterMarkView *watermarkView;
@end

@implementation NXPreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _fileValidityDateModel = [NXLoginUser sharedInstance].userPreferenceManager.userPreference.preferenceFileValidateDate;

    [self commonInit];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commonInit {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"Preferences";
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    //background scrollView
    UIScrollView *bgScrollView  = [[UIScrollView alloc]init];
    bgScrollView.backgroundColor = [UIColor whiteColor];
    bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    UILabel *documentLabel = [[UILabel alloc] init];
    documentLabel.text = @"Document";
    documentLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [bgScrollView addSubview:documentLabel];
    UILabel *defaultWatermarkLabel = [[UILabel alloc]init];
    defaultWatermarkLabel.numberOfLines = 0;
    defaultWatermarkLabel.attributedText = [self createAttributeString:@"Default watermark " subTitle1:@"(User-defined policy)"];
    [bgScrollView addSubview:defaultWatermarkLabel];
    // watermarkView
    NXWaterMarkView *watermarkView = [[NXWaterMarkView alloc]init];
    watermarkView.origialWaterMarks = [[NXLoginUser sharedInstance].userPreferenceManager userPreference].preferenceWatermark;
    watermarkView.delegate = self;
    [bgScrollView addSubview:watermarkView];
    self.watermarkView = watermarkView;
    
    //file validity content view
    UIView *fileValidityDateContentView = [[UIView alloc] init];
    fileValidityDateContentView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    [bgScrollView addSubview:fileValidityDateContentView];
    
    // default expiry date label
    UILabel *defaultExpiryDateLabel = [[UILabel alloc] init];
    defaultExpiryDateLabel.text = @"Digital rights validity period";
    defaultExpiryDateLabel.numberOfLines = 0;
    defaultExpiryDateLabel.attributedText = [self createAttributeString:@"Digital permissions validity period " subTitle1:@"(User-defined policy)"];
    [fileValidityDateContentView addSubview:defaultExpiryDateLabel];
    
    //fileValidityTypeLabel
    UILabel *fileValidityTypeLabel = [[UILabel alloc] init];
    // fileValidityTypeLabel.text = @"Date Range";
    fileValidityTypeLabel.textColor = [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0];
    fileValidityTypeLabel.font = [UIFont systemFontOfSize:14.0];
    self.fileValidityTypeLabel = fileValidityTypeLabel;
    [fileValidityDateContentView addSubview:fileValidityTypeLabel];
    
    //change label
    UILabel *changeLabel = [[UILabel alloc] init];
    changeLabel.textColor = [UIColor colorWithRed:74.0/255.0 green:143.0/255.0 blue:232.0/255.0 alpha:1.0];
    changeLabel.font = [UIFont italicSystemFontOfSize:14.0];
    UITapGestureRecognizer *changeLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapChangeLabel:)];
    [changeLabel addGestureRecognizer:changeLabelTapGestureRecognizer];
    changeLabel.userInteractionEnabled = YES;
    
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:@"Change" attributes:attribtDic];
    changeLabel.attributedText = attribtStr;
    [fileValidityDateContentView addSubview:changeLabel];
    
    // description label
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.textColor = [UIColor colorWithRed:172.0/255.0 green:172.0/255.0 blue:172.0/255.0 alpha:1.0];
    descriptionLabel.font = [UIFont systemFontOfSize:14.0];
    descriptionLabel.adjustsFontSizeToFitWidth = YES;
    self.descriptionLabel = descriptionLabel;
    [self setDesLabelTextWithModel:_fileValidityDateModel];
    [fileValidityDateContentView addSubview:descriptionLabel];
    // save button
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UIButton *saveButton = [[UIButton alloc] init];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(onTapSaveButton:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setBackgroundColor:[UIColor colorWithRed:73.0/255.0 green:160.0/255.0 blue:84.0/255.0 alpha:1.0]];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.layer.cornerRadius = 5.0;
    self.saveBtn = saveButton;
    [bottomView addSubview:saveButton];
    
    if (IS_IPHONE_X) {
        if (@available(iOS 11.0, *))  {
            [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.leading.equalTo(self.view.mas_safeAreaLayoutGuideLeading);
                make.trailing.equalTo(self.view.mas_safeAreaLayoutGuideTrailing);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            }];
            [documentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(bgScrollView).offset(5);
                    make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(20);
                    make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-10);
                    make.height.equalTo(@30);
                    
            }];
            [defaultWatermarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(documentLabel.mas_bottom).offset(5);
                    make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(20);
                    make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-10);
//                    make.height.equalTo(@30);
                    
            }];
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                make.height.equalTo(@60);
            }];
        }

    }else {
        [bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.bottom.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        if (IS_IPAD) {
            [documentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_topLayoutGuideBottom).offset(5);
                make.left.equalTo(self.view).offset(20);
                make.right.equalTo(self.view).offset(-10);
                make.height.equalTo(@30);
            }];
            [defaultWatermarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(documentLabel.mas_bottom).offset(5);
                make.left.equalTo(self.view).offset(20);
                make.right.equalTo(self.view).offset(-10);
//                make.height.equalTo(@30);
            }];
        }else {
            [documentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_topLayoutGuideBottom).offset(5);
                make.left.equalTo(self.view).offset(20);
                make.right.equalTo(self.view).offset(-10);
                make.height.equalTo(@30);
            }];
            [defaultWatermarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(documentLabel.mas_bottom).offset(5);
                make.left.equalTo(self.view).offset(20);
                make.right.equalTo(self.view).offset(-10);
//                make.height.equalTo(@30);
            }];
        }
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-20);
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.height.equalTo(@60);
        }];
    }

    [watermarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(defaultWatermarkLabel.mas_bottom).offset(5);
        make.left.equalTo(bottomView).offset(10);
        make.right.equalTo(bottomView).offset(-10);
        make.height.equalTo(@260);
    }];
    
    [fileValidityDateContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bottomView);
        make.height.equalTo(@(140));
        make.top.equalTo(watermarkView.mas_bottom).offset(10);
        make.bottom.equalTo(bgScrollView).offset(-120);
    }];
    
    [defaultExpiryDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fileValidityDateContentView).offset(5);
        make.left.equalTo(fileValidityDateContentView).offset(20);
        make.right.equalTo(fileValidityDateContentView).offset(-5);
    }];
    
    [fileValidityTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(fileValidityDateContentView).offset(20);
        make.top.equalTo(defaultExpiryDateLabel.mas_bottom).offset(10);
        make.width.equalTo(@(100));
        make.height.equalTo(@(20));
    }];
    
    [changeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(fileValidityTypeLabel).offset(100);
        make.top.equalTo(defaultExpiryDateLabel.mas_bottom).offset(10);;
        
    }];
    
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(fileValidityDateContentView).offset(20);
        make.right.equalTo(fileValidityDateContentView).offset(-20);
        make.top.equalTo(fileValidityTypeLabel.mas_bottom).offset(15);
        make.height.equalTo(@(44));
    }];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bottomView);
        make.width.equalTo(@200);
        make.height.equalTo(@45);
    }];
}

- (void)onTapSaveButton:(id)sender
{
    if (![NXCommonUtils checkIsLegalFileValidityDate:_fileValidityDateModel]) {
        [NXMBManager showMessage:NSLocalizedString(@"MSG_COM_FILE_EXPIRETIME_INVALID", NULL) toView:self.view hideAnimated:YES afterDelay:kDelay];
        return;
    }
    
    [NXMBManager showLoadingToView:self.view];
    
    NXUserPreference *preferenceModel = [[NXUserPreference alloc]init];
    preferenceModel.preferenceWatermark = [self.watermarkView getTheWaterMarkValuesFromTextViewUI];
    preferenceModel.preferenceFileValidateDate = _fileValidityDateModel;
    [[NXLoginUser sharedInstance].userPreferenceManager updateUserPreference:preferenceModel completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NXMBManager hideHUDForView:self.view];
            if (error) {
                [NXMBManager showMessage:@"Update failed" hideAnimated:YES afterDelay:3];
            }else{
                [NXMBManager showMessage:@"Update successfully" hideAnimated:YES afterDelay:3];
            }
        });
    }];
}

- (void)setDesLabelTextWithModel:(NXLFileValidateDateModel *)model
{
    if (model.type == NXLFileValidateDateModelTypeNeverExpire) {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"Access rights will Never expire"];
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:[UIColor colorWithRed:48.0/255.0 green:173.0/255.0 blue:99.0/255.0 alpha:1.0]
                           range:NSMakeRange(19, 12)];
        [attrString addAttribute:NSFontAttributeName
                           value:[UIFont boldSystemFontOfSize:15.0f]
                           range:NSMakeRange(19, 12)];
        [attrString addAttribute:NSForegroundColorAttributeName
                           value:[UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0]
                           range:NSMakeRange(0, 18)];
        self.descriptionLabel.attributedText = attrString;
        self.fileValidityTypeLabel.text = @"Never expire";
    }
    else if(model.type == NXLFileValidateDateModelTypeRange)
    {
        self.descriptionLabel.text = [model getValidateDateDescriptionString];
        self.fileValidityTypeLabel.text = @"Date range";
    }
    else if (model.type == NXLFileValidateDateModelTypeRelative)
    {
        self.descriptionLabel.text = [model getValidateDateDescriptionString];
        self.fileValidityTypeLabel.text = @"Relative";
    }
    else if(model.type == NXLFileValidateDateModelTypeAbsolute)
    {
        self.descriptionLabel.text = [model getValidateDateDescriptionString];
        self.fileValidityTypeLabel.text = @"Absolute date";
    }
}
- (void)watermarkViewTextDidChange:(BOOL)isValid {
    if (isValid) {
        [self.saveBtn setBackgroundColor:[UIColor colorWithRed:73.0/255.0 green:160.0/255.0 blue:84.0/255.0 alpha:1.0]];
        self.saveBtn.enabled = YES;
    }else {
        self.saveBtn.backgroundColor = [UIColor lightGrayColor];
        self.saveBtn.enabled = NO;
    }
}
- (void)onTapChangeLabel:(id)sender
{
    [self.watermarkView closeTheKeyBoardIfNeed];
    NXFileValidityDateChooseViewController *vc = [[NXFileValidityDateChooseViewController alloc] initWithDateModel:self.fileValidityDateModel];
    WeakObj(self);
    vc.chooseCompBlock = ^(NXLFileValidateDateModel *dateModel) {
        StrongObj(self);
        self.fileValidityDateModel = dateModel;
        [self setDesLabelTextWithModel:dateModel];
    };
    [vc show];
}
- (NSAttributedString *)createAttributeString:(NSString *)title subTitle1:(NSString *)subtitle1 {
   
    
    NSMutableAttributedString *sub1 = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    NSMutableAttributedString *myprojects = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:@{NSForegroundColorAttributeName :[UIColor lightGrayColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    [sub1 appendAttributedString:myprojects];

    return sub1;
}
@end
