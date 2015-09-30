//
//  UmoteVC.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-05.
//  Copyright (c) 2014 MSMU. All rights reserved.
//
#import "UmoteApplication.h"

#import "UmoteVC.h"
#import "UmoteModel.h"

#import "IMAAdsLoader.h"
#import "IMAAVPlayerContentPlayhead.h"

@interface UmoteVC () <UITabBarDelegate, UmoteChannelChangeDelegate, UIGestureRecognizerDelegate, IMAAdsLoaderDelegate, IMAAdsManagerDelegate, UIActionSheetDelegate, UIActivityItemSource>
{
    UISwipeGestureRecognizer *_rightSwipe;
    UISwipeGestureRecognizer *_leftSwipe;
    UITapGestureRecognizer *_singleTap;
    
    __weak IBOutlet UIView *_controlView;
    __weak IBOutlet UITextView *_debugTextView;
    
    NSNumber *_playingChannel;
    NSDictionary *_metaData;

    UIActionSheet *_actionSheet;
    
    UIInterfaceOrientation _layoutOrientation;
}

@property (weak, nonatomic) IBOutlet UILabel *lblChannelName;
@property (weak, nonatomic) IBOutlet UILabel *lblChannelId;

@property (nonatomic, assign) BOOL isTriggeredByPause;
@property (nonatomic, strong) IMAAdsLoader *adsLoader;
@property (nonatomic, strong) IMAAdsManager *adsManager;

@property (nonatomic, assign) BOOL adPlaying;
@property (nonatomic, assign) NSInteger lastAdRequestLength;

@property (nonatomic, weak) MPTimedMetadata *adMetaData;

@end

@implementation UmoteVC

#pragma mark - IMA

- (IMASettings *) createIMASettings {
    IMASettings *settings = [[IMASettings alloc] init];
    settings.ppid = @"IMA_PPID_0";
    settings.language = @"en";
    return settings;
}

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    
    if (self.adsLoader != loader)
    {
        NSLog(@"loader mismatch");
        return;
    }
    
    // Get the ads manager from ads loaded data.
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    IMAAVPlayerContentPlayhead *playhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:[AVPlayer new]];
    [self.adsManager initializeWithContentPlayhead:playhead adsRenderingSettings:nil];
    
    // We assume self.videoView is the view where content video is played.
    self.adsManager.adView.frame = self.playerView.bounds;
    [self.playerView addSubview:self.adsManager.adView];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Loading failed, log it.
    NSLog(@"Ad loading error: %@", adErrorData.adError.message);
    
    if (self.adsLoader == loader)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1   * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self requestAdsOfLength:self.lastAdRequestLength-5];
        });
    }
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    [self.player pause];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    [self.player play];
}

- (void)setupAdsLoader {
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:[self createIMASettings]];
    self.adsLoader.delegate = self;
}

- (void)hideButtonInSubviews:(UIView *)superView
{
//    NSLog(@"%@", superView);
//    NSLog(@"%@", [superView subviews]);
    for (UIView *subview in [superView subviews])
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            subview.hidden = YES;
        }
        else
        {
            [self hideButtonInSubviews:subview];
        }
    }
}

// Process ad events.
- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    NSLog(@"Received ad event - %d", event.type);
    // Perform different actions based on the event type.
    if (event.type == kIMAAdEvent_STARTED) {
        NSLog(@"Ad has started.");
        self.adPlaying = YES;
        
        /// hide buttons
        [self hideButtonInSubviews:adsManager.adView];
    }
    else if (event.type == kIMAAdEvent_LOADED)
    {
        NSLog(@"Ad has loaded.");
        [self startAds];
    }
    else if (event.type == kIMAAdEvent_ALL_ADS_COMPLETED)
    {
        NSLog(@"Ad has completed.");
        [self unloadAdsManager];
        
        if ([UmoteModel sharedModel].isRemoteMode)
        {
            [self requestAds];
        }
        else
        {
            [[UmoteModel sharedModel] syncVideoId];
        }
        
        self.adPlaying = NO;
    }
    else if (event.type == kIMAAdEvent_PAUSE)
    {
        self.adPlaying = NO;
    }
}

- (void)unloadAdsManager {
    if (self.adsManager != nil) {
        [self.adsManager destroy];
        self.adsManager.delegate = nil;
        self.adsManager = nil;
    }
    
    self.adsLoader = nil;
}

