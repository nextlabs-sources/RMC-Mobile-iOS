//
//  NXSortByButtonRoundView.m
//  nxrmc
//
//  Created by EShi on 11/24/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXSortByButtonRoundView.h"

@interface NXSortByButtonRoundView()
@property(nonatomic, strong) CAShapeLayer *roundBackgroundLayer;

@end
@implementation NXSortByButtonRoundView


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // add round green back ground
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.actionButton.bounds.size.width / 2.0f, self.actionButton.bounds.size.height /2.0f) radius:((self.actionButton.bounds.size.width / 2.0f)-2.0f) startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(360) clockwise:YES];
    path.lineWidth = 0.1f;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    [self.roundBackgroundLayer removeFromSuperlayer];
    self.roundBackgroundLayer = [CAShapeLayer layer];
    self.roundBackgroundLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.roundBackgroundLayer.fillColor = RMC_MAIN_COLOR.CGColor;
    self.roundBackgroundLayer.path = path.CGPath;
    [self.actionButton.layer insertSublayer:self.roundBackgroundLayer below:self.actionButton.layer.sublayers.firstObject];
    
    if (self.actionButton.isSelected) {
        self.roundBackgroundLayer.hidden = YES;
    }else
    {
         self.roundBackgroundLayer.hidden = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"]) {
        BOOL isSelected = ((NSNumber *)change[@"new"]).boolValue;
        if (isSelected) {
            self.roundBackgroundLayer.hidden = YES;
        }else
        {
            self.roundBackgroundLayer.hidden = NO;
        }
    }
}
@end
