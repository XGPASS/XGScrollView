//
//  XGModel.h
//  XGScrollView
//
//  Created by hzsydev on 15/8/31.
//  Copyright (c) 2015年 syg. All rights reserved.
//  循环滚动广告用到的model

#import "JSONModel.h"

@interface XGModel : JSONModel

@property (nonatomic, copy) NSString <Optional>     *imageUrl;      // 图片地址
@property (nonatomic, copy) NSString <Optional>     *imageID;       // 图片id
@property (nonatomic, copy) NSString <Optional>     *imageDescribe; // 图片描述

@end
