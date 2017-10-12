//
//  ZJPhotoBrower.m
//  ZJPhotoBrower
//
//  Created by 张建 on 2017/4/21.
//  Copyright © 2017年 JuZiShu. All rights reserved.
//

#import "ZJPhotoBrower.h"
#import "ZJPhotoImageView.h"
#import "UIImageView+WebCache.h"
#import "ZJPieProgressView.h"

//屏幕宽
#define KScreenW [UIScreen mainScreen].bounds.size.width
#define KScreenH [UIScreen mainScreen].bounds.size.height
#define ZJKeyWindow [UIApplication sharedApplication].keyWindow

@interface ZJPhotoBrower ()<UIScrollViewDelegate>

//底层滑动的scrollView
@property (nonatomic,strong)UIScrollView * scrollView;
//黑色背景View
@property (nonatomic,strong)UIView * backView;
//工具栏
@property (nonatomic,strong)UIView * toolView;
//页面个数
@property (nonatomic,strong)UIPageControl * pageControll;
//原始frame数组
@property (nonatomic,strong)NSMutableArray * originRectsArr;
//是不是双击
@property (nonatomic,assign)BOOL isZone;

@end


@implementation ZJPhotoBrower
//懒加载
-(NSMutableArray *)originRectsArr{
    
    if (_originRectsArr == nil) {
        
        _originRectsArr = [NSMutableArray array];
        
    }
    return _originRectsArr;
    
}
//1.类方法创建
+ (instancetype)photoBrowser{
    
    return [[self alloc] init];
    
}
//1.1初始化
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        //2.1创建黑色背景
        [self setupBackView];
        
        //2.2创建scrollView
        [self setupScrollView];
        
        //2.3工具栏
        [self setupToolView];
        
        //3.4页面个数
        [self setupPageControll];
    }
    
    return self;
}

//2.1创建黑色背景
- (void)setupBackView{
    
    if (_backView == nil) {
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,KScreenW , KScreenH)];
        _backView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backView];
    }
    
}

//2.2创建scrollView
- (void)setupScrollView{
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = YES;
    _scrollView.tag = 101;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.frame = CGRectMake(0, 0,KScreenW,KScreenH);
    [self addSubview:_scrollView];
    
}
//2.3工具栏
- (void)setupToolView{
    
    _toolView = [[UIView alloc] init];
    _toolView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.5];
    _toolView.frame = CGRectMake(0, KScreenH - 50, KScreenW, 50);
    [self addSubview:_toolView];
    
    UILabel * label = [[UILabel alloc] init];
    label.frame = _toolView.bounds;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"此处是工具栏";
    label.backgroundColor = [UIColor clearColor];
    [_toolView addSubview:label];
    
}
//3.4页面个数
- (void)setupPageControll{
    
    _pageControll = [[UIPageControl alloc] init];
    _pageControll.backgroundColor = [UIColor clearColor];
    _pageControll.frame = CGRectMake(0, KScreenH - 70, KScreenW, 20);
    //分选中的颜色
    _pageControll.pageIndicatorTintColor = [UIColor darkGrayColor];
    //选中的颜色
    _pageControll.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:_pageControll];
}

