//
//  SCMyIDController.m
//  SCWallet
//
//  Created by 闪链 on 2019/1/15.
//  Copyright © 2019 zaker_sink. All rights reserved.
//

#import "SCMyIDController.h"
#import "SCMyIDCell.h"
#import "SCWalletTipView.h"
#import "SCEnterController.h"
#import "BackupsController.h"
#import "WalletNavViewController.h"
#import "SCSubscribeEmailView.h"
#import "SCRootTool.h"
#import "SCWalletEnterView.h"
#import "AESCrypt.h"
#import "BackupPriKeyController.h"
#import "SCExpPriKController.h"

@interface SCMyIDController ()
<UITableViewDelegate,UITableViewDataSource>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) NSArray *textArray;

@property(strong, nonatomic) UIImageView *headImg;//头像
@property(strong, nonatomic) UILabel *nameLab;//
@property(strong, nonatomic) UILabel *nameID;//
@property(strong, nonatomic) UILabel *takeEmailLab;//订阅邮箱

@property(strong, nonatomic) UIView *operationView;//

@property(strong, nonatomic) walletModel *wallet;//
@end

@implementation SCMyIDController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalizedString(@"我的身份");
    
    self.wallet = [UserinfoModel shareManage].wallet;
//    获取系统钱包
    NSArray *walletArr= [walletModel bg_find:nil where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",[NSObject bg_sqlKey:@"ID"],[NSObject bg_sqlValue:@(0)],[NSObject bg_sqlKey:@"isSystem"],[NSObject bg_sqlValue:@(1)]]];
    self.wallet = [walletArr lastObject];
    
    _textArray = @[LocalizedString(@"头像"),LocalizedString(@"身份名"),LocalizedString(@"身份ID")];
    [self.view addSubview:self.tableView];
    
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCMyIDCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SCMyIDCell"];
    if (!cell) {
        cell = [[SCMyIDCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SCMyIDCell"];
    }
    if (indexPath.section == 0) {
        cell.str = self.textArray[indexPath.row];
        if (indexPath.row==0) {
            //头像
            [cell addSubview:self.headImg];
        }
        if (indexPath.row==1) {
            [cell addSubview:self.nameLab];
        }
        if (indexPath.row==2) {
            [cell addSubview:self.nameID];
        }
    }
    if (indexPath.section == 1) {
        cell.str = LocalizedString(@"邮箱");
        [cell addSubview:self.takeEmailLab];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return HEIGHT;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return _textArray.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        SCSubscribeEmailView *emailv = [SCSubscribeEmailView new];
        emailv.showBgView = YES;
        [KeyWindow addSubview:emailv];
    }
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = 0;
        _tableView.bounces = NO;
        _tableView.backgroundColor = SCGray(242);
        _tableView.tableFooterView = self.operationView;
    }
    return _tableView;
}

#pragma mark - 退出当前身份  备份身份
- (void)backupID
{
    walletModel *wallet = [UserinfoModel shareManage].wallet;
    WeakSelf(weakSelf);
    SCWalletEnterView *se = [SCWalletEnterView shareInstance];
    se.title = LocalizedString(@"请输入密码");
    se.placeholderStr = @"密码";
    se.isOperation = NO;
    [se setReturnTextBlock:^(NSString *showText) {
        if ([wallet.ID isEqualToNumber:@(0)]||[wallet.ID isEqualToNumber:@(60)]) {
            BackupsController *sc = [BackupsController new];
            sc.password = showText;
            [weakSelf.navigationController pushViewController:sc animated:YES];

        }
        else
        {
            NSString *privateKey = [AESCrypt decrypt:wallet.privateKey password:showText];
            SCExpPriKController *priKvc = [SCExpPriKController new];
            priKvc.prikey = privateKey;
            [self.navigationController pushViewController:priKvc animated:YES];
        }
    }];
  
//    BackupPriKeyController *sc = [BackupPriKeyController new];
//    sc.isBackup = YES;
//    WalletNavViewController *navi = [[WalletNavViewController alloc]initWithRootViewController:sc];
//    [weakSelf presentViewController:navi animated:YES completion:nil];
}

- (void)exitID
{
    SCWalletTipView *st = [SCWalletTipView shareInstance];
    st.title = @"退出当前身份";
    st.detailStr = @"即将移除身份及所有已导入的钱包，请确保所有钱包已备份。";
    [st setReturnBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SCWalletEnterView *se = [SCWalletEnterView shareInstance];
            se.title = LocalizedString(@"请输入密码");
            se.placeholderStr = LocalizedString(@"密码");
            se.callBack = YES;
            [se setReturnTextBlock:^(NSString *showText) {
                [SVProgressHUD showWithStatus:LocalizedString(@"正在退出身份...")];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (!IsStrEmpty([AESCrypt decrypt:self.wallet.password password:showText])) {
                        [(AppDelegate *)[[UIApplication sharedApplication] delegate] reset];
                    }
                    else{
                        [SVProgressHUD dismiss];
                        [TKCommonTools showToast:LocalizedString(@"密码错误")];
                    }
                });
            }];
        });
    }];
}

