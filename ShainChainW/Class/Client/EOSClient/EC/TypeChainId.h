//
//  TypeChainId.h
//  TronWallet
//
//  Created by 闪链 on 2019/3/30.
//  Copyright © 2019 onesmile. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TypeChainId : NSObject
- (const void *)getBytes ;
- (const NSData *)chainId;
@end

NS_ASSUME_NONNULL_END
