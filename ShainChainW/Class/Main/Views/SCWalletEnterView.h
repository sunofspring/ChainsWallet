//
//  SCWalletEnterView.h
//  SCWallet
//
//  Created by 林衍杰 on 2019/1/8.
//  Copyright © 2019年 zaker_sink. All rights reserved.
//  带输入的提示框

#import <UIKit/UIKit.h>
typedef void (^ReturnTextBlock)(NSString *showText);
typedef void (^CancleBlock)();


@interface SCWalletEnterView : UIView
+ (instancetype)shareInstance;
@property(assign ,nonatomic) BOOL isOperation; //默认yes
@property(assign ,nonatomic) BOOL callBack; //直接返回
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *placeholderStr;
@property (strong, nonatomic) UITextField *tf;
@property (nonatomic, copy) ReturnTextBlock returnTextBlock;
@property (nonatomic, copy) CancleBlock cancleBlock;
@end
 
