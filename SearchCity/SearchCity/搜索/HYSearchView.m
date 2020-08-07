//
//  HYSearchView.m
//  SearchCity
//
//  Created by 曹海洋 on 2020/8/7.
//  Copyright © 2020 . All rights reserved.
//

#import "HYSearchView.h"
#import "HYDefine.h"

@implementation HYSearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _searchIcon = image(@"qrscan_search");
        _clearIcon  = image(@"chacha");
        CGFloat hei = frame.size.height;
        
        self.leftViewMode = UITextFieldViewModeAlways;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, hei)];
        UIImageView *leftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(8, (hei - 16) / 2, 16, 16)];
        leftImgView.image = _searchIcon;
        [leftView addSubview:leftImgView];
        
        self.leftView = leftView;
        
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, hei)];
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(4, (hei - 16) / 2, 16, 16);
        [rightBtn setImage:_clearIcon forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:rightBtn];
        
        self.rightView = rightView;
        
        [self addTarget:self action:@selector(isShowClearBtn) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)clearText {
    self.text = @"";
    [self isShowClearBtn];
    [self resignFirstResponder];
}

// 是否显示clearBtn
- (void)isShowClearBtn {
    if (self.text.length > 0) {
        self.rightViewMode = UITextFieldViewModeAlways;
    }
    else {
        self.rightViewMode = UITextFieldViewModeNever;
    }
    
    if (self.textChangedBlock) {
        self.textChangedBlock([self.text copy]);
    }
}

@end
