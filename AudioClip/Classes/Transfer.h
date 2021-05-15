//
//  Transfer.h
//  AudioClip
//
//  Created by FeeBaishi on 2021/5/14.
//

#import <Foundation/Foundation.h>

#import "TranferUtil.h"

#import "TranferConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface Transfer : NSObject

/// 转换调用方法
/// @param s_path 需要转换的文件路径(文件只需要 Document/)
/// @param des_path 目标地址(Doument/)
/// @param config 转换配置
/// @param porgress 进度回调
/// @param complete 完成回调
+ (void)start:(NSString*)s_path with:(NSString*)des_path config:(TranferConfig*)config complete:(void(^)(BOOL state,NSError* error))complete;

@end

NS_ASSUME_NONNULL_END
