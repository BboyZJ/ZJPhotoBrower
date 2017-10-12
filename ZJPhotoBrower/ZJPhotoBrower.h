//
//  ZJPhotoBrower.h
//  ZJPhotoBrower
//
//  Created by 张建 on 2017/4/21.
//  Copyright © 2017年 JuZiShu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJPhotoBrower : UIView

//存放图片的数组
@property (nonatomic,strong)NSArray * photos;

//当前的index
@property (nonatomic,assign)int currentIndex;

//显示当前浏览器
- (void)show;

//类方法返回图片浏览器
+ (instancetype)photoBrowser;

@end
