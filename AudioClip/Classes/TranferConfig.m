//
//  TranferConfig.m
//  AudioClip
//
//  Created by FeeBaishi on 2021/5/14.
//

#import "TranferConfig.h"

@implementation TranferConfig

+(TranferConfig*)getConfig:(int)channel sampleRate:(int)samplerate fileType:(FileType_Want)type{
    TranferConfig* config = [[TranferConfig alloc]init];
    config.des_sampleRate = samplerate <= 0 ? 44100:samplerate;
    config.des_channels = channel <= 0 ? 2:channel;
    config.des_depth = 16;
    [self fixType:config type:type];
    return config;
}

+(void)fixType:(TranferConfig*)config type:(FileType_Want)type{
    
    switch (type) {
        case MP3:
            config.des_formatid = kAudioFormatMPEGLayer3;
            config.des_filetype = kAudioFileMP3Type;
            break;
        case aiff:
            config.des_formatid = kAudioFormatLinearPCM;
            config.des_filetype = kAudioFileAIFFType;
            break;
        case wav:
            config.des_formatid = kAudioFormatLinearPCM;
            config.des_filetype = kAudioFileWAVEType;
            break;
        case aac:
            config.des_formatid = kAudioFormatMPEG4AAC;
            config.des_filetype = kAudioFileAAC_ADTSType;
            break;
        case m4a:
            config.des_formatid = kAudioFormatMPEG4AAC;
            config.des_filetype = kAudioFileM4AType;
            break;
        case caf:
            config.des_formatid = kAudioFormatMPEG4AAC;
            config.des_filetype = kAudioFileCAFType;
            break;
            
        default:
            break;
    }
    
}

@end
