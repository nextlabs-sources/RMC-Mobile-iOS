//
//  NXRoundButton.m
//  CoreAnimationDemo
//
//  Created by EShi on 11/8/16.
//  Copyright © 2016 Eren. All rights reserved.
//


#import "NXRoundButtonView.h"
#import "UIView+UIExt.h"
@interface NXRoundButtonView()
@property(nonatomic, assign) CGFloat radius;

@property(nonatomic, strong) UIColor *actionButtonSelectedColor;
@property(nonatomic, strong) UIColor *actionButtonNormalColor;

@property(nonatomic, assign) BOOL isCustomShadowPosition;
@property(nonatomic, assign) CGSize shadowOffset;
@property(nonatomic, assign) CGFloat shadowRadius;
@end
@implementation NXRoundButtonView
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.actionButton.frame = CGRectMake(self.bounds.size.width/2 - self.radius, self.bounds.size.height/2 - self.radius, self.radius * 2, self.radius *2);
    [self.actionButton cornerRadian:self.radius];
    
    self.actionButton.layer.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.9].CGColor;
    self.actionButton.layer.shadowOffset = self.isCustomShadowPosition? self.shadowOffset: CGSizeMake(1.0, 1.0); // work shadowRadius
    self.actionButton.layer.shadowRadius = self.isCustomShadowPosition? self.shadowRadius: 2.0f;
    self.actionButton.layer.shadowOpacity = 0.5;
}

- (instancetype)initWithRadius:(CGFloat)radius shadowOffset:(CGSize) shadowOffset shadowRadius:(CGFloat) shadowRadius
{
    self = [super init];
    if (self) {
        _isCustomShadowPosition = YES;
        _shadowOffset = shadowOffset;
        _shadowRadius = shadowRadius;
        
    }
    return [self initWithRadius:radius];
}
- (instancetype)initWithRadius:(CGFloat)radius
{
    self = [super initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)];
    if (self) {
        _radius = radius;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius
{
    self = [super initWithFrame:frame];
    if (self) {
        _radius = radius;
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _actionButton = [[UIButton alloc] init];
    [self.actionButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionButton addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
    [self.actionButton setAdjustsImageWhenHighlighted:NO];
    [self addSubview:_actionButton];
    self.backgroundColor = [UIColor clearColor];
}

- (BOOL)isSelected
{
    return self.actionButton.isSelected;
}

- (void)setSelected:(BOOL)selected
{
    [self.actionButton setSelected:selected];
}
- (void)dealloc
{
    [self.actionButton removeObserver:self forKeyPath:@"selected"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"]) {
        BOOL isSelected = ((NSNumber *)change[@"new"]).boolValue;
        if (isSelected) {
            self.actionButton.backgroundColor = self.actionButtonSelectedColor?: self.actionButton.backgroundColor;
        }else
        {
            self.actionButton.backgroundColor = self.actionButtonNormalColor?: self.actionButton.backgroundColor;
        }
    }
}

- (void)actionButtonClicked:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(nxroundButtonView:actionButtonShouldClicked:)]) {
        if (![self.delegate nxroundButtonView:self actionButtonShouldClicked:button]) {
            return;
        }
    }
    
    [self.actionButton setSelected:!self.actionButton.isSelected];
    if([self.delegate respondsToSelector:@selector(nxroundButtonView:actionButtonClicked:)])
    {
        [self.delegate nxroundButtonView:self actionButtonClicked:button];
    }
}

- (void)setBtnBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    if (state == UIControlStateNormal) {
        self.actionButtonNormalColor = color;
    }else if(state == UIControlStateSelected)
    {
        self.actionButtonSelectedColor = color;
    }
    if (self.actionButton.isSelected) {
        self.actionButton.backgroundColor = self.actionButtonSelectedColor?: self.actionButton.backgroundColor;
    }else
    {
        self.actionButton.backgroundColor = self.actionButtonNormalColor?: self.actionButton.backgroundColor;
    }
}
- (void)setBtnImage:(UIImage *)image forState:(UIControlState)state
{
    [self.actionButton setImage:image forState:state];
}

- (UIImage *) imageForState:(UIControlState)state
{
    return [self.actionButton imageForState:state];
}

@end
