//
//  Transfer.m
//  AudioClip
//
//  Created by FeeBaishi on 2021/5/14.
//

#import "Transfer.h"

@implementation Transfer

+ (void)start:(NSString*)s_path with:(NSString*)des_path config:(TranferConfig*)config complete:(void(^)(BOOL state,NSError* error))complete{
    
    NSError* error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:nil];
    
    AudioTranforSettings settings = {0};
    
    //Check if source file or output file is null
    if (!s_path || s_path.length <= 0) {
        NSLog(@"Source file is not exit");
        complete(NO,error);
    }
    
    if (!des_path || des_path.length <= 0) {
        NSLog(@"Output file is no exit");
        complete(NO,error);
    }
    
    //Create ExtAudioFileRef
    NSURL* sourceURL = [NSURL fileURLWithPath:s_path];
    CheckError(ExtAudioFileOpenURL((__bridge CFURLRef)sourceURL,
                                   &settings.s_file),
               "ExtAudioFileOpenURL failed");
    
    [self valieSeting:config];
    
    settings.des_format.mSampleRate       = config.des_sampleRate;
    settings.des_format.mBitsPerChannel   = config.des_depth;
    if (config.des_formatid==kAudioFormatMPEG4AAC) {
        settings.des_format.mBitsPerChannel = 0;
    }
    settings.des_format.mChannelsPerFrame = config.des_channels;
    settings.des_format.mFormatID         = config.des_formatid;
    
    if (config.des_formatid==kAudioFormatLinearPCM) {
        settings.des_format.mBytesPerFrame   = settings.des_format.mChannelsPerFrame * settings.des_format.mBitsPerChannel/8;
        settings.des_format.mBytesPerPacket  = settings.des_format.mBytesPerFrame;
        settings.des_format.mFramesPerPacket = 1;
        settings.des_format.mFormatFlags     = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        //some file type only support big-endian
        if (config.des_filetype == kAudioFileAIFFType || config.des_filetype == kAudioFileSoundDesigner2Type || config.des_filetype == kAudioFileAIFCType || config.des_filetype == kAudioFileNextType) {
            settings.des_format.mFormatFlags |= kAudioFormatFlagIsBigEndian;
        }
    }else{
        UInt32 size = sizeof(settings.des_format);
        CheckError(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                          0,
                                          NULL,
                                          &size,
                                          &settings.des_format),
                   "AudioFormatGetProperty kAudioFormatProperty_FormatInfo failed");
    }
    
    //Create output file
    //if output file path is invalid, this returns an error with 'wht?'
    NSURL* outputURL = [NSURL fileURLWithPath:des_path];
    
    //create output file
    settings.des_filepath = (__bridge CFStringRef)(outputURL.absoluteString);
    if (settings.des_format.mFormatID!=kAudioFormatMPEGLayer3) {
        CheckError(ExtAudioFileCreateWithURL((__bridge CFURLRef)outputURL,
                                             config.des_filetype,
                                             &settings.des_format,
                                             NULL,
                                             kAudioFileFlags_EraseFile,
                                             &settings.des_file),
                   "Create output file failed, the output file type and output format pair may not match");
    }
    
    //Set input file's client data format
    //Must be PCM, thus as we say, "when you convert data, I want to receive PCM format"
    if (settings.des_format.mFormatID==kAudioFormatLinearPCM) {
        settings.s_formatid = settings.des_format;
    }else{
        settings.s_formatid.mFormatID = kAudioFormatLinearPCM;
        settings.s_formatid.mSampleRate = settings.des_format.mSampleRate;
        //TODO:set format flags for both OS X and iOS, for all versions
        settings.s_formatid.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
        //TODO:check if size of SInt16 is always suitable
        settings.s_formatid.mBitsPerChannel = 8 * sizeof(SInt16);
        settings.s_formatid.mChannelsPerFrame = settings.des_format.mChannelsPerFrame;
        //TODO:check if this is suitable for both interleaved/noninterleaved
        settings.s_formatid.mBytesPerPacket = settings.s_formatid.mBytesPerFrame = settings.s_formatid.mChannelsPerFrame*sizeof(SInt16);
        settings.s_formatid.mFramesPerPacket = 1;
    }
    
    CheckError(ExtAudioFileSetProperty(settings.s_file,
                                       kExtAudioFileProperty_ClientDataFormat,
                                       sizeof(settings.s_formatid),
                                       &settings.s_formatid),
               "Setting client data format of input file failed");
    
    //If the file has a client data format, then the audio data in ioData is translated from the client format to the file data format, via theExtAudioFile's internal AudioConverter.
    if (settings.des_format.mFormatID!=kAudioFormatMPEGLayer3) {
        CheckError(ExtAudioFileSetProperty(settings.des_file,
                                           kExtAudioFileProperty_ClientDataFormat,
                                           sizeof(settings.s_formatid),
                                           &settings.s_formatid),
                   "Setting client data format of output file failed");
    }
    
    
    printf("Start converting...\n");
    if (settings.des_format.mFormatID==kAudioFormatMPEGLayer3) {
        startMP3(&settings);
    } else {
        startTrans(&settings);
    }
    
    
    ExtAudioFileDispose(settings.s_file);
    //AudioFileClose/ExtAudioFileDispose function is needed, or else for .wav output file the duration will be 0
    ExtAudioFileDispose(settings.des_file);
    complete(YES,nil);
    
}