//3.显示当前的浏览器
- (void)show{
    
    //3.1添加photoBrower
    [ZJKeyWindow addSubview:self];
    
    //3.2获取原始的frame
    [self setupOriginRects];
    
    //3.3设置滚动距离
    _scrollView.contentSize = CGSizeMake(KScreenW * self.photos.count, 0);
    _scrollView.contentOffset = CGPointMake(KScreenW * self.currentIndex, 0);
    
    //3.4创建子视图
    [self setupSmallScrollViews];
    
    //3.5页面个数
    _pageControll.numberOfPages = self.photos.count;
    _pageControll.currentPage = self.currentIndex;
    
}
//3.2获取原始图片的frame-在其父视图
- (void)setupOriginRects{
    
    for (ZJPhotoImageView * phoho in self.photos) {
        
        UIImageView * sourceImgView = phoho.sourceImageView;
        CGRect sourceF = [ZJKeyWindow convertRect:sourceImgView.frame fromView:sourceImgView.superview];
        [self.originRectsArr addObject:[NSValue valueWithCGRect:sourceF]];
    }
}
//3.4创建子视图
- (void)setupSmallScrollViews{
    
    __weak ZJPhotoBrower * weakSelf = self;
    
    for (int i = 0; i < self.photos.count; i ++) {
        
        //3.4.1缩放图片的scrollView
        UIScrollView * smallScrollView = [self creatSmallScrollView:i];
        //3.4.2添加photoImgView,并且添加点击和双击事件
        ZJPhotoImageView * photo = [self addTapWithTag:i];
        photo.frame = CGRectMake(0, 0, KScreenW, KScreenW);
        photo.center = smallScrollView.center;
        photo.backgroundColor = [UIColor redColor];
        [smallScrollView addSubview:photo];
        
        //3.4.3创建饼状进度视图
        ZJPieProgressView * loop = [self creatLoopWithTag:i];
        [smallScrollView addSubview:loop];
        
        //url
        NSURL * bigImgUrl = [NSURL URLWithString:photo.bigImgUrl];
        
        //检查图片是否已经缓存过
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:photo.bigImgUrl done:^(UIImage *image, SDImageCacheType cacheType) {
            
            if (image == nil) {
                
                NSLog(@"没缓存过");
                //显示进度
                loop.hidden = NO;
            }
            
        }];
        
        //设置图片
        [photo sd_setImageWithURL:bigImgUrl placeholderImage:[UIImage imageNamed:@"default.png"] options:SDWebImageRetryFailed | SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
            //设置进度条
            NSLog(@"%f",(CGFloat)receivedSize / (CGFloat)expectedSize);
            loop.progressValue = (CGFloat)receivedSize/(CGFloat)expectedSize;
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            //下载成功
            if (image != nil) {
                
                //隐藏进度条
                loop.hidden = YES;
                
                //下载下来的图片
                if (cacheType == SDImageCacheTypeNone) {
                    
                    //3.4.3
                    [weakSelf setupPhotoFrame:photo];
                    
                }else {
                    
                    photo.frame = [weakSelf.originRectsArr[i] CGRectValue];
                    [UIView animateWithDuration:0.3 animations:^{
                       
                        [weakSelf setupPhotoFrame:photo];
                        
                    }];
                    

                }
            }
            //下载失败
            else {
                
                //图片下载失败
                photo.bounds = CGRectMake(0, 0, 240, 240);
                photo.center = CGPointMake(KScreenW / 2, KScreenH / 2);
                photo.contentMode = UIViewContentModeScaleAspectFit;
                photo.image = [UIImage imageNamed:@"preview_image_failure"];
                
                //进度条移除
                [loop removeFromSuperview];
                
            }
            
        }];
    }
}
//3.4.1-缩放图片的scrollView
- (UIScrollView *)creatSmallScrollView:(int)tag{
    
    UIScrollView *smallScrollView = [[UIScrollView alloc] init];
    smallScrollView.backgroundColor = [UIColor blackColor];
    smallScrollView.tag = tag;
    smallScrollView.frame = CGRectMake(KScreenW * tag, 0, KScreenW, KScreenH - 50);
    smallScrollView.delegate = self;
    smallScrollView.maximumZoomScale=3.0;
    smallScrollView.minimumZoomScale=1;
    [self.scrollView addSubview:smallScrollView];
    
    return smallScrollView;
    
}
//3.4.2-点击和双击事件
- (ZJPhotoImageView *)addTapWithTag:(int)tag{
    
    ZJPhotoImageView * photo = self.photos[tag];
    //单击
    UITapGestureRecognizer * photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap:)];
    [photo addGestureRecognizer:photoTap];
    //双击
    UITapGestureRecognizer * zoneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoneTap:)];
    zoneTap.numberOfTapsRequired = 2;
    [photo addGestureRecognizer:zoneTap];
    
    //zonmTap失败了再执行photoTap，否则zonmTap永远不会被执行
    [photoTap requireGestureRecognizerToFail:zoneTap];
    
    return photo;

}
//单击
- (void)photoTap:(UITapGestureRecognizer *)tap {
    
    //1.将图片缩放回一倍，然后再缩放回原来的frame，否则由于屏幕太小动画直接从3倍缩回去，看不完整
    ZJPhotoImageView * photo = (ZJPhotoImageView *)tap.view;
    UIScrollView * smallScrollView = (UIScrollView *)photo.superview;
    smallScrollView.zoomScale = 1.0;
    
    //2.如果是长图片先将其移动到CGPointMake(0, 0)在缩放回去
    if (CGRectGetHeight(photo.frame) > KScreenH) {
        smallScrollView.contentOffset = CGPointMake(0, 0);
    }
    
    //3.再取出原始frame，缩放回去
    CGRect frame = [self.originRectsArr[photo.tag] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        
        photo.frame = frame;
        _backView.alpha = 0;
        
    }completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
    
}
//双击
- (void)zoneTap:(UITapGestureRecognizer *)tap{
    
    int currentIndex = (int)tap.view.tag;
    if (self.currentIndex == currentIndex && currentIndex != 101) {
        
        if (_isZone) {
            
            
            [UIView animateWithDuration:0.3 animations:^{
                
                UIScrollView *smallScrollView = (UIScrollView *)tap.view.superview;
                smallScrollView.zoomScale = 1.0;
                
            } completion:^(BOOL finished) {
                
                //没双击
                _isZone = NO;
            }];

            
        }else {
            
            [UIView animateWithDuration:0.3 animations:^{
                
                UIScrollView *smallScrollView = (UIScrollView *)tap.view.superview;
                smallScrollView.zoomScale = 3.0;
                
            } completion:^(BOOL finished) {
                
                //双击了
                _isZone = YES;
            }];
        }
    }
    
    
   
    
}
//3.4.3-创建饼状进度条
- (ZJPieProgressView *)creatLoopWithTag:(int)tag{
    
    ZJPieProgressView *loop = [[ZJPieProgressView alloc] init];
    loop.tag = tag;
    loop.frame = CGRectMake(0,0 , 80, 80);
    loop.center = CGPointMake(KScreenW / 2, KScreenH / 2);
    loop.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    loop.hidden = YES;
    UITapGestureRecognizer *loopTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loopTap:)];
    [loop addGestureRecognizer:loopTap];
    return loop;
    
}
//单击
- (void)loopTap:(UITapGestureRecognizer *)tap{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _backView.alpha = 0;
        tap.view.alpha = 0;
        
    }completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
    
}

