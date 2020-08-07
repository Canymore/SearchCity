//
//  ViewController.m
//  SearchCity
//
//  Created by 曹海洋 on 2020/8/6.
//  Copyright © 2020 . All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 原始数据转化成只有名称的json数据
//    [self ct1ToCt2];
    
    // 将json格式的城市名称加上拼音
//    [self ct2ToCt3];
    
    // 按拼音首字母分组
//    [self ct3ToCt4];
    
    // 按拼音排序
//    [self ct4ToCt5];
    
    // 把拼音按字分割开
    [self ct5ToCt6];
}

// 按字把拼音分割开
- (void)ct5ToCt6 {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city5" ofType:@"txt"];
    NSLog(@"filePath-----> %@", filePath);
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSArray<NSDictionary *> *dicArr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    // 遍历每个字母开头
    NSMutableArray *mutArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in dicArr) {
        NSMutableArray *valueArr = [[NSMutableArray alloc] init];
        for (NSDictionary *cityDic in dic.allValues.lastObject) {
            
            NSMutableDictionary *valueDic = [[NSMutableDictionary alloc] init];
            valueDic[@"name"] = [cityDic[@"name"] copy];
            
            NSMutableString *pinyinText = [[NSMutableString alloc] initWithString:valueDic[@"name"]];
            // 转换后拼音带声调
            if (CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformMandarinLatin, NO)) {
                // 转换后拼音不带声调
                if (CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformStripDiacritics, NO)) {
//                    [pinyinText replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, pinyinText.length)];
                    valueDic[@"pinyin"] = pinyinText;
                }
                else {
                    NSLog(@"转换失败的城市：%@", cityDic[@"name"]);
                }
            }
            else {
                NSLog(@"转换失败的城市：%@", cityDic[@"name"]);
            }
            
            [valueArr addObject:valueDic];
        }
        
        [mutArr addObject:@{dic.allKeys.firstObject: valueArr}];
    }
    
    NSString *home = NSHomeDirectory();
    NSLog(@"home---> %@", home);
    NSString *writePath = [NSString stringWithFormat:@"%@/city6.txt", home];
    
    
    NSData *writeData = [NSJSONSerialization dataWithJSONObject:mutArr options:NSJSONWritingPrettyPrinted error:nil];
    [writeData writeToFile:writePath atomically:YES];
}

// 按拼音排序
- (void)ct4ToCt5 {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city4" ofType:@"txt"];
    NSLog(@"filePath-----> %@", filePath);
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSArray<NSDictionary *> *dicArr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *sortArr = [dicArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary<NSString *, id> *dic1 = (NSDictionary *)obj1;
        NSDictionary<NSString *, id> *dic2 = (NSDictionary *)obj2;
        
        return [dic1.allKeys.firstObject compare:dic2.allKeys.firstObject];
    }];
    
    NSMutableArray *mutArr = [[NSMutableArray alloc] initWithArray:sortArr];
    for (int i = 0; i < mutArr.count; i++)
    {
        NSDictionary *dic = mutArr[i];
        NSMutableDictionary *mutDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
        NSArray *arr = mutDic.allValues.firstObject;
        NSArray *sortArr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSDictionary<NSString *, id> *dic1 = (NSDictionary *)obj1;
            NSDictionary<NSString *, id> *dic2 = (NSDictionary *)obj2;
            
            return [dic1[@"pinyin"] compare:dic2[@"pinyin"]];
        }];
        
        mutDic[mutDic.allKeys.firstObject] = sortArr;
        mutArr[i] = mutDic;
    }
    
    NSString *home = NSHomeDirectory();
    NSLog(@"home---> %@", home);
    NSString *writePath = [NSString stringWithFormat:@"%@/city5.txt", home];
    
    
    NSData *writeData = [NSJSONSerialization dataWithJSONObject:mutArr options:NSJSONWritingPrettyPrinted error:nil];
    [writeData writeToFile:writePath atomically:YES];
}