// Process ad playing errors.
- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    // There was an error while playing the ad.
    NSLog(@"Error during ad playback: %@", error.message);
}

// Optional: receive updates about individual ad progress.
- (void)adDidProgressToTime:(NSTimeInterval)mediaTime totalTime:(NSTimeInterval)totalTime {
    // This can be very noisy log - called 5 times a second.
//    NSLog(@"Current ad time: %lf", mediaTime);
}


- (void)startAds {
    [self.adsManager start];
}

#pragma mark - public

- (void)requestAds {
    [self requestAdsOfLength:120];
}

- (void)requestAdsOfLength:(NSInteger)adLength
{
    self.lastAdRequestLength = adLength;
    
    [self setupAdsLoader];
    
    NSString *adTag = [[UmoteModel sharedModel] adUrlWithTime:adLength chanId:nil videoId:nil];
  //@"http://revive.msmu.me/www/delivery/fc.php?script=bannerTypeHtml:vastInlineBannerTypeHtml:vastInlineHtml&format=vast&zones=1&source=mobile&secs=120";

    IMAAdsRequest *request =
    [[IMAAdsRequest alloc] initWithAdTagUrl:adTag
                             companionSlots:nil
                                userContext:nil];
    [self.adsLoader requestAdsWithRequest:request];
    NSLog(@"requestAdsWithRequest: %@", adTag);
}

- (void)updateChannel
{
    [self unloadAdsManager];
 
    UmoteModel *model = [UmoteModel sharedModel];
    
    NSString *urlStr;
    if (model.uDemand)
    {
        NSDictionary *uDemand = model.uDemand;
        self.lblChannelName.text = uDemand[UDEMAND_name];
        self.lblChannelId.text = @"UDemand";
        urlStr = uDemand[UDEMAND_vodurl];
    }
    else
    {
        NSDictionary *ch = model.channels[model.curChannelIdx];
        self.lblChannelName.text = ch[CHANNEL_fullName];
        self.lblChannelId.text = [NSString stringWithFormat:@"channel %@", ch[CHANNEL_chanID]];
        urlStr = ch[CHANNEL_streamURL];
        
#ifdef ID3
        _debugTextView.hidden = NO;
        if (model.curChannelIdx == 0)
        {
            urlStr = @"https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8";
            self.lblChannelName.text = @"Apple Advance Stream";
        }
#endif
        _playingChannel = ch[CHANNEL_chanID];
        

    }
    
    NSURL *url = [NSURL URLWithString:urlStr];

    [self quicklyStopMovie];
    [self quicklyPlayMovie:url seekToPos:0];
    
    [self viewWillLayoutSubviews];
}

#pragma mark - activity

- (IBAction)onShare:(id)sender {
    NSString *text = @"Download the uMote app by MSMU. Great for watching content from all over the world.";
    NSArray *activityItems = @[text, self];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop];
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return [NSURL URLWithString:@"https://itunes.apple.com/us/app/msmu-mote/id898875601?ls=1&mt=8"];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType;
{
    return @"Download uMote app by MSMU.";
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"https://itunes.apple.com/us/app/msmu-mote/id898875601?ls=1&mt=8";
}

#pragma mark - action sheet


NSString *kViewMode = @"View Mode";
NSString *kRemoteMode = @"Remote Mode";

NSString *kLogOut = @"Log Off";
NSString *kLogIn = @"Log In";

- (IBAction)onAction:(id)sender {

    if (_actionSheet != nil)
        return;
    
    NSString *modeStr = [UmoteModel sharedModel].isRemoteMode ?  kViewMode : kRemoteMode;
    
    if ([UmoteModel sharedModel].isSignedIn)
    {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:kLogOut otherButtonTitles:modeStr, nil];
    }
    else
    {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kLogIn, nil];
        
    }
    
    [_actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLogIn])
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self performSegueWithIdentifier:@"logIn" sender:self];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLogOut])
    {
        [[UmoteModel sharedModel] signOut];
        [UmoteModel sharedModel].remoteMode = NO;
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kViewMode])
    {
        [UmoteModel sharedModel].remoteMode = NO;
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kRemoteMode])
    {
        [UmoteModel sharedModel].remoteMode = YES;
    }
    
    _actionSheet = nil;
}

#pragma mark - Umote controls

