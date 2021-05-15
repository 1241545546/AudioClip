//
//  TranferConfig.h
//  AudioClip
//
//  Created by FeeBaishi on 2021/5/14.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

enum DepthBit{
    DepthBit_8  = 8,
    DepthBit_16 = 16,
    DepthBit_24 = 24,
    DepthBit_32 = 32
};

typedef NS_ENUM(NSUInteger, FileType_Want) {
    MP3  = 0,
    aiff,
    aac,
    wav,
    m4a,
    caf
};

@interface TranferConfig : NSObject

@property (nonatomic, assign) int des_sampleRate; // 每秒采样率
@property (nonatomic, assign) int des_channels; //声道
@property (nonatomic, assign) enum DepthBit des_depth; //存储位采样深度
@property (nonatomic, assign) AudioFormatID  des_formatid; //原始编码类型
@property (nonatomic, assign) AudioFileTypeID des_filetype; //输出编码类型

/// 获取配置参数
/// @param channel 通道 默认 2
/// @param samplerate  采样率 默认 44100
+(TranferConfig*)getConfig:(int)channel sampleRate:(int)samplerate fileType:(FileType_Want)type;


@end

NS_ASSUME_NONNULL_END
