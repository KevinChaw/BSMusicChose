//
//  BSMusicPickViewController.h
//  BSMusicChose
//
//  Created by 邹志勇 on 15/5/26.
//  Copyright (c) 2015年 邹志勇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSMusicPickViewController;

@protocol BSMusicPickDelegate <NSObject>

-(void) choseMusic:(NSURL *) assetURL musicPick:(BSMusicPickViewController *) musicPick;

@end

@interface BSMusicPickViewController : UIViewController

@property (nonatomic, weak) id<BSMusicPickDelegate> delegate;

@end
