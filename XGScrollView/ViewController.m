//
//  ViewController.m
//  XGScrollView
//
//  Copyright (c) 2015年 syg. All rights reserved.
//

#import "ViewController.h"
#import "XGADScrollView.h"

@interface ViewController ()<XGADScrollViewDelegate>

@property (nonatomic, strong) XGADScrollView     *adScrollView;
@property (nonatomic, strong) NSMutableArray     *imageArray;

@end

@implementation ViewController

#pragma mark - 懒加载

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray  arrayWithCapacity:0];
    }
    return _imageArray;
}

#pragma mark - 声明周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"循环滚动广告图片";
    
    [self initDatas];
    self.automaticallyAdjustsScrollViewInsets = NO; // 设置为no 防止ScrollView变形
    
    _adScrollView = [[XGADScrollView alloc]initWithFrame:CGRectMake(0.0, 64.0, self.view.frame.size.width, 0.5*self.view.frame.size.width)];
    _adScrollView.backgroundColor = [UIColor whiteColor];
    _adScrollView.delegate = self;
    [self.view addSubview:_adScrollView];
    
    if (self.imageArray.count > 0) {
        [_adScrollView  setADScrollViewContent:self.imageArray];
    }
}

// 页面将要消失 停止定时器
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.adScrollView superview]) {
        [self.adScrollView stopScroll];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    //定时器在View将要显示的时候开启，在View消失的时候解除
    if ([self.adScrollView superview]) {
        [self.adScrollView startScrollWithTimeInterval:5.0];
    }
}

// 初始化数据（直接从百度找了一些图片）
- (void)initDatas {
    
    NSArray *imgUrlArr = @[@"http://www.qq1234.org/uploads/allimg/140610/3_140610105824_9.jpg",@"http://img5q.duitang.com/uploads/item/201502/22/20150222191048_e4Uac.jpeg",@"http://img5q.duitang.com/uploads/item/201506/05/20150605140911_uNhQY.jpeg",@"http://www.qqzhi.com/uploadpic/2014-09-05/160840259.jpg",@"http://img4q.duitang.com/uploads/item/201504/04/20150404H0051_HyRvJ.jpeg",@"http://v1.qzone.cc/avatar/201408/22/21/13/53f741f95904e103.jpg!200x200.jpg",@"http://v1.qzone.cc/avatar/201404/13/11/12/534a00b62633e072.jpg!200x200.jpg",@"http://p.3761.com/pic/27891417049690.jpg"];
    NSArray *imgIDArr = @[@"9527",@"10086",@"10010",@"4036",@"1314",@"710",@"718",@"90718"];
    
    for (NSInteger i = 0; i < imgUrlArr.count ; i++) {
        XGModel  *model = [[XGModel  alloc] init];
        model.imageUrl = imgUrlArr[i];
        model.imageID = imgIDArr[i];
        [self.imageArray  addObject:model];
    }
}

#pragma mark - KLADScrollViewDelegate

- (void)adScrollViewImageTouch:(XGModel *)imageModel {
    
    NSLog(@"点击的图片id是==%@==",imageModel.imageID);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