//The file format and data format match documentatin is at: https://developer.apple.com/library/ios/documentation/MusicAudio/Conceptual/CoreAudioOverview/SupportedAudioFormatsMacOSX/SupportedAudioFormatsMacOSX.html
//Check if the input combination is valid
+(void)valieSeting:(TranferConfig*)config{
    //原始数据 pcm(硬件的原始采样数据) -> 编码(eg: MPEGLayer 3) -> 包装格式(eg: kAudioFileMP3Type)(也就是选择存储的文件类型) -> 具体的后缀文件(eg: xxx.mp3)
    BOOL state = YES;
    switch (config.des_filetype) {
        case kAudioFileWAVEType:{
            //for wave file format
            //WAVE file type only support PCM, alaw and ulaw
            state = config.des_formatid==kAudioFormatLinearPCM || config.des_formatid==kAudioFormatALaw || config.des_formatid==kAudioFormatULaw;
            break;
        }
        case kAudioFileSoundDesigner2Type:{
            state = config.des_formatid==kAudioFormatLinearPCM;
            break;
        }
        case kAudioFileAAC_ADTSType:{
            //aac only support aac data format
            state = config.des_formatid==kAudioFormatMPEG4AAC;
            break;
        }
        case kAudioFileAIFFType:{
            //AIFF only support PCM format
            state = config.des_formatid==kAudioFormatLinearPCM;
            break;
        }
        case kAudioFileAC3Type:{
            //convert from PCM to ac3 format is not supported
            state = NO;
            break;
        }
        case kAudioFileAIFCType:{
            //TODO:kAudioFileAIFCType together with kAudioFormatMACE3/kAudioFormatMACE6/kAudioFormatQDesign2/kAudioFormatQUALCOMM pair failed
            //Since MACE3:1/MACE6:1 is obsolete, they're not supported yet
            state = config.des_formatid==kAudioFormatLinearPCM || config.des_formatid==kAudioFormatULaw || config.des_formatid==kAudioFormatALaw || config.des_formatid==kAudioFormatAppleIMA4 || config.des_formatid==kAudioFormatQDesign2 || config.des_formatid==kAudioFormatQUALCOMM;
            break;
        }
        case kAudioFileCAFType:{
            //caf file type support almost all data format
            //TODO:not all foramt are supported, check them out
            state = YES;
            break;
        }
        case kAudioFileMP3Type:{
            //TODO:support mp3 type
            state = config.des_formatid==kAudioFormatMPEGLayer3;
            break;
        }
        case kAudioFileMPEG4Type:{
            state = config.des_formatid==kAudioFormatMPEG4AAC;
            break;
        }
        case kAudioFileM4AType:{
            state = config.des_formatid==kAudioFormatMPEG4AAC || config.des_formatid==kAudioFormatAppleLossless;
            break;
        }
        case kAudioFileNextType:{
            state = config.des_formatid==kAudioFormatLinearPCM || config.des_formatid==kAudioFormatULaw;
            break;
        }
        default:
            break;
    }
    
    if (!state) {
        NSLog(@"音频编码校验失败 -- error info : 要求输出文件类型与输入编码格式不匹配");
        exit(0);
    }

}

@end
