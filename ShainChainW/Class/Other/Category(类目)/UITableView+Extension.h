//
//  UITableView+Extension.h
//  CopyLeXiang
//
//  Created by 林衍杰 on 2017/9/28.
//  Copyright © 2017年 林衍杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Extension)
- (void)tableViewDisplayWithShoppingCart:(UIImage *)img imgFrame:(CGRect)frame ifNecessaryForRowCount:(NSUInteger)rowCount tipString:(NSString *)tipstr message:(NSString *)message onClickEvent:(void (^)(id obj))onClickEvent;

- (void)tableViewDisplayWithShoppingCart:(UIImage *)img ifNecessaryForRowCount:(NSUInteger)rowCount tipString:(NSString *)tipstr message:(NSString *)message onClickEvent:(void (^)(id obj))onClickEvent;

- (void)tableViewDisplayWithShoppingCart:(UIImage *)img ifNecessaryForRowCount:(NSUInteger)rowCount sectionHeight:(CGFloat)height onClickEvent:(void (^)(id obj))onClickEvent;

- (void)loading;
- (void)hideLoading;
@end