- (void)hideControl
{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        return;
    }

    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = _controlView.frame;
        frame.origin.x = self.view.frame.size.width;
        _controlView.alpha = 0.0;
        _controlView.frame = frame;
    } completion:^(BOOL finished) {
        [self.view addGestureRecognizer:_singleTap];
    }];
}

- (void)showControl
{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = _controlView.frame;
        frame.origin.x = self.view.frame.size.width - 320;
        _controlView.alpha = 0.85;
        _controlView.frame = frame;
    } completion:^(BOOL finished) {
        [self.view removeGestureRecognizer:_singleTap];
        
    }];
}

- (IBAction)onRightSwipe:(id)sender {
    [self hideControl];
}

- (IBAction)onLeftSwipe:(id)sender {
    [self showControl];
}

- (IBAction)onTapped:(id)sender {
    [self showControl];
}


#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [UmoteModel sharedModel].channelChangeDelegate = self;
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:44.0/255.0 green:49.0/255.0 blue:55.0/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    
    _leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onLeftSwipe:)];
    _leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;

    _rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onRightSwipe:)];
    _rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapped:)];
    _singleTap.delegate = self;

    [self setupPlayer];
    
    NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    [def addObserver:self
            selector:@selector(applicationDidEnterForeground:)
                name:UIApplicationDidBecomeActiveNotification
              object:[UIApplication sharedApplication]];
    [def addObserver:self
            selector:@selector(applicationDidEnterBackground:)
                name:UIApplicationWillResignActiveNotification
              object:[UIApplication sharedApplication]];

    [def addObserver:self
            selector:@selector(remoteModeChanged)
                name:kUmoteRemoteModeChanged
              object:nil];

    [UmoteModel sharedModel].curChannelIdx = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2   * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"logIn" sender:self];
        });
    }
    
    self.canHideControl = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}

- (void)viewWillUnload
{
    [super viewWillUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setCanHideControl:(BOOL)canHideControl
{
    _canHideControl = canHideControl;
    
    if (_canHideControl)
    {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        {
            [self registerForHideControlEvents];
            return;
        }
    }

    [self unregisterForHideControlEvents];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == _layoutOrientation)
    {
        return;   // no layout update needed.
    }
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        self.navigationController.navigationBarHidden = YES;
        
        self.playerView.frame = self.view.frame;
        _controlView.frame = CGRectMake(self.view.frame.size.width - 320,
                                        0,
                                        320,
                                        self.view.frame.size.height);
        _controlView.alpha = 0.6;
        _controlView.backgroundColor = [UIColor clearColor];
        
        [self registerForHideControlEvents];
    }
    else
    {
        self.navigationController.navigationBarHidden = NO;
        
        CGRect frame;
        if ([[UIScreen mainScreen ] bounds ].size.height == 480.0)
        {
            frame = CGRectMake(0,
                               0,
                               self.view.frame.size.width,
                               self.view.frame.size.width * 9 / 16);  // 16:9 for iPhone 4S
        }
        else
        {
            frame = CGRectMake(0,
                               0,
                               self.view.frame.size.width,
                               self.view.frame.size.width * 3 / 4);  // 4:3 for iPhone 5 as there is enough pixel vertically
        }
        
        self.playerView.frame = frame;
        _controlView.frame = CGRectMake(0,
                                        self.playerView.frame.size.height,
                                        self.view.frame.size.width,
                                        self.view.frame.size.height - self.playerView.frame.size.height);
        _controlView.alpha = 1.0;
        _controlView.backgroundColor = [UIColor colorWithRed:43.0/255.0 green:49.0/255.0 blue:54.0/255.0 alpha:1.0];
        
        [self unregisterForHideControlEvents];
    }

    [self updatePlayerFrame];
    
    self.adsManager.adView.frame = self.playerView.bounds;
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    _layoutOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
#ifdef ID3
    [_debugTextView.superview bringSubviewToFront:_debugTextView];
#endif
}

- (BOOL)prefersStatusBarHidden
{
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - gesture delegate
// this allows you to dispatch touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - notifications

- (void)remoteModeChanged
{
    if ([UmoteModel sharedModel].isRemoteMode)
    {
        [self requestAds];
        
        [self quicklyStopMovie];
    }
    else
    {
        [self updateChannel];
    }
}

- (void)applicationDidEnterForeground:(NSNotification *)notification
{
    [self updateChannel];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self quicklyStopMovie];
}

