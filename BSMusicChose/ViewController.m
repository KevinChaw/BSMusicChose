//
//  ViewController.m
//  BSMusicChose
//
//  Created by 邹志勇 on 15/5/26.
//  Copyright (c) 2015年 邹志勇. All rights reserved.
//

#import "ViewController.h"

#import "BSMusicPickViewController.h"

#import<AVFoundation/AVFoundation.h>

@interface ViewController ()<BSMusicPickDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)transcodemusic:(id)sender {
    

    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"绿袖子" ofType:@"mp3"];
    
    NSURL *urlMusic = [[NSURL alloc] initFileURLWithPath:musicPath];
    [self convertToMp3:urlMusic];
}

- (IBAction)addMusic:(id)sender {
    
    BSMusicPickViewController* musicPickViewController = [[BSMusicPickViewController alloc] initWithNibName:nil bundle:nil] ;
    musicPickViewController.delegate = self;
    
    UINavigationController* navigationViewController = [[UINavigationController alloc] initWithRootViewController:musicPickViewController];
                                                                                                              
    
    [self presentViewController:navigationViewController animated:YES completion:Nil];
    
}

#pragma BSMusicPickDelegate

-(void) choseMusic:(NSURL *) assetURL musicPick:(BSMusicPickViewController *) musicPick
{
    [self convertToMp3:assetURL];
}


- (void) convertToMp3: (NSURL *) songURL
{
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:songURL options:nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *filePath = NSTemporaryDirectory();

    filePath = [filePath stringByAppendingPathComponent:[songURL lastPathComponent]];
    filePath = [filePath stringByAppendingPathExtension:@"mp3"];

    NSArray *ar = [AVAssetExportSession exportPresetsCompatibleWithAsset: songAsset];
    NSLog(@"%@", ar);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                      presetName: AVAssetExportPresetAppleM4A];
    
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    
 //   exporter.outputFileType = @"com.apple.m4a-audio";
    exporter.outputFileType = AVFileTypeMPEGLayer3;
    
    NSError *error1;
    
    if([fileManager fileExistsAtPath:filePath])
    {
        [fileManager removeItemAtPath:filePath error:&error1];
    }
    
    exporter.outputURL = [NSURL fileURLWithPath:filePath];
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
         NSData *data1 = [NSData dataWithContentsOfFile:filePath];
        
         int exportStatus = exporter.status;
         
         switch (exportStatus) {
             case AVAssetExportSessionStatusFailed: {
                 
                 // log error to text view
                 NSError *exportError = exporter.error;
                 
                 NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                 break;
             }
             case AVAssetExportSessionStatusCompleted: {
                 NSLog (@"AVAssetExportSessionStatusCompleted");
                 break;
             }
                 
             case AVAssetExportSessionStatusUnknown: {
                 NSLog (@"AVAssetExportSessionStatusUnknown");
                 break;
             }
             case AVAssetExportSessionStatusExporting: {
                 NSLog (@"AVAssetExportSessionStatusExporting");
                 break;
             }
                 
             case AVAssetExportSessionStatusCancelled: {
                 NSLog (@"AVAssetExportSessionStatusCancelled");
                 break;
             }
                 
             case AVAssetExportSessionStatusWaiting: {
                 NSLog (@"AVAssetExportSessionStatusWaiting");
                 break;
             }
                 
             default:{
                 NSLog (@"didn't get export status");
                 break;
             }
         }
     }];
}

@end
