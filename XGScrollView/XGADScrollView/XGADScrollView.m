//
//  XGADScrollView.m
//  XGScrollView
//
//  Created by hzsydev on 15/8/31.
//  Copyright (c) 2015年 syg. All rights reserved.
//  循环滚动广告的ScrollView

#import "XGADScrollView.h"
#import "UIImageView+WebCache.h"

#define KLPageHeight     30.0

// 根据16位RBG值转换成颜色，格式:KLColorFrom16RGB(0xFF0000)
#define KLColorFrom16RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// 根据10位RBG值转换成颜色, 格式:KLColorFrom10RBG(255,255,255)
#define KLColorFrom10RGB(RED, GREEN, BLUE) [UIColor colorWithRed:RED/255.0 green:GREEN/255.0 blue:BLUE/255.0 alpha:1.0]

@interface XGADScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView       *scrollView;
@property (nonatomic, strong) UIPageControl      *pageControl;
@property (nonatomic, strong) NSMutableArray     *dataArray;
@property (nonatomic, strong) NSTimer            *timer;
@property (nonatomic, assign) CGFloat             lastPointX;
@property (nonatomic, assign) NSTimeInterval      timeInterval;// 定时器时间间隔
@property (nonatomic, assign) BOOL                moveLeft;
@property (nonatomic, assign) BOOL                isUserDrag;// 是用户拖拽 而不是系统反弹

@end

@implementation XGADScrollView
//MARK: - 懒加载
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray  arrayWithCapacity:0];
    }
    return _dataArray;
}

//MARK: - 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self layoutScrollView];
    }
    return self;
}

//MARK: - 布局ScrollView
- (void)layoutScrollView{
    
    self.timeInterval = 2.0;
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.clipsToBounds = YES;
    [self addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0, (self.frame.size.height -KLPageHeight), self.frame.size.width, KLPageHeight)];
    _pageControl.currentPageIndicatorTintColor = KLColorFrom16RGB(0xf36815);
    _pageControl.currentPage = 0;
    _pageControl.clipsToBounds = YES;
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [self addSubview:_pageControl];
}

//MARK: - 设置UIScrollView图片的显示(外部调用)
- (void)setADScrollViewContent:(NSArray *)imgDataArray{
    
    
    if (imgDataArray.count > 0) {
        
        [self.dataArray  removeAllObjects];
        [self.dataArray  addObjectsFromArray:imgDataArray];
        
        if (imgDataArray.count == 1) {
            
            UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
            imageView.backgroundColor = [UIColor whiteColor];
            
            XGModel  *tempModel = [imgDataArray firstObject];
            // xfxc_icon02占位图片
            [imageView sd_setImageWithURL:[NSURL URLWithString:tempModel.imageUrl] placeholderImage:[UIImage imageNamed:@"xfxc_icon02"]];
            imageView.tag = 2;
            imageView.userInteractionEnabled = YES;
            [_scrollView addSubview:imageView];
            
            //加手势
            UITapGestureRecognizer  *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouch:)];
            tapGesture.numberOfTapsRequired = 1;
            [imageView addGestureRecognizer:tapGesture];
            _scrollView.contentSize = CGSizeMake(self.frame.size.width, 0);
            
        }else{
            for (NSInteger i = 0; i< (imgDataArray.count+2); i++) {
                
                UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((i *self.frame.size.width), 0.0, self.frame.size.width, self.frame.size.height)];
                imageView.backgroundColor = [UIColor whiteColor];
                
                if (i == 0) {
                    XGModel  *tempModel = [imgDataArray lastObject];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:tempModel.imageUrl] placeholderImage:[UIImage imageNamed:@"xfxc_icon02"]];
                }else if (i == (imgDataArray.count+1)){
                    XGModel  *tempModel = [imgDataArray firstObject];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:tempModel.imageUrl] placeholderImage:[UIImage imageNamed:@"xfxc_icon02"]];
                }else{
                    XGModel  *tempModel = imgDataArray[i-1];
                    [imageView sd_setImageWithURL:[NSURL URLWithString:tempModel.imageUrl] placeholderImage:[UIImage imageNamed:@"xfxc_icon02"]];
                }
                
                imageView.tag = i+1;
                imageView.userInteractionEnabled = YES;
                [_scrollView addSubview:imageView];
                
                //加手势
                UITapGestureRecognizer  *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouch:)];
                tapGesture.numberOfTapsRequired = 1;
                [imageView addGestureRecognizer:tapGesture];
            }
            _scrollView.contentSize = CGSizeMake((imgDataArray.count+2) * self.frame.size.width, 0);
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
        }
        
        if (imgDataArray.count > 1){
            _pageControl.hidden = NO;
            _pageControl.numberOfPages = imgDataArray.count;
        }else{
            _pageControl.hidden = YES;
        }
    }else{}
    
}

