//
//  ZJPhotoImageView.h
//  ZJPhotoBrower
//
//  Created by 张建 on 2017/4/21.
//  Copyright © 2017年 JuZiShu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJPhotoImageView : UIImageView

/**
 *  原始imageView
 */
@property (nonatomic,strong)UIImageView * sourceImageView;

/**
 *  大图URL
 */
@property (nonatomic,strong) NSString * bigImgUrl;

@end
