//
//  BSMusicPickViewController.m
//  BSMusicChose
//
//  Created by 邹志勇 on 15/5/26.
//  Copyright (c) 2015年 邹志勇. All rights reserved.
//

#import "BSMusicPickViewController.h"
#import "BSMusicItemTableViewCell.h"

#import <MediaPlayer/MediaPlayer.h>

@interface BSMusicPickViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_songItems;
    NSInteger _currentSelected;
    NSIndexPath * _indexPath;
    
    BOOL _bPlaying;
}

@property(nonatomic, strong) UITableView* tableViewMusic;

@property(nonatomic, strong) MPMusicPlayerController* appMusicPlayer;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong)  UIBarButtonItem *okButton;
@end

@implementation BSMusicPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.title = @"选择音乐";
    
    // Add a custom complete  button as the nav bar's custom right view
    self.okButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", @"")
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(doChose:)];
    self.okButton.tintColor = RGBCOLOR(46, 128, 220);
    self.okButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = self.okButton;
    
    UIButton* cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 30, 30);
    [cancelBtn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setImage:[UIImage imageNamed:@"back_s"] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    //
    CGRect rcRootView = self.view.bounds;
    CGRect rcTableViewMusic = CGRectMake(0, 0, rcRootView.size.width, rcRootView.size.height);
    
    self.tableViewMusic = [[UITableView alloc] initWithFrame:rcTableViewMusic style:UITableViewStylePlain];
    self.tableViewMusic.dataSource = self;
    self.tableViewMusic.delegate = self;
    self.tableViewMusic.multipleTouchEnabled = YES;
    
    [self.view addSubview:self.tableViewMusic];
    

    [self buildMusicLibrary];
}

- (void)dealloc
{
    [self closeMusicPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) buildMusicLibrary
{
    _currentSelected = -1;
    _bPlaying = NO;
    
    if (_songItems == nil)
        _songItems = [[NSMutableArray alloc] init];
    else
        [_songItems removeAllObjects];
    
    MPMediaQuery *everything = [MPMediaQuery songsQuery]; // [[MPMediaQuery alloc] init];

    
    NSArray *items = [everything items];
    for (MPMediaItem *song in items){
        [_songItems addObject:song];
    }
    
    [self.tableViewMusic reloadData];
    
    [self createMusicPlayer];
}

-(void) createMusicPlayer
{
    if(self.appMusicPlayer)
        return;
    
    self.appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [self.appMusicPlayer setShuffleMode:MPMusicShuffleModeOff];
    [self.appMusicPlayer setRepeatMode:MPMusicRepeatModeOne];
    
    //
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(playingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:self.appMusicPlayer];
    
    
    //
    [notificationCenter addObserver:self
                           selector:@selector(playbackStateChanged:)
                               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object:self.appMusicPlayer];
    
    [self.appMusicPlayer beginGeneratingPlaybackNotifications];
}


-(void) closeMusicPlayer
{
    if(self.appMusicPlayer == nil)
        return;
    
    [self.appMusicPlayer stop];
    
    //
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self
                                  name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:self.appMusicPlayer];
    
    
    //
    [notificationCenter removeObserver:self
                               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object:self.appMusicPlayer];
    
    [self.appMusicPlayer endGeneratingPlaybackNotifications];
    
    self.appMusicPlayer = nil;
}

- (void)playingItemChanged:(NSNotification *)notification
{

}

- (void)playbackStateChanged:(NSNotification *)notification
{
    
}

-(void) loadMusic:(NSInteger) index
{
    NSArray *musicArray = [NSArray arrayWithObjects:_songItems[index], nil];
    
    MPMediaItemCollection* musicCollection = [[MPMediaItemCollection alloc] initWithItems:musicArray];
    
    [self.appMusicPlayer setQueueWithItemCollection:musicCollection];
    
    [self.appMusicPlayer play];
 
    if (self.timer == nil)
    {
        //start timer
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                      target:self
                                                    selector:@selector(updatePlayProgress)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    
    _bPlaying = YES;
    
    [self updatePlayStatusUI];
}

- (void) updatePlayProgress
{
    NSTimeInterval currentPosition =  [self.appMusicPlayer currentPlaybackTime];
    
    BSMusicItemTableViewCell *cell = ( BSMusicItemTableViewCell *) [self.tableViewMusic cellForRowAtIndexPath:_indexPath];
    if (cell){
        [cell setPlayPosition:currentPosition];
    }
}

-(void) playPauseMusic
{
    if (_bPlaying){
        [self.appMusicPlayer pause];
    }
    else{
        [self.appMusicPlayer play];
    }
    
    _bPlaying = !_bPlaying;
    
    [self updatePlayStatusUI];
}

-(void) updatePlayStatusUI
{
    BSMusicItemTableViewCell *cell = ( BSMusicItemTableViewCell *) [self.tableViewMusic cellForRowAtIndexPath:_indexPath];
    if (cell){
        if (!_bPlaying)
            cell.playView.image = [UIImage imageNamed:@"playMusic.png"];
        else
            cell.playView.image = [UIImage imageNamed:@"pauseMusic.png"];
    }
}

-(void) closeMyself
{
    if(self.appMusicPlayer)
        [self.appMusicPlayer stop];
    
    if (self.timer)
        [self.timer invalidate];
    
    if (self.navigationController)
    {
        UIViewController *temp = [self.navigationController topViewController];
        if(  temp == (UIViewController *) self)
        {
            
            [self.navigationController dismissViewControllerAnimated:YES
                                                          completion:nil];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {

    }
}

- (void) onCancel:(id)sender
{
    [self closeMyself];
}

- (void) doChose:(id)sender
{
    if (self.delegate){
        NSURL *songURL =[_songItems[_currentSelected] valueForProperty:MPMediaItemPropertyAssetURL];
        [self.delegate choseMusic:[songURL copy]  musicPick:self];
    }
    
    [self closeMyself];
}

#pragma UITableViewDataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _songItems.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath:%ld\n", (long)indexPath.row);
    
    static NSString *CellIdentifier = @"Cell";
    BSMusicItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[BSMusicItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *songTitle =[_songItems[indexPath.row] valueForProperty:MPMediaItemPropertyTitle];
    cell.songNameLabel.text = songTitle;
    
    NSNumber *durationValue = [_songItems[indexPath.row] valueForProperty:MPMediaItemPropertyPlaybackDuration];
    
    [cell setDuration:durationValue.doubleValue];
    
    return cell;
}



#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewMusic){
        
        self.okButton.enabled = YES;
        
        if (_currentSelected == indexPath.row)
        {
            [self playPauseMusic];
            
            return;
        }

        NSMutableArray * arrayCell = [[NSMutableArray alloc] init];
        if(_currentSelected != -1)
            [arrayCell addObject:[NSIndexPath indexPathForRow:_currentSelected  inSection:0]];
        
        [arrayCell addObject:indexPath];

        _currentSelected = indexPath.row;

        [tableView reloadRowsAtIndexPaths:arrayCell withRowAnimation:UITableViewRowAnimationNone];
        
        [tableView selectRowAtIndexPath:indexPath animated:FALSE scrollPosition:UITableViewScrollPositionNone];
        
        _indexPath = [NSIndexPath indexPathForRow:_currentSelected  inSection:0];
        
        [self loadMusic:_currentSelected];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _currentSelected)
        return 88;
    
    return 44;
}

@end