- (void)videoPlaybackStateChanged :(NSNotification *)notification
{
    NSLog(@"videoPlaybackStateChanged - %@", notification);
    if (!self.adPlaying &&
        [self.player playbackState] == MPMoviePlaybackStatePaused)
    {
        [self.player pause];
    }
}



#pragma mark - helpers

- (NSString *)metaDataDescription
{
    NSString *str = @"";
    
    for (MPTimedMetadata *metadata in self.player.timedMetadata)
    {
        str = [NSString stringWithFormat:
               @"%@ \n"
               "<MPTimedMetadata: %p>\n"
               "allMetaData = \n%@\n"
               "key =\n%@\n"
               "keyspace =\n%@\n"
               "timestamp =\%f\n"
               "value = \n%@\n",
               str,
               metadata,
               [metadata.allMetadata description],
               [metadata.key description],
               [metadata.keyspace description],
               metadata.timestamp,
               [metadata.value description]
               ];
        
        NSLog(@"%@", str);
        
        NSData *jsonData = [metadata.value dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];

        NSLog(@"%@", dict);

        NSString *videoIdStr = dict[@"videoId"];
        if (videoIdStr)
        {
            NSNumber *vidId = [NSNumber numberWithInteger:[videoIdStr integerValue]];
            [UmoteModel sharedModel].videoId = vidId;
        }
        
        NSNumber *commercial = dict[@"commercial"];
        NSNumber *stamp = dict[@"stamp"];
        
        if ([commercial integerValue] == 1)
        {
            if (self.adPlaying == YES)
            {
                NSLog(@"---------------- ad already playing");
            }
            else if (self.adMetaData == metadata)
            {
                NSLog(@"---------------- received repeating metadata");
            }
            else
            {
                [self requestAdsOfLength:(120 - [stamp integerValue])];
                self.adPlaying = YES;
                self.adMetaData = metadata;
            }
        }
    }
    
    _debugTextView.text = str;
    return str;
}

- (void)metadataUpdate:(id)obj{
    NSLog(@"metadataUpdate - %@", obj);
    [self metaDataDescription];
}

- (void)metadataUserInfoKey:(id)obj{
    NSLog(@"metadataUserInfoKey - %@", obj);
}

- (void)setupPlayer
{
   
    
MPMoviePlayerController *player = [[MPMoviePlayerController alloc] init ];//WithContentURL: myURL];
    player.movieSourceType = MPMovieSourceTypeUnknown;//MPMovieSourceTypeStreaming;
    player.controlStyle = MPMovieControlStyleDefault;
   
    self.player = player;
    [self.playerView addSubview: self.player.view];
    self.playerView.frame = CGRectMake(0, 0, 300, 400);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlaybackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];
}



- (void)updatePlayerFrame
{
    [self.player.view setFrame: self.playerView.bounds];
}

- (void)playInPlayer:(NSURL*)fileURL seekToPos:(long)pos
{
    self.player.contentURL = fileURL;
    [self.player play];
    // Register for meta-data notifications
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(metadataUpdate:)
                   name:MPMoviePlayerTimedMetadataUpdatedNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(metadataUserInfoKey:)
                   name:MPMoviePlayerTimedMetadataUserInfoKey
                 object:nil];
}

- (void)stopInPlayer
{
    
    [self.player stop];
   
}

-(void)quicklyPlayMovie:(NSURL*)fileURL seekToPos:(long)pos
{
	[UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [self playInPlayer:fileURL seekToPos:pos];
    
    NSLog(@"playing - %@", fileURL);
}

-(void)quicklyStopMovie
{
    [self stopInPlayer];
    
   _playingChannel = nil;

	[UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)registerForHideControlEvents
{
    if (self.canHideControl)
    {
        
        [self.view addGestureRecognizer:_leftSwipe];
        [self.view addGestureRecognizer:_rightSwipe];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideControl) name:kApplicationDidTimeoutNotification object:nil];
    }
}

- (void)unregisterForHideControlEvents
{
    [self.view removeGestureRecognizer:_leftSwipe];
    [self.view removeGestureRecognizer:_rightSwipe];
    [self.view removeGestureRecognizer:_singleTap];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationDidTimeoutNotification object:nil];
}





@end