// 图片点击
- (void)imageTouch:(UITapGestureRecognizer *)tap {
    NSInteger  index = tap.view.tag -1;
    if (self.dataArray.count > (index-1)) {
        XGModel  *model = self.dataArray[(index - 1)];
        if ([self.delegate  respondsToSelector:@selector(adScrollViewImageTouch:)]) {
            [self.delegate adScrollViewImageTouch:model];
        }
    }
}


//MARK: - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == _scrollView) {
        if (scrollView.contentOffset.x <= 0) {
            [scrollView setContentOffset:CGPointMake(self.frame.size.width *(self.dataArray.count), 0)];
        }else if (scrollView.contentOffset.x >= self.frame.size.width *(self.dataArray.count +1)){
            [scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
        }
        NSInteger page = (scrollView.contentOffset.x/self.frame.size.width) -1;
        _pageControl.currentPage = page;
        
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    if (scrollView == _scrollView){
        
        if (scrollView.contentOffset.x <= 0) {
            [scrollView setContentOffset:CGPointMake(self.frame.size.width *(self.dataArray.count), 0)];
        }else if (scrollView.contentOffset.x >= self.frame.size.width *(self.dataArray.count +1)){
            [scrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
        }
        
        NSInteger page = (scrollView.contentOffset.x/self.frame.size.width) -1;
        _pageControl.currentPage = page;
        _scrollView.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (fabs(scrollView.contentOffset.x - _lastPointX) < 50.0) {
        
        if (scrollView.contentOffset.x > _lastPointX) {
            _moveLeft = NO;
        }else{
            _moveLeft = YES;
        }
    }
    _lastPointX = scrollView.contentOffset.x;
    
    if (self.isUserDrag) {
        
        [self  cancelTimer];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 开始时,标记置真
    self.isUserDrag = YES;
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 结束时,置flag还原
    if (self.isUserDrag) {
        [self  addTimerWithTimeInterval:self.timeInterval];
    }
    self.isUserDrag = NO;
}

//MARK: - 定时器相关
-(void)addTimerWithTimeInterval:(NSTimeInterval)ti
{
    if (nil == self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(update:) userInfo:nil repeats:YES];
        //[self.timer fire];
        // 提高定时器运行的优先级
        [[NSRunLoop  currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

// 取消定时器
- (void)cancelTimer{
    
    if (self.timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

// 图片滚动
- (void)update:(NSTimer *)timer{
    
    if (self.dataArray.count > 1) {
        if (_moveLeft) {
            [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x - self.frame.size.width, 0.0) animated:YES];
        }else{
            [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + self.frame.size.width, 0.0) animated:YES];
        }
    }
}

//MARK: - 开启自动滚动
- (void)startScrollWithTimeInterval:(NSTimeInterval)ti{
    
    if (ti == 0.0) {
        ti = 2.0;
    }
    
    self.timeInterval = ti;
    
    [self  addTimerWithTimeInterval:ti];
    
}

// 停止滚动
- (void)stopScroll{
    [self  cancelTimer];
}

//MARK: - dealloc
- (void)dealloc
{
    _scrollView.delegate = nil;
    
}


@end
