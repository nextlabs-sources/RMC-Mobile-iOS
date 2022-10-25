//
//  NXUploadFileVC.m
//  nxrmc
//
//  Created by Sznag on 2020/9/27.
//  Copyright © 2020 nextlabs. All rights reserved.
//

#import "NXUploadFileVC.h"
#import "Masonry.h"
#import "UIImage+ColorToImage.h"
#import "UIView+UIExt.h"
@interface NXUploadFileVC ()
@property(nonatomic, strong)UIScrollView *mainScrollView;
@property(nonatomic, strong)UIView *bottomView;
@property(nonatomic, strong)UIButton *addButton;

@end

@implementation NXUploadFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonNavgationBar];
    [self commonInitUI];
    [self checkThisFile:self.currentFile];

}
- (void)commonInitUI {
    UIScrollView *mainScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:mainScrollView];
    self.mainScrollView = mainScrollView;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    UIView *bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    UIButton *addButton = [[UIButton alloc] init];
    [bottomView addSubview:addButton];
    [addButton setTitle:@"Add the file" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageWithSize:CGSizeMake(200, 200) colors:@[RMC_GRADIENT_START_COLOR,RMC_GRADIENT_END_COLOR] gradientType:GradientTypeUpLeftToLowRight] forState:UIControlStateNormal];
    [addButton cornerRadian:3];
    self.addButton = addButton;
    [mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.equalTo(@60);
    }];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.width.equalTo(@300);
        make.height.equalTo(@40);
    }];
    
}
- (void)checkThisFile:(NXFileBase *)fileItem {
    if (!fileItem) {
        return;
    }

    
}
- (void)commonNavgationBar{
    self.navigationItem.title = @"Create a protectd file";
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelThisOperation:)];
    self.navigationItem.rightBarButtonItem = cancelItem;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)cancelThisOperation:(id)sender{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
