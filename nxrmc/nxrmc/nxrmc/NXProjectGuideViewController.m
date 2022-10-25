//
//  NXProjectGuideViewController.m
//  nxrmc
//
//  Created by Bill (Guobin) Zhang on 5/25/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectGuideViewController.h"

#import "NXCarouselView.h"
#import "NXPageView.h"
#import "Masonry.h"
#import "UIView+UIExt.h"
#import "UIImage+ColorToImage.h"

#import "NXCommonUtils.h"

@interface NXProjectGuideViewController()<NXCarouseViewDataSource>

@property(nonatomic, weak) NXCarouselView *scrollView;

@end

@implementation NXProjectGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews  {
    [super viewDidLayoutSubviews];
}

- (void)dealloc {
    DLog(@"");
}

#pragma mark -

- (void)createProject:(id)sender {
    if (self.clickBlock) {
        self.clickBlock(nil);
    }
    [self back:nil];
}

- (void)back:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NXCarouseViewDelegate, NXCarouseViewDataSource

- (NSInteger)numberofPagecarouseView:(NXCarouselView *)carouseView {
    return 5;
}

- (UIView *)pageAtIndex:(NSInteger)index carouseView:(NXCarouselView *)carouseView {
    NXPageView *view = [[NXPageView alloc] init];

    NSDictionary *normalProperty = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    NSDictionary *coloredProperty = @{NSForegroundColorAttributeName:RMC_MAIN_COLOR, NSObliquenessAttributeName:@(0.2)};
    
    NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] init];
    switch (index) {
        case 0:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Work securely in a team\n", NULL)attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"without worrying about\n", NULL) attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"leakage of intellectual property\n", NULL) attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"and trade secret.", NULL) attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
        }
            break;
        case 1:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Share project documents\n", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"safely!", NULL) attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            view.detailTextLabel.text = NSLocalizedString(@"Store and manage documents for the\nproject for secure sharing across\nproject team.", NULL);
        }
            break;
        case 2:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Teamwork!", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            view.detailTextLabel.text = NSLocalizedString(@"Common collaboration space for the\nproject team to work together.", NULL);
        }
            break;
        case 3:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Manage project\n", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Centrally!", NULL) attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            view.detailTextLabel.text = NSLocalizedString(@"Central place to manage and track all\nthe critical documents and sensitive\nfiles shared with.", NULL);
        }
            break;
        case 4:
        {
            NSAttributedString *attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Track and monitor\n", NULL)attributes:normalProperty];
            [titleAttribute appendAttributedString:attri];
            
            attri = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"usage and risk!", NULL) attributes:coloredProperty];
            [titleAttribute appendAttributedString:attri];
            
            view.detailTextLabel.text = NSLocalizedString(@"Revoke, track, monitor, and report\n usage of all project documents\nautomatically.", NULL);
        }
            break;
        default:
            break;
    }
    view.mainTextLabel.attributedText = titleAttribute;
    view.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Welcome-Project-Image%ld", (long)index]];
    
    view.pageControl.numberOfPages = 5;
    view.pageControl.currentPage = index;
    view.pageControl.currentDotImage = [UIImage imageNamed:@"dotCurrentImage"];
    view.pageControl.dotImage = [UIImage imageNamed:@"dotImage"];
    return view;
}

- (void)carouseView:(NXCarouselView *)carouseView didClickPage:(UIView *)view atIndex:(NSInteger)index {
    NSLog(@"");
}

#pragma mark

- (void)commonInit {
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedString(@"Project", NULL);
    self.navigationItem.titleView = titleLabel;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NXCarouselView *carouselView = [[NXCarouselView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:carouselView];
    
    carouselView.dataSource = self;
    carouselView.showPageControl = NO;
    [carouselView reloadData];
    [carouselView addShadow:UIViewShadowPositionBottom color:[UIColor lightGrayColor] width:1 Opacity:0.5];
    
    UIButton *creatProjectBtn = [[UIButton alloc] init];
    [self.view addSubview:creatProjectBtn];
    [creatProjectBtn setTitle:NSLocalizedString(@"Create a project", NULL) forState:UIControlStateNormal];
    [creatProjectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [creatProjectBtn cornerRadian:3];
    [creatProjectBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [creatProjectBtn addTarget:self action:@selector(createProject:) forControlEvents:UIControlEventTouchUpInside];
    creatProjectBtn.backgroundColor = [UIColor whiteColor];
    creatProjectBtn.layer.borderColor = [UIColor blackColor].CGColor;
    creatProjectBtn.layer.borderWidth = 2;
    
    [carouselView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(kMargin);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(creatProjectBtn.mas_top).offset(-kMargin * 3);
    }];
    
    [creatProjectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.6);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop).offset(-kMargin * 3);
        make.height.equalTo(@(kMargin * 5));
    }];
    
#if 0
    creatProjectBtn.backgroundColor = [UIColor greenColor];
    carouselView.backgroundColor = [UIColor lightGrayColor];
#endif
}

@end
