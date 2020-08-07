//
//  HYSearchCityViewController.m
//  SearchCity
//
//  Created by 曹海洋 on 2020/8/7.
//  Copyright © 2020 . All rights reserved.
//

#import "HYSearchCityViewController.h"
#import "HYSearchView.h"

#import "HYDefine.h"

@interface HYSearchCityViewController ()

<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

// 顶部搜索框
@property(nonatomic, strong) HYSearchView *searchView;
// 当前城市按钮
@property(nonatomic, strong) UIButton *curCityBtn;

// 列表
@property(nonatomic, strong) UITableView *aTableView;
@property(nonatomic, strong) NSArray *dataArr;              // 全部数据
@property(nonatomic, strong) NSMutableArray *searchArr;     // 搜索到的数据
@property(nonatomic, strong) NSString *frontText;           // 上一次请求搜索的数据，搜索完成后置nil

@end

@implementation HYSearchCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择城市";
    self.view.backgroundColor = [UIColor colorWithRed:240.0 / 255 green:241.0 / 255 blue:242.0 / 255 alpha:1.0];
    _curCity = @"北京市";          // 应由外部传入
    // 加载数据
    NSLog(@"加载数据%@", self.dataArr.count > 0 ? @"成功" : @"失败");
    _searchArr = [[NSMutableArray alloc] init];
    [_searchArr addObjectsFromArray:self.dataArr];
    
    // 初始化顶部视图
    [self initHeadView];
    
    // 初始化tableView
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, self.curCityBtn.frame.origin.y + self.curCityBtn.frame.size.height + 10, SCREEN_WIDTH - 20, SCREEN_HEIGHT - SafeAreaTopHeight - 70 - 54 - 37)];
    bgView.backgroundColor = [UIColor whiteColor];
    UIBezierPath *path4 = [UIBezierPath bezierPathWithRoundedRect:bgView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *tl = [CAShapeLayer layer];
    tl.path = path4.CGPath;
    tl.fillColor = [UIColor whiteColor].CGColor;
    bgView.layer.mask = tl;
    [self.view addSubview:bgView];
    
    _aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, SCREEN_HEIGHT - SafeAreaTopHeight - 70 - 54 - 37) style:UITableViewStyleGrouped];
    _aTableView.delegate = self;
    _aTableView.dataSource = self;
    _aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _aTableView.backgroundColor = [UIColor whiteColor];
    [_aTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cityCell"];
    
    [bgView addSubview:_aTableView];
    
    // 添加事件处理
    @weakify(self);
    _searchView.textChangedBlock = ^(NSString * _Nonnull text) {
        @strongify(self);
        // 先把之前的取消掉
        // 避免重复调用，在0.5秒内没有其他请求才开始搜索
        if (self.frontText) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchCityWithText:) object:self.frontText];
        }
        
        // 如果有搜索内容，就异步延迟搜索，如果没有搜索内容，就直接显示全部城市
        if (text.length > 0) {
            self.frontText = text;
            [self performSelector:@selector(searchCityWithText:) withObject:self.frontText afterDelay:0.5 inModes:@[NSRunLoopCommonModes]];
        }
        else {
            // 搜索框没有内容时，显示全部
            [self.searchArr removeAllObjects];
            [self.searchArr addObjectsFromArray:self.dataArr];
            [self.aTableView reloadData];
        }
    };
    
    // 添加按钮点击事件
    [_curCityBtn addTarget:self action:@selector(selectCurrentCity) forControlEvents:UIControlEventTouchUpInside];
    
}

// 通过关键字搜索城市，并刷新列表
- (void)searchCityWithText:(NSString *)text
{
    // 将输入的文字转化成拼音，便于搜索
    NSMutableString *pinyinText = [[NSMutableString alloc] initWithString:text];
    BOOL isPinyin = NO;
    // 开始转化
    if (CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformMandarinLatin, NO)) {
        // 转换后拼音不带声调
        if (CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformStripDiacritics, NO)) {
            // 拼音的搜索规则和汉字的搜索规则不一样
            if ([pinyinText isEqualToString:text]) {
                isPinyin = YES;
            }
        }
    }
    
    // 遍历字母列表
    [self.searchArr removeAllObjects];
    for (NSDictionary *dic in self.dataArr)
    {
        // 找到该字母下面的全部城市
        NSArray *cityArr = dic.allValues.firstObject;
        // 该字母下面的城市中搜索到的城市
        NSMutableArray *scArr = [[NSMutableArray alloc] init];
        // 遍历城市信息
        for (NSDictionary *cityDic in cityArr)
        {
            NSString *name = cityDic[@"name"];
            NSString *pinyin = cityDic[@"pinyin"];
            // 无空格的拼音
            NSString *noSpacePy = [cityDic[@"pinyin"] stringByReplacingOccurrencesOfString:@" " withString:@""];
            // 如果用户输入的是拼音，并且无空格拼音包含它，就算上
            if (isPinyin) {
                /*
                 用户输入：haer
                 匹配：哈尔滨，齐齐哈尔
                 */
                if ([noSpacePy.lowercaseString containsString:pinyinText.lowercaseString]) {
                    [scArr addObject:cityDic];
                }
            }
            else {
                if ([name containsString:text]) {
                    /*
                     用户输入：哈尔
                     匹配：哈尔滨，齐齐哈尔
                     */
                    [scArr addObject:cityDic];
                }
                else {
                    /*
                     用户输入：哈儿
                     匹配：哈尔滨，齐齐哈尔
                     用户输入：啊
                     匹配：阿克苏，阿坝
                     */
                    NSString *addSpacePinyin = [NSString stringWithFormat:@" %@ ", pinyin].lowercaseString;
                    NSString *addSpacePinyinText = [NSString stringWithFormat:@" %@ ", pinyinText].lowercaseString;
                    if ([addSpacePinyin containsString:addSpacePinyinText]) {
                        [scArr addObject:cityDic];
                    }
                }
            }
            
        }
        // 判断当前字母下面有没有搜索到相关的城市
        if (scArr.count > 0) {
            NSDictionary *scDic = @{dic.allKeys.firstObject: [[NSArray alloc] initWithArray:scArr]};
            [self.searchArr addObject:scDic];
        }
    }
    
    // 刷新列表
    [self.aTableView reloadData];
}