//3.4.4-设置图片的frame
- (void)setupPhotoFrame:(ZJPhotoImageView *)photo{
    
    UIScrollView *smallScrollView = (UIScrollView *)photo.superview;
    
    _backView.alpha = 1.0f;
    
    CGFloat ratio = (double)photo.image.size.height/(double)photo.image.size.width;
    
    CGFloat bigW = KScreenW;
    CGFloat bigH = KScreenW * ratio;

    if (bigH < KScreenH - 50) {
        
        photo.bounds = CGRectMake(0, 0, bigW, bigH);
        photo.center = CGPointMake(KScreenW / 2, KScreenH / 2);
    }
    //设置长图的frame
    else{
        
        photo.frame = CGRectMake(0, 0, bigW, KScreenH - 50);
        smallScrollView.contentSize = CGSizeMake(KScreenW, KScreenH - 50);
    }
}

#pragma mark ---UIScrollViewDelegate---
//返回将要缩放的UIView对象，多次执行
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    
    if (scrollView.tag == 101) return nil;
    
    ZJPhotoImageView * photo = self.photos[scrollView.tag];
    
    return photo;
}
//当scrollView缩放时，调用该方法，在缩放过程中，会多次调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if (scrollView.tag == 101) return;
    
    ZJPhotoImageView * photo = (ZJPhotoImageView *)self.photos[scrollView.tag];
    CGFloat photoY = (KScreenH - photo.frame.size.height) / 2;
    CGRect photoF = photo.frame;
    
    if (photoY>0) {
        
        photoF.origin.y = photoY;
        
    }else{
        
        photoF.origin.y = 0;
        
    }
    
    photo.frame = photoF;
    
}
//当缩放结束后，并且缩放大小回到minimumZoomScale与maxZoomScale之间后（我们也许会超出缩放范围）,调用该方法
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    //如果结束缩放后scale为1时，跟原来的宽高会有些轻微的出入，导致无法滑动，需要将其调整为原来的宽度
    if (scale == 1.0) {
        
        CGSize tempSize = scrollView.contentSize;
        tempSize.width = KScreenW;
        scrollView.contentSize = tempSize;
        CGRect tempF = view.frame;
        tempF.size.width = KScreenW;
        view.frame = tempF;
        
    }
    
}
//滑动减速时调用该方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int currentIndex = scrollView.contentOffset.x / KScreenW;
    
    if (self.currentIndex != currentIndex && scrollView.tag == 101) {
        
        self.currentIndex = currentIndex;
        
        //当前的页面
        _pageControll.currentPage = self.currentIndex;
        
        for (UIView *view in scrollView.subviews) {
            
            if ([view isKindOfClass:[UIScrollView class]]) {
                
                UIScrollView *scrollView = (UIScrollView *)view;
                scrollView.zoomScale = 1.0;
            }
            
        }
        
    }
    
}
#pragma mark 设置frame
-(void)setFrame:(CGRect)frame{
    
    frame = CGRectMake(0, 0, KScreenW, KScreenH);
    
    [super setFrame:frame];
    
}


@end