#pragma mark - lazyload
- (UIImageView *)headImg
{
    if (!_headImg) {
        UIImageView *img = [UIImageView new];
        img.size = CGSizeMake(40, 40);
        img.layer.cornerRadius = img.width/2;
        img.clipsToBounds = YES;
        img.right = SCREEN_WIDTH-15;
        img.centerY = HEIGHT/2;
        img.image= IMAGENAME(@"2.4浏览Candy-Bar");
        _headImg = img;
    }
    return _headImg;
}

- (UILabel *)nameLab
{
    if (!_nameLab) {
        _nameLab = [UILabel new];
        _nameLab.size = CGSizeMake(120, HEIGHT);
        _nameLab.right = SCREEN_WIDTH-15;
        _nameLab.font = kFont(15);
        _nameLab.textColor = SCGray(128);
        _nameLab.textAlignment = NSTextAlignmentRight;
        _nameLab.text = self.wallet.idname?self.wallet.idname:@"id_name";
    }
    return _nameLab;
}

- (UILabel *)nameID
{
    if (!_nameID) {
        _nameID = [UILabel new];
        _nameID.size = CGSizeMake(120, HEIGHT);
        _nameID.right = SCREEN_WIDTH-15;
        _nameID.font = kFont(15);
        _nameID.textColor = SCGray(128);
        _nameID.textAlignment = NSTextAlignmentRight;
        _nameID.numberOfLines = 2;
        _nameID.text = [self.wallet.idname?self.wallet.idname:@"id_name" base64EncodedString];
    }
    return _nameID;
}

- (UILabel *)takeEmailLab
{
    if (!_takeEmailLab) {
        _takeEmailLab = [UILabel new];
        _takeEmailLab.size = CGSizeMake(120, HEIGHT);
        _takeEmailLab.right = SCREEN_WIDTH-15;
        _takeEmailLab.font = kFont(15);
        _takeEmailLab.textColor = SCGray(128);
        _takeEmailLab.textAlignment = NSTextAlignmentRight;
        _takeEmailLab.numberOfLines = 2;
        _takeEmailLab.text = LocalizedString(@"未订阅");
        _takeEmailLab.textColor = MainColor;
    }
    return _takeEmailLab;
}

- (UIView *)operationView
{
    if (!_operationView) {
        _operationView = [UIView new];
        _operationView.size = CGSizeMake(SCREEN_WIDTH, 96+10);
        _operationView.backgroundColor = [UIColor clearColor];
        
        UILabel *lab1 = [UILabel new];
        lab1.size = CGSizeMake(SCREEN_WIDTH, 48);
        lab1.x = 0;
        lab1.y = 10;
        lab1.text = LocalizedString(@"备份身份");
        lab1.textColor = SCColor(252, 102, 50);
        lab1.textAlignment = NSTextAlignmentCenter;
        lab1.font = kFont(15);
        lab1.backgroundColor = [UIColor whiteColor];
        [_operationView addSubview:lab1];
        
        UILabel *lab2 = [UILabel new];
        lab2.size = CGSizeMake(SCREEN_WIDTH, 48);
        lab2.x = 0;
        lab2.y = lab1.bottom;
        lab2.text = LocalizedString(@"退出当前身份");
        lab2.textColor = SCColor(252, 174, 50);
        lab2.textAlignment = NSTextAlignmentCenter;
        lab2.font = kFont(15);
        lab2.backgroundColor = [UIColor whiteColor];
        [_operationView addSubview:lab2];
        
        UIView *line = [RewardHelper addLine2];
        line.centerY = _operationView.height/2+5;
        [_operationView addSubview:line];
        
        WeakSelf(weakSelf);
        [lab1 setTapActionWithBlock:^{
           //备份身份
            [weakSelf backupID];
        }];
        [lab2 setTapActionWithBlock:^{
            //退出当前身份
            [weakSelf exitID];
        }];
    }
    return _operationView;
}

@end
