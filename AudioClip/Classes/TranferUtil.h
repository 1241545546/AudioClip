//
//  TranferUtil.h
//  AudioClip
//
//  Created by FeeBaishi on 2021/5/14.
//

#import <Foundation/Foundation.h>

#import "lame.h"

#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN


typedef struct AudioTranforSettings{
    AudioStreamBasicDescription   s_formatid;
    AudioStreamBasicDescription   des_format;
    
    ExtAudioFileRef               s_file;
    CFStringRef                   des_filepath;
    ExtAudioFileRef               des_file;
    
    AudioStreamPacketDescription* inputPacketDescriptions;
}AudioTranforSettings;

static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}

void startMP3(AudioTranforSettings* settings);

void startTrans(AudioTranforSettings* settings);

@interface TranferUtil : NSObject

@end

NS_ASSUME_NONNULL_END
