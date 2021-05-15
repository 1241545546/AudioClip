//
//  SSViewController.m
//  AudioClip
//
//  Created by 1241545546@qq.com on 04/06/2021.
//  Copyright (c) 2021 1241545546@qq.com. All rights reserved.
//

#import "SSViewController.h"

#import "Transfer.h"

@interface SSViewController ()

@end

@implementation SSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [Transfer start:[NSBundle.mainBundle pathForResource:@"textsource" ofType:@"mp3"] with:[NSString stringWithFormat:@"%@/Documents/resultwav.wav",NSHomeDirectory()] config:[TranferConfig getConfig:0 sampleRate:0 fileType:(aac)] complete:^(BOOL state, NSError * _Nonnull error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
