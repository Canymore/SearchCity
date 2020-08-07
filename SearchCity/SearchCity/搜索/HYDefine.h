//
//  HYDefine.h
//  SearchCity
//
//  Created by 曹海洋 on 2020/8/7.
//  Copyright © 2020 . All rights reserved.
//

#ifndef HYDefine_h
#define HYDefine_h

#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height

#define STATUS_HEIGHT           UIApplication.sharedApplication.statusBarFrame.size.height
#define NAV_HEIGHT              44.0
#define TAB_HEIGHT              49.0

#define SafeAreaTopHeight       (STATUS_HEIGHT + NAV_HEIGHT)
#define SafeAreaBottomHeight    (STATUS_HEIGHT == 44.0 ? 34.0 : 0)
#define SafeAreaHeight          (SCREEN_HEIGHT - (SafeAreaTopHeight) - SafeAreaBottomHeight)


#define image(image)            [UIImage imageNamed:image]
#define font(s)                 [UIFont fontWithName:@"PingFangSC-Regular" size:s]

#define rgb(r, g, b)            [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:1.0]
#define rgba(r, g, b, a)        [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]

#define Color_Title             [UIColor colorWithRed:51.0 / 255 green:51.0 / 255 blue:51.0 / 255 alpha:1.0]
#define Color_Separator         [UIColor colorWithRed:234.0 / 255 green:234.0 / 255 blue:234.0 / 255 alpha:1.0]
#define Color_Shadow            [UIColor colorWithRed:51.0 / 255 green:51.0 / 255 blue:51.0 / 255 alpha:0.05]
#define Color_Placeholder       [UIColor colorWithRed:187.0 / 255 green:187.0 / 255 blue:187.0 / 255 alpha:1.0]





#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* HYDefine_h */
