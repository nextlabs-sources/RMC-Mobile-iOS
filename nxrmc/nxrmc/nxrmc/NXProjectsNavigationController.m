//
//  NXProtectsNavigationController.m
//  nxrmc
//
//  Created by nextlabs on 1/18/17.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXProjectsNavigationController.h"

#import "NXMyProjectsViewController.h"
#import "NXPeopleViewController.h"
#import "NXProjectFilesVC.h"

#import "NXPullDownButton.h"
#import "UIImage+ColorToImage.h"
#import "Masonry.h"
#import "NXProjectSummaryVC.h"
#import "NXProjectModel.h"

@interface NXProjectsNavigationController ()<UINavigationControllerDelegate>

@property(nonatomic, weak) NXMyProjectsViewController *pullDownProjectsVC;
@property(nonatomic, weak) UIViewController *currentShowVC;
@property(nonatomic, strong) UIBarButtonItem *backButtonItem;
@end

@implementation NXProjectsNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
//    self.navigationBar.shadowImage = [[UIImage alloc] init];
//    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    
    self.navigationBar.tintColor = [UIColor blackColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                               NSFontAttributeName : [UIFont systemFontOfSize:15]};
    
    self.navigationBar.topItem.title = NSLocalizedString(@"Alexa Files", NULL);
    
    self.delegate = self;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureTitleView:(UIViewController *)vc
{
     vc.navigationItem.titleView = [self titleView];
}

#pragma mark
- (void)back:(id)sender {
    //for pull down show projects view disenable back button.
    if ([self.topViewController isKindOfClass:[NXMyProjectsViewController class]]) {
        return;
    }
    
    if (self.viewControllers.count == 1) {
        [self.tabBarController.navigationController popViewControllerAnimated:YES];
    } else {
        [self popViewControllerAnimated:YES];
    }
}

- (void)clickMySpaceDown:(NXPullDownButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self.tabBarController.tabBar setHidden:YES];
        self.currentShowVC.navigationItem.rightBarButtonItems = nil;
        self.currentShowVC.navigationItem.leftBarButtonItems = nil;
        NXMyProjectsViewController *projectVC = [[NXMyProjectsViewController alloc] initWithExceptModel:[self.projectModel copy]];
        projectVC.showGoToSpace = YES;
        [self addChildViewController:projectVC];
        [self.view addSubview:projectVC.view];
        [projectVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.navigationBar.mas_bottom);
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideBottom);
        }];
        projectVC.view.alpha = 0.0;
        [projectVC beginAppearanceTransition:YES animated:YES];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
             projectVC.view.alpha = 1.0;
         } completion:^(BOOL finished) {
             [projectVC endAppearanceTransition];
             [projectVC didMoveToParentViewController:self];
         }];
        self.pullDownProjectsVC = projectVC;
    } else {
        if ([_currentShowVC isKindOfClass:[NXPeopleViewController class]]) {
           NXPeopleViewController *peopleVC = (NXPeopleViewController *)self.currentShowVC;
            [peopleVC configureNavigationRightBarButtons];
            } else if ([_currentShowVC isKindOfClass:[NXProjectFilesVC class]]) {
            NXProjectFilesVC *filesVC = (NXProjectFilesVC *)self.currentShowVC;
            [filesVC configureNavigationRightBarButtons];
            }else if([_currentShowVC isKindOfClass:[NXProjectSummaryVC class]]){
                NXProjectSummaryVC *summaryVC = (NXProjectSummaryVC *)self.currentShowVC;
                [summaryVC configureNavigationBarButtons];
            }
        [self.tabBarController.tabBar setHidden:NO];
        [self.pullDownProjectsVC willMoveToParentViewController:nil];
        [self.pullDownProjectsVC beginAppearanceTransition:NO animated:YES];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
             self.pullDownProjectsVC.view.alpha = 0.0;
         } completion:^(BOOL finished) {
             [self.pullDownProjectsVC endAppearanceTransition];
             [self.pullDownProjectsVC.view removeFromSuperview];
             [self.pullDownProjectsVC removeFromParentViewController];
             self.pullDownProjectsVC = nil;
         }];
    }
}

#pragma mark
- (NXPullDownButton *)titleView {
     NSString *buttonTitle = self.projectModel.name;
    CGSize buttonSize = [self sizeOfLabelWithCustomMaxWidth:self.view.bounds.size.width/4 * 3 systemFontSize:14 andFilledTextString:buttonTitle];
    NXPullDownButton *pullDownBtn = [[NXPullDownButton alloc]init];
    pullDownBtn.frame = CGRectMake(0, 0,buttonSize.width/0.69, 30);
    pullDownBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    pullDownBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [pullDownBtn addTarget:self action:@selector(clickMySpaceDown:) forControlEvents:UIControlEventTouchUpInside];
    pullDownBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [pullDownBtn setTitle:buttonTitle forState:UIControlStateNormal];
    [pullDownBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pullDownBtn setImage:[UIImage imageNamed:@"down arrow - black1"] forState:UIControlStateNormal];
    [pullDownBtn setImage:[UIImage imageNamed:@"up arrow - black1"] forState:UIControlStateSelected];
    return pullDownBtn;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[NXMyProjectsViewController class]]) {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
    [self clickMySpaceDown:nil];
    viewController.navigationItem.titleView = [self titleView];
    _currentShowVC = viewController;
    
}

#pragma mark ---->return size from title size
- (CGSize)sizeOfLabelWithCustomMaxWidth:(CGFloat)width systemFontSize:(CGFloat)fontSize andFilledTextString:(NSString *)str{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = str;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:fontSize];
    [label sizeToFit];
    CGSize size = label.frame.size;
    return size;
}

@end
