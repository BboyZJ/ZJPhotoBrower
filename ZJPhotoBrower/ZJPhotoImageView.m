//
//  ZJPhotoImageView.m
//  ZJPhotoBrower
//
//  Created by 张建 on 2017/4/21.
//  Copyright © 2017年 JuZiShu. All rights reserved.
//

#import "ZJPhotoImageView.h"

@implementation ZJPhotoImageView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        //不裁剪的话，缩放的时候会看到两边多余的部分
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        
    }
    return self;
}

@end
