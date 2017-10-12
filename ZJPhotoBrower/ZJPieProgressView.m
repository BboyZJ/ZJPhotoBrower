//
//  ZJPieProgressView.m
//  ZJPhotoBrower
//
//  Created by 张建 on 2017/4/21.
//  Copyright © 2017年 JuZiShu. All rights reserved.
//

#import "ZJPieProgressView.h"

#define ZJColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@implementation ZJPieProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

//赋值
- (void)setProgressValue:(CGFloat)progressValue{
    
    _progressValue = progressValue;
    
    if (self.tag == 1) {
        
        NSLog(@"%f",progressValue);
    }
    if (progressValue == 1.0) {
        
        self.hidden = YES;
    }else {
        
        //重绘
        [self setNeedsDisplay];
    }
}

//绘制
- (void)drawRect:(CGRect)rect{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //画外圆
    [ZJColor(255.0, 255.0, 255.0, 0.8) set];
    
    CGContextAddArc(ctx, rect.size.width/2, rect.size.height/2,10 * 2 + 2,0 , M_PI*2, 0);
    CGContextStrokePath(ctx);
    ;
    //画内圆
    CGContextSetLineWidth(ctx, 10 * 2);
    CGContextAddArc(ctx, rect.size.width/2, rect.size.height/2, 10,- M_PI_2 , - M_PI_2 + M_PI * 2 * _progressValue, 0);
    CGContextStrokePath(ctx);
    
}

@end
