//
//  NXLightView.m
//  
//
//  Created by tim on 14/10/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXLightView.h"
#import "UIImage+ColorToImage.h"
#import <WebKit/WebKit.h>

#define KSpotlightViewWidth     ([UIScreen mainScreen].bounds.size.width*2.0)
#define KSpotlightViewHeight    ([UIScreen mainScreen].bounds.size.height*0.2)

@interface NXLightView ()
@property (nonatomic,assign) BOOL isTouch;
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *imageViewA;
@property (nonatomic,strong) WKWebView *superWebView;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign)CGPoint currentPoint;
@end
@implementation NXLightView
- (instancetype)initWithFrame:(CGRect)frame andSuperView:(UIView*)supView {
    self=[super initWithFrame:frame];
    if (self) {
        self.superWebView = nil;
        for (UIView *subView in supView.subviews) {
            if ([subView isKindOfClass:[WKWebView class]]) {
                self.superWebView = (WKWebView *)subView;
                break;
            }
        }
        self.imageViewA=[[UIImageView alloc]init];
        self.imageViewA.image=[UIImage imageWithColor:RMC_MAIN_COLOR];
        
        self.imageViewA.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.imageViewA];
        
        id views = @{ @"imageViewA": self.imageViewA};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageViewA]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageViewA]|" options:0 metrics:nil views:views]];
        
    }
    return self;
}

- (void)addLightViewWithCenterPoint:(CGPoint)point {
    self.currentPoint=point;
    [self createTimer];
    UIGraphicsBeginImageContext(self.imageViewA.frame.size);
    CGContextRef con =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(con, RMC_MAIN_COLOR.CGColor);
    CGContextFillRect(con,[UIScreen mainScreen].bounds);
    
    CGFloat minRoundous = KScreenWidth < KScreenHeight ? KScreenWidth : KScreenHeight;
    
    CGContextAddArc(con, point.x, point.y, minRoundous/3.2, -M_PI, M_PI, 0);
//    CGContextAddRect(con,CGRectMake(point.x-KSpotlightViewWidth/2, point.y-KSpotlightViewHeight/2, KSpotlightViewWidth, KSpotlightViewHeight));;
    CGContextSetBlendMode(con, kCGBlendModeClear);
    CGContextFillPath(con);
    self.imageViewA.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch =[touches anyObject];
    CGPoint point =[touch locationInView:touch.view];
    if (!self.bgView) {
        self.bgView=[[UIView alloc]init];
        self.bgView.backgroundColor=RMC_MAIN_COLOR;
    }
    self.bgView.center=point;
    self.bgView.bounds=CGRectMake(0, 0, KSpotlightViewWidth, KSpotlightViewHeight*4);
    [self.imageViewA addSubview:self.bgView];
    [self addLightViewWithCenterPoint:point];

    [UIView animateWithDuration:1.5 animations:^{
        self.bgView.alpha=0;
    } completion:^(BOOL finished) {
            }];
    
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
       self.bgView.hidden=YES;
    UITouch *touch =[touches anyObject];
    CGPoint point =[touch locationInView:touch.view];
    [self addLightViewWithCenterPoint:point];
    
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.bgView.hidden=NO;
    [self invalidateTimer];
    UITouch *touch =[touches anyObject];
    CGPoint point =[touch locationInView:touch.view];
    self.bgView.center=point;

    [UIView animateWithDuration:1.5 animations:^{
        self.bgView.alpha=1;
    } completion:^(BOOL finished) {
         self.imageViewA.image=[UIImage imageWithColor:RMC_MAIN_COLOR];
     [self.bgView removeFromSuperview];
        self.bgView=nil;
        
    }];
    
}
- (void)createTimer {
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scrollToNext) userInfo:nil repeats:YES];
    }
}
- (void)scrollToNext {
    if (self.currentPoint.y>KScreenHeight-KSpotlightViewHeight/1.5&&self.superWebView.scrollView.contentOffset.y<=self.superWebView.scrollView.contentSize.height-KScreenHeight+44) {
        [self.superWebView.scrollView setContentOffset:CGPointMake(0, self.superWebView.scrollView.contentOffset.y+KSpotlightViewHeight/2) animated:YES];
    }else if (self.currentPoint.y<KSpotlightViewHeight/2&&self.superWebView.scrollView.contentOffset.y>0) {
        [self.superWebView.scrollView setContentOffset:CGPointMake(0, self.superWebView.scrollView.contentOffset.y-KSpotlightViewHeight/2) animated:YES];
    }

}
- (void)invalidateTimer {
    if (_timer) {
        [_timer invalidate];
        _timer=nil;
    }
}
@end