// 点击当前定位城市按钮，切换到当前定位的城市
- (void)selectCurrentCity {
    if (self.didSelectedCity) {
        self.didSelectedCity(self.curCity);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchView resignFirstResponder];
}

// section和row 分别对应的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.searchArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = self.searchArr[section];
    NSArray *arr = dic.allValues.lastObject;
    return arr.count;
}
// section的头视图的高度和显示的内容
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 显示的数据
    NSDictionary *dic = self.searchArr[section];
    NSString *title = dic.allKeys.lastObject;
    // 返回的整个视图
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 32)];
    bgView.backgroundColor = [UIColor whiteColor];
    // 字母文字
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, bgView.bounds.size.width - 32, 20)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor colorWithRed:153.0 / 255 green:153.0 / 255 blue:153.0 / 255 alpha:1.0];
    titleLabel.font = font(14);
    titleLabel.text = title;
    [bgView addSubview:titleLabel];
    
    return bgView;
}
// section的footer视图的高度和内容
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 0)];
}

// 每一行显示的高度和内容
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell"];
    // 防止下标越界
    if (self.searchArr.count <= indexPath.section) {
        return cell;
    }
    NSDictionary *dic = self.searchArr[indexPath.section];
    NSArray *arr = dic.allValues.lastObject;
    if (arr.count <= indexPath.row) {
        return cell;
    }
    // 文字
    if ([cell.contentView viewWithTag:200] == nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, SCREEN_WIDTH - 20 - 32, 20)];
        label.textColor = Color_Title;
        label.font = font(14);
        label.textAlignment = NSTextAlignmentLeft;
        label.tag = 200;
        [cell.contentView addSubview:label];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 43.5, SCREEN_WIDTH - 20 - 32, 0.5)];
        line.backgroundColor = Color_Separator;
        [cell.contentView addSubview:line];
    }
    UILabel *label = [cell.contentView viewWithTag:200];
    NSDictionary *cityDic = arr[indexPath.row];
    label.text = cityDic[@"name"];
    
    return cell;
}
// 点击行要做的事
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.searchArr.count > indexPath.section) {
        // 获取城市数据
        NSDictionary *dic = self.searchArr[indexPath.section];
        NSArray *arr = dic.allValues.lastObject;
        // 防止下标越界
        if (arr.count > indexPath.row) {
            NSDictionary *cityDic = arr[indexPath.row];
            if (self.didSelectedCity) {
                self.didSelectedCity(cityDic[@"name"]);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


#pragma mark - 初始化顶部视图
- (void)initHeadView {
    // 搜索框
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, 60)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.shadowColor = Color_Shadow.CGColor;
    bgView.layer.shadowOffset = CGSizeMake(0,6);
    bgView.layer.shadowOpacity = 1;
    bgView.layer.shadowRadius = 14;
    [self.view addSubview:bgView];
    
    _searchView = [[HYSearchView alloc] initWithFrame:CGRectMake(10, 12, SCREEN_WIDTH - 20, 36)];
    _searchView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入搜索城市中文名或拼音" attributes:@{NSFontAttributeName: font(14), NSForegroundColorAttributeName: Color_Placeholder}];
    _searchView.textColor = Color_Title;
    _searchView.font = font(14);
    _searchView.backgroundColor = Color_Separator;
    _searchView.layer.cornerRadius = 18;
    _searchView.layer.masksToBounds = YES;
    _searchView.delegate = self;
    [bgView addSubview:_searchView];
    
    // 当前定位按钮
    _curCityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _curCityBtn.frame = CGRectMake(10, bgView.frame.origin.y + bgView.frame.size.height + 10, SCREEN_WIDTH - 20, 44);
    [_curCityBtn setTitle:[NSString stringWithFormat:@"当前定位城市：%@", _curCity] forState:UIControlStateNormal];
    [_curCityBtn setTitleColor:Color_Title forState:UIControlStateNormal];
    [_curCityBtn setBackgroundColor: [UIColor whiteColor]];
    _curCityBtn.layer.cornerRadius = 4;
    _curCityBtn.layer.masksToBounds = YES;
    _curCityBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_curCityBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    _curCityBtn.titleLabel.font = font(14);
    [self.view addSubview:_curCityBtn];
}

#pragma mark - 懒加载
- (NSArray *)dataArr {
    if (!_dataArr) {
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city" ofType:@"txt"]];
        _dataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    }
    return _dataArr;
}

@end
