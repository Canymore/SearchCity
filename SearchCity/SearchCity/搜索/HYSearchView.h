//
//  HYSearchView.h
//  SearchCity
//
//  Created by 曹海洋 on 2020/8/7.
//  Copyright © 2020 . All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYSearchView : UITextField

@property(nonatomic, strong) UIImage *searchIcon;
@property(nonatomic, strong) UIImage *clearIcon;

// 当输入框文本改变后
@property(nonatomic, copy) void(^textChangedBlock)(NSString *text);

@end

NS_ASSUME_NONNULL_END
