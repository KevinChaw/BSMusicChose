//
//  BSMusicItemTableViewCell.m
//  BSMusicChose
//
//  Created by 邹志勇 on 15/5/26.
//  Copyright (c) 2015年 邹志勇. All rights reserved.
//



#import "BSMusicItemTableViewCell.h"
@interface BSMusicItemTableViewCell()
{
    double _duration;
    
}


@property (nonatomic, strong) UILabel *songDurationLabel;
@property (nonatomic, strong) UIProgressView *playProgressView;

@end

@implementation BSMusicItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if(selected){
        self.backgroundColor =[UIColor grayColor];
        self.songNameLabel.textColor = [UIColor whiteColor];
        self.songDurationLabel.textColor = [UIColor whiteColor];
        self.playView.hidden = NO;
        self.playProgressView.hidden = NO;
    }
    else{
        self.backgroundColor =[UIColor whiteColor];
        self.songNameLabel.textColor = [UIColor blackColor];
        self.songDurationLabel.textColor = [UIColor grayColor];
        self.playView.hidden = YES;
        self.playProgressView.hidden = YES;
        [self.playProgressView  setProgress:0 animated:NO];
    }
    
    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
        return nil;

    [self buildView];
    
    return self;
}


-(void) buildView
{
    _duration = 10000;
    
    //
    self.songNameLabel = [[UILabel alloc] init];
    self.songNameLabel.backgroundColor = [UIColor clearColor];
    self.songNameLabel.textColor = [UIColor blackColor];
    self.songNameLabel.text = @"";
    self.songNameLabel.textAlignment = NSTextAlignmentLeft;
    self.songNameLabel.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:self.songNameLabel];
     
    //
    self.songDurationLabel = [[UILabel alloc] init];
    self.songDurationLabel.backgroundColor = [UIColor clearColor];
    self.songDurationLabel.textColor = [UIColor grayColor];
    self.songDurationLabel.text = @"";
    self.songDurationLabel.textAlignment = NSTextAlignmentLeft;
    self.songDurationLabel.font = [UIFont boldSystemFontOfSize:12];
    [self addSubview:self.songDurationLabel];
    
    self.playView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playMusic.png"]];
    self.playView.hidden = YES;
    [self addSubview:self.playView];
    
    //
    self.playProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.playProgressView.trackTintColor = RGBCOLOR(160,160,160); //[UIColor whiteColor];
    self.playProgressView.progressTintColor = [UIColor orangeColor];
    self.playProgressView.hidden = YES;
    [self addSubview:self.playProgressView];
    
}


-(void)layoutSubviews
{
    [super layoutSubviews];

    CGRect rcBounds = self.bounds;
    
    float cellNormalHeight = 44;
    
    float labelHeight = 25.0;
    float durationLabelWidth = 50;
    
    CGRect rcSongName = CGRectMake(8,  (cellNormalHeight - labelHeight) / 2, rcBounds.size.width - durationLabelWidth - 30, labelHeight);
    self.songNameLabel.frame = rcSongName;
    
    CGRect rcSongDuration = CGRectMake(rcBounds.size.width - durationLabelWidth,  (cellNormalHeight - labelHeight) / 2, durationLabelWidth, labelHeight);
    self.songDurationLabel.frame = rcSongDuration;
    
    float playViewHeight = 28;
    CGRect rcPlayView = CGRectMake(12,  cellNormalHeight + (cellNormalHeight - playViewHeight) / 2 - 6, playViewHeight, playViewHeight);
    self.playView.frame = rcPlayView;
    
    CGRect rcProgressBar = CGRectMake(60,  cellNormalHeight + (cellNormalHeight - 2) / 2 - 6, rcBounds.size.width - 80, 2);
    self.playProgressView.frame = rcProgressBar;
}


-(void) setDuration:(double) duration
{
    _duration = duration;
    
    self.songDurationLabel.text = [self timeFormatted:duration];
}

-(void) setPlayPosition:(double) position
{
    float progress = position  / _duration;
    
    [self.playProgressView  setProgress:progress
                               animated:NO];
}


- (NSString *)timeFormatted:(double) duration
{
    int hours   = (int) (duration / 3600.0);
    
    int minutes =(int) ((duration - hours * 3600.0) / 60.0);
    
    int seconds = (int) (duration - hours * 3600.0 - minutes * 60.0);
    
    if (hours != 0){
        return[NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else{
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
}

@end