- (void)ct3ToCt4 {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city3" ofType:@"txt"];
    NSLog(@"filePath-----> %@", filePath);
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSArray<NSDictionary *> *dicArr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    NSMutableArray<NSMutableDictionary *> *resultArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dic in dicArr) {
        NSString *pinyin = dic[@"pinyin"];
        NSString *firstC = [pinyin substringToIndex:1];         // 首字母
        
        BOOL isHave = NO;
        int index = 0;
        for (int i = 0; i < resultArr.count; i++) {
            NSDictionary *dic = resultArr[i];
            if ([dic.allKeys.firstObject isEqualToString:firstC.uppercaseString]) {
                isHave = YES;
                index = i;
                break;
            }
        }
        if (isHave) {
            NSMutableDictionary *mutDic = resultArr[index];
            NSMutableArray *valueArr = mutDic[firstC.uppercaseString];
            [valueArr addObject:dic];
        }
        else {
            NSMutableArray *valueArr = [[NSMutableArray alloc] init];
            [valueArr addObject:dic];
            NSMutableDictionary *mutDic = [[NSMutableDictionary alloc] init];
            mutDic[firstC.uppercaseString] = valueArr;
            
            [resultArr addObject:mutDic];
        }
    }
    
    NSString *home = NSHomeDirectory();
    NSLog(@"home---> %@", home);
    NSString *writePath = [NSString stringWithFormat:@"%@/city4.txt", home];
    
    
    NSData *writeData = [NSJSONSerialization dataWithJSONObject:resultArr options:NSJSONWritingPrettyPrinted error:nil];
    [writeData writeToFile:writePath atomically:YES];
    
}

- (void)ct2ToCt3 {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city2" ofType:@"txt"];
    NSLog(@"filePath-----> %@", filePath);
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSArray<NSString *> *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    NSMutableArray<NSDictionary *> *dicArr = [[NSMutableArray alloc] initWithCapacity:arr.count];
    for (NSString *name in arr)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        dic[@"name"] = [name copy];
        
        NSMutableString *pinyinText = [[NSMutableString alloc] initWithString:name];
        // 转换后拼音带声调
        if (CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformMandarinLatin, NO)) {
            // 转换后拼音不带声调
            if (CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformStripDiacritics, NO)) {
                [pinyinText replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, pinyinText.length)];
                dic[@"pinyin"] = pinyinText;
            }
            else {
                NSLog(@"转换失败的城市：%@", name);
            }
        }
        else {
            NSLog(@"转换失败的城市：%@", name);
        }
        
        [dicArr addObject:dic];
    }
    
    NSString *home = NSHomeDirectory();
    NSLog(@"home---> %@", home);
    NSString *writePath = [NSString stringWithFormat:@"%@/city3.txt", home];
    
    
    NSData *writeData = [NSJSONSerialization dataWithJSONObject:dicArr options:NSJSONWritingPrettyPrinted error:nil];
    [writeData writeToFile:writePath atomically:YES];
}

- (void)ct1ToCt2 {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"city1" ofType:@"txt"];
    NSLog(@"filePath-----> %@", filePath);
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    NSMutableArray *nameArr = [[NSMutableArray alloc] initWithCapacity:arr.count];
    for (NSDictionary *dic in arr) {
        [nameArr addObject:dic[@"name"]];
    }
    NSString *home = NSHomeDirectory();
    NSLog(@"home---> %@", home);
    NSString *writePath = [NSString stringWithFormat:@"%@/city2.txt", home];
    
    
    NSData *writeData = [NSJSONSerialization dataWithJSONObject:nameArr options:NSJSONWritingPrettyPrinted error:nil];
    [writeData writeToFile:writePath atomically:YES];
    
    // 项目目录中的city2中手动添加了香港，澳门，以及台湾省内包含的一些市
}


@end
