//
//  TWNetworkManager.m
//  FunApp
//
//  Created by chunhui on 16/6/1.
//  Copyright © 2016年 chunhui. All rights reserved.
//

#import "TWNetworkManager.h"
#import "TKRequestHandler.h"
#import "TKAppInfo.h"
#import "UIDevice+Hardware.h"
#import "Reachability.h"
#import "TKNetworkManager.h"


NSString * const KEY_USERNAME_PASSWORD = @"com.company.app.usernamepassword";
NSString * const KEY_PASSWORD = @"com.company.app.password";

#define kNodeIpKey @"__node_ip__"
#define kNodePortKey @"__node_port__"

#define kDefaultIp @"47.75.249.119"
#define kDefaultPort @"50051"

@interface TWNetworkManager()<TKRequestHandlerDelegate>

@property(nonatomic , strong) NSMutableDictionary *extraInfo;
@property(nonatomic , strong) NSString *cuid;


@property(nonatomic , copy)  NSString *nodeIp;
@property(nonatomic , copy)  NSString *nodePort;

@end


@implementation TWNetworkManager

IMP_SINGLETON

-(instancetype)init
{
    self = [super init];
    if (self) {
        _extraInfo = [[NSMutableDictionary alloc]init];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.nodeIp = [defaults objectForKey:kNodeIpKey];
        self.nodePort = [defaults objectForKey:kNodePortKey];
        
        if (self.nodeIp.length == 0) {
            self.nodeIp = kDefaultIp;
            [defaults setObject:self.nodeIp forKey:kNodeIpKey];
        }
        if (self.nodePort.length == 0) {
            self.nodePort = kDefaultPort;
            [defaults setObject:self.nodePort forKey:kNodePortKey];
        }
        
        [defaults synchronize];
        NSString *address = [NSString stringWithFormat:@"%@:%@",_nodeIp,_nodePort];
   
    }
    return self;
}

+(NSString *)appHost
{
    TWNetworkManager *manager = [TWNetworkManager sharedInstance];
    return [NSString stringWithFormat:@"%@:%@",manager.nodeIp,manager.nodePort];
}

-(void)resetIp:(NSString *)ip andPort:(NSString *)port
{
    self.nodeIp = ip;
    self.nodePort = port;
    
    NSString *address = [NSString stringWithFormat:@"%@:%@",ip,port];
 
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.nodeIp forKey:kNodeIpKey];
    [defaults setObject:self.nodePort forKey:kNodePortKey];
    [defaults synchronize];
 
}

-(void)resetToDefault
{
    [self resetIp:kDefaultIp andPort:kDefaultPort];
}

-(NSString *)ip
{
    return _nodeIp;
}

-(NSString *)port
{
    return _nodePort;
}


#pragma mark - login
-(void)loginDoneNotification:(NSNotification *)notification
{
   // TKUserInfo *userinfo = [[TKAccountManager sharedInstance]userInfo];
   // TKRequestHandler *handler = [TKRequestHandler sharedInstance];
   // [handler setValue:[NSString stringWithFormat:@"%@ %@",userinfo.tokenType,userinfo.accessToken] forHTTPHeaderField:@"Authorization"];
}

-(void)logoutNotification:(NSNotification *)notification
{
    TKRequestHandler *handler = [TKRequestHandler sharedInstance];
    [handler setAuthorizationHeaderFieldWithUsername:@"ecclient" password:@"ecclientsecret"];
}





@end
