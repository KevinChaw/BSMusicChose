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
    [self exportMusic:urlMusic];
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
    [self exportMusic:assetURL];
}


- (void) exportMusic: (NSURL *) songURL
{
    if ([songURL.pathExtension caseInsensitiveCompare:@"mp3"] == NSOrderedSame)
        return [self mp3SourceToSink:songURL];
        
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:songURL options:nil];

        
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *filePath = NSTemporaryDirectory();

    filePath = [filePath stringByAppendingPathComponent:[songURL lastPathComponent]];
    filePath = [filePath stringByAppendingPathExtension:@"mp3"];

    NSArray *ar = [AVAssetExportSession exportPresetsCompatibleWithAsset: songAsset];
    NSLog(@"%@", ar);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                      presetName: AVAssetExportPresetAppleM4A];
    
    exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                    presetName: AVAssetExportPresetAppleM4A];
    
    
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    
    exporter.outputFileType = @"com.apple.m4a-audio";

    NSError *error1;
    
    if([fileManager fileExistsAtPath:filePath])
    {
        [fileManager removeItemAtPath:filePath error:&error1];
    }
    
    exporter.outputURL = [NSURL fileURLWithPath:filePath];
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
         int exportStatus = exporter.status;
         
         switch (exportStatus) {
             case AVAssetExportSessionStatusCompleted: {
                 NSLog (@"AVAssetExportSessionStatusCompleted");
                 break;
             }
             case AVAssetExportSessionStatusExporting: {
                 NSLog (@"AVAssetExportSessionStatusExporting");
                 break;
             }
             default:{
                 NSLog (@"some error happened!");
                 break;
             }
         }
     }];
}

- (void) mp3SourceToSink: (NSURL *) mp3URL
{
    if ([mp3URL.pathExtension caseInsensitiveCompare:@"mp3"] != NSOrderedSame)
        return;
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:mp3URL options:nil];
    
    
    NSString* fileName = [[mp3URL lastPathComponent] substringWithRange:NSMakeRange(0, [ [mp3URL lastPathComponent] length] - 4)];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = NSTemporaryDirectory();
    
    NSString* mp3FilePath = [[filePath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"mp3"];
    
    NSString* movFilePath = [[filePath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"mov"];
    
    NSArray *ar = [AVAssetExportSession exportPresetsCompatibleWithAsset: songAsset];
    NSLog(@"%@", ar);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: songAsset
                                                                      presetName: AVAssetExportPresetPassthrough];

    
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    
    NSError *error1;
    
    if([fileManager fileExistsAtPath:movFilePath]){
        [fileManager removeItemAtPath:movFilePath error:&error1];
    }
    
    if([fileManager fileExistsAtPath:mp3FilePath]){
        [fileManager removeItemAtPath:mp3FilePath error:&error1];
    }
    
    exporter.outputURL = [NSURL fileURLWithPath:movFilePath];
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{

        int exportStatus = exporter.status;
        
        switch (exportStatus) {
            case AVAssetExportSessionStatusCompleted: {
                NSLog (@"AVAssetExportSessionStatusCompleted");
                BOOL bResult = [self extractQuicktimeMovie:[NSURL URLWithString:movFilePath] toFile: [NSURL URLWithString:mp3FilePath]];
                if (bResult)
                {
                     NSLog (@"Export mp3 file OK!");
                }
                
                break;
            }
            case AVAssetExportSessionStatusExporting: {
                NSLog (@"AVAssetExportSessionStatusExporting");
                break;
            }
            default:{
                NSLog (@"some error happened!");
                break;
            }
        }
        
        NSError *error;
        if([fileManager fileExistsAtPath:movFilePath]){
            [fileManager removeItemAtPath:movFilePath error:&error];
        }
    }];
}

- (BOOL) extractQuicktimeMovie:(NSURL*)movieURL toFile:(NSURL*)destURL {
    FILE* src = fopen([[movieURL path] cStringUsingEncoding:NSUTF8StringEncoding], "r");
    if (NULL == src) {
        return NO;
    }
    
    char atom_name[5];
    atom_name[4] = '\0';
    unsigned long atom_size = 0;
    while (true) {
        if (feof(src)) {
            break;
        }
        
        fread((void*)&atom_size, 4, 1, src);
        fread(atom_name, 4, 1, src);
        atom_size = ntohl(atom_size);
        const size_t bufferSize = 1024 * 100;
        
        if (strcmp("mdat", atom_name) == 0) {
            FILE* dst = fopen([[destURL path] cStringUsingEncoding:NSUTF8StringEncoding], "w");
            unsigned char buf[bufferSize];
            if (NULL == dst) {
                fclose(src);
                return NO;
            }
            
            // Thanks to Rolf Nilsson/Roni Music for pointing out the bug here:
            // Quicktime atom size field includes the 8 bytes of the header itself.
            atom_size -= 8;
            while (atom_size != 0) {
                size_t read_size = (bufferSize < atom_size)?bufferSize:atom_size;
                if (fread(buf, read_size, 1, src) == 1) {
                    fwrite(buf, read_size, 1, dst);
                }
                atom_size -= read_size;
            }
            
            fclose(dst);
            fclose(src);
            return YES;
        }
        
        if (atom_size == 0)
            break; //0 atom size means to the end of file... if it's not the mdat chunk, we're done
        fseek(src, atom_size, SEEK_CUR);
    }
    
    fclose(src);
    return NO;
}


@end
