//
//  ViewController.m
//  ZJPhotoBrower
//
//  Created by 张建 on 2017/4/21.
//  Copyright © 2017年 JuZiShu. All rights reserved.
//

#import "ViewController.h"
#import "ZJPhotoImageView.h"
#import "ZJPhotoBrower.h"

#define kImageWidth 100
#define kImageHeight 100
#define kImageMargin 5

@interface ViewController ()

//imageViewsArr
@property (nonatomic,strong)NSMutableArray * imageViewsArr;
//URL数组
@property (nonatomic,strong) NSMutableArray *bigImgUrls;

@end

@implementation ViewController

//imageViewsArr
- (NSMutableArray *)imageViewsArr {
    
    if (_imageViewsArr == nil) {
        
        _imageViewsArr = [NSMutableArray array];
    }
    
    return _imageViewsArr;
}
//URL数组
-(NSMutableArray *)bigImgUrls{
    
    if (_bigImgUrls==nil) {
        
        // 加载plist中的字典数组
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Picture.plist" ofType:nil];
        NSArray *tempUrls = [NSArray arrayWithContentsOfFile:path];
        _bigImgUrls = [NSMutableArray arrayWithArray:tempUrls];
        
    }
    
    return _bigImgUrls;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.创建子视图
    [self setupImgViews];
    
}

//1.创建子视图
- (void)setupImgViews{
    
    for (int i = 0; i < 9; i ++) {
        
        //1.1创建iamgeView
        UIImageView * child = [[UIImageView alloc] init];
        child.backgroundColor = [UIColor greenColor];
        child.userInteractionEnabled = YES;
        child.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i + 1]];
        child.clipsToBounds = YES;
        child.contentMode = UIViewContentModeScaleAspectFill;
        child.tag = i;
        
        //1.2添加手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [child addGestureRecognizer:tap];
        
        //1.3设置frame
        //列数
        int column = i % 3;
        //行数
        int row = i / 3;
        //根据列数和行数算出x,y
        int childX = column * (kImageWidth + kImageMargin) + 30;
        int childY = row *  (kImageHeight + kImageMargin) + 30;
        child.frame = CGRectMake(childX, childY, kImageWidth, kImageHeight);
        
        //1.4添加自视图
        [self.view addSubview:child];
        
        //1.5子视图数组
        [self.imageViewsArr addObject:child];
    }
}

//2.点击图片的事件
- (void)imageTap:(UITapGestureRecognizer *)tap {
    
    NSLog(@"点击了图片的事件");
    
    //2.1创建ZJPhoto数组
    NSMutableArray * photos = [NSMutableArray array];
    
    for (int i = 0; i < self.imageViewsArr.count; i ++) {
        
        UIImageView * child = self.imageViewsArr[i];
        
        ZJPhotoImageView * photo = [[ZJPhotoImageView alloc] init];
        //设置原始imageView
        photo.sourceImageView = child;
        //设置大图URL
        photo.bigImgUrl = self.bigImgUrls[i];
        //设置图片tag
        photo.tag = i;
        //添加到Photo数组
        [photos addObject:photo];
        
    }
    
    //2.2创建图片浏览器
    ZJPhotoBrower * photoBrower = [ZJPhotoBrower photoBrowser];
    //设置ZJPhoto数组
    photoBrower.photos = photos;
    //设置当前要显示图片的tag
    photoBrower.currentIndex = (int)tap.view.tag;
    //显示图片浏览器
    [photoBrower show];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
