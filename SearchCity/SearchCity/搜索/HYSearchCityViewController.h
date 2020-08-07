//
//  HYSearchCityViewController.h
//  SearchCity
//
//  Created by 曹海洋 on 2020/8/7.
//  Copyright © 2020 . All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYSearchCityViewController : UIViewController

// 当前定位的城市
@property(nonatomic, strong) NSString *curCity;

// 当选择一个城市的时候回调
@property(nonatomic, copy) void(^didSelectedCity)(NSString *city);

@end

NS_ASSUME_NONNULL_END
