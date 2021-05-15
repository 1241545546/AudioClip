//
//  TranferUtil.m
//  AudioClip
//
//  Created by FeeBaishi on 2021/5/14.
//

#import "TranferUtil.h"

@implementation TranferUtil

void startMP3(AudioTranforSettings* settings){
    //Init lame and set parameters
    lame_t lame = lame_init();
    lame_set_in_samplerate(lame, settings->s_formatid.mSampleRate);
    lame_set_num_channels(lame, settings->s_formatid.mChannelsPerFrame);
    lame_set_VBR(lame, vbr_default);
    lame_init_params(lame);
    
    NSString* des_filepath = (__bridge NSString*)settings->des_filepath;
    FILE* des_file = fopen([des_filepath cStringUsingEncoding:1], "wb");
    
    UInt32 sizePerBuffer = 32*1024;
    UInt32 framesPerBuffer = sizePerBuffer/sizeof(SInt16);
    
    int write;
    
    // allocate destination buffer
    SInt16 *outputBuffer = (SInt16 *)malloc(sizeof(SInt16) * sizePerBuffer);
    
    while (1) {
        AudioBufferList outputBufferList;
        outputBufferList.mNumberBuffers              = 1;
        outputBufferList.mBuffers[0].mNumberChannels = settings->des_format.mChannelsPerFrame;
        outputBufferList.mBuffers[0].mDataByteSize   = sizePerBuffer;
        outputBufferList.mBuffers[0].mData           = outputBuffer;
        
        UInt32 framesCount = framesPerBuffer;
        
        CheckError(ExtAudioFileRead(settings->s_file,
                                    &framesCount,
                                    &outputBufferList),
                   "ExtAudioFileRead failed");
        
        SInt16 pcm_buffer[framesCount];
        unsigned char mp3_buffer[framesCount];
        memcpy(pcm_buffer,
               outputBufferList.mBuffers[0].mData,
               framesCount);
        if (framesCount==0) {
            printf("Done reading from input file\n");
            //TODO:Add lame_encode_flush for end of file
            return;
        }
        
        //the 3rd parameter means number of samples per channel, not number of sample in pcm_buffer
        write = lame_encode_buffer_interleaved(lame,
                                               outputBufferList.mBuffers[0].mData,
                                               framesCount,
                                               mp3_buffer,
                                               0);
        fwrite(mp3_buffer,
                               1,
                               write,
                               des_file);
    }
    fclose(des_file);
}

void startTrans(AudioTranforSettings* settings){
    //Determine the proper buffer size and calculate number of packets per buffer
    //for CBR and VBR format
    UInt32 sizePerBuffer = 32*1024;//32KB is a good starting point
    UInt32 framesPerBuffer = sizePerBuffer/sizeof(SInt16);
    
    // allocate destination buffer
    SInt16 *outputBuffer = (SInt16 *)malloc(sizeof(SInt16) * sizePerBuffer);
    UInt32 readcount = 0;
    while (1) {
        AudioBufferList outputBufferList;
        outputBufferList.mNumberBuffers              = 1;
        outputBufferList.mBuffers[0].mNumberChannels = settings->des_format.mChannelsPerFrame;
        outputBufferList.mBuffers[0].mDataByteSize   = sizePerBuffer;
        outputBufferList.mBuffers[0].mData           = outputBuffer;
        
        UInt32 framesCount = framesPerBuffer;
        
        CheckError(ExtAudioFileRead(settings->s_file,
                                    &framesCount,
                                    &outputBufferList),
                   "ExtAudioFileRead failed");
        if (framesCount==0) {
            printf("Done reading from input file\n");
            return;
        }
//        ExtAudioFileWriteAsync(settings->des_file, framesCount, &outputBufferList);
        CheckError(ExtAudioFileWrite(settings->des_file,
                                     framesCount,
                                     &outputBufferList),
                   "ExtAudioFileWrite failed");
    }
}

@end
