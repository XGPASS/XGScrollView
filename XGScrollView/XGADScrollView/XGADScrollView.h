//
//  XGADScrollView.h
//  XGScrollView
//
//  Created by hzsydev on 15/8/31.
//  Copyright (c) 2015年 syg. All rights reserved.
//  循环滚动广告的ScrollView

#import <UIKit/UIKit.h>
#import "XGModel.h"

@protocol XGADScrollViewDelegate <NSObject>
// 代理 
@optional
- (void)adScrollViewImageTouch:(XGModel *)imageModel ;
@end


@interface XGADScrollView : UIView
@property (nonatomic, weak) id<XGADScrollViewDelegate>  delegate;
/**
 * 设置UIScrollView图片的显示
 * imageArray数据源
 */
- (void)setADScrollViewContent:(NSArray *)imgDataArray;

- (void)startScrollWithTimeInterval:(NSTimeInterval)ti; ///< 启动定时器滚动 设置间隔时间(参数为零时，默认2.0秒)

- (void)stopScroll;///< 停止滚动

@end
