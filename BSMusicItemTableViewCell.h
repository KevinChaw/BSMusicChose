//
//  BSMusicItemTableViewCell.h
//  BSMusicChose
//
//  Created by 邹志勇 on 15/5/26.
//  Copyright (c) 2015年 邹志勇. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@interface BSMusicItemTableViewCell : UITableViewCell

@property (nonatomic,strong) UILabel *songNameLabel;


@property (nonatomic,strong) UIImageView *playView;

-(void) setDuration:(double) duration;

-(void) setPlayPosition:(double) position;

@end
