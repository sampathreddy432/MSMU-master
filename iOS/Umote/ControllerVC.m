//
//  ControllerVC.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-06.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "ControllerVC.h"
#import "UmoteModel.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ControllerVC ()
{
    __weak IBOutlet UIButton *_btnChUp;
    __weak IBOutlet UIButton *_btnChDown;
    __weak IBOutlet UIButton *_btnVolUp;
    __weak IBOutlet UIButton *_btnVolDown;
    
    __weak IBOutlet UIButton *_btnRemoteChUp;
    __weak IBOutlet UIButton *_btnRemoteChDown;
    __weak IBOutlet UIButton *_btnRemoteVolUp;
    __weak IBOutlet UIButton *_btnRemoteVolDown;
    __weak IBOutlet UIButton *_btnRemoteMute;
}

@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UIView *controllerView;

@end

@implementation ControllerVC

- (IBAction)onRemoteChannelUp:(id)sender {
    [[UmoteModel sharedModel] remoteControl:RemoteChannelUp completionHandler:^(BOOL success, NSString *errMsg) {

    }];
}

- (IBAction)onRemoteChannelDown:(id)sender {
    [[UmoteModel sharedModel] remoteControl:RemoteChannelDown completionHandler:^(BOOL success, NSString *errMsg) {
        
    }];
}

- (IBAction)onRemoteVolumeDown:(id)sender {
    [[UmoteModel sharedModel] remoteControl:RemoteVolumeDown completionHandler:^(BOOL success, NSString *errMsg) {
        
    }];
}

- (IBAction)onRemoteVolumeUp:(id)sender {
    [[UmoteModel sharedModel] remoteControl:RemoteVolumeUp completionHandler:^(BOOL success, NSString *errMsg) {
        
    }];
}

- (IBAction)onRemoteMute:(id)sender {
    [[UmoteModel sharedModel] remoteControl:RemoteMute completionHandler:^(BOOL success, NSString *errMsg) {
        
    }];
}

- (IBAction)onChannelUp:(id)sender {
    [[UmoteModel sharedModel] channelUp];
}

- (IBAction)onChannelDown:(id)sender {
    [[UmoteModel sharedModel] channelDown];
}

- (IBAction)onVolumeUp:(id)sender {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume = musicPlayer.volume + 0.0625;
}

- (IBAction)onVolumeDown:(id)sender {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume = musicPlayer.volume - 0.0625;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tabBarController.tabBar setBarTintColor:[UIColor colorWithRed:44.0/255.0 green:49.0/255.0 blue:55.0/255.0 alpha:1.0]];
    [self.tabBarController.tabBar setTranslucent:NO];
    
}

- (void)updateUI
{
    if ([UmoteModel sharedModel].isRemoteMode)
    {
        self.controllerView.hidden = NO;
        self.playView.hidden = YES;
    }
    else
    {
        self.controllerView.hidden = YES;
        self.playView.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUI)
                                                 name:kUmoteRemoteModeChanged
                                               object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.view.frame;
    
    CGFloat len = MIN(self.view.frame.size.height, self.view.frame.size.width);
    CGFloat offsetX = (frame.size.width - len) / 2;
    
    
    _btnChUp.center    = CGPointMake(len/2 + offsetX,   frame.size.height - len/4*3);
    _btnChDown.center  = CGPointMake(len/2 + offsetX,   frame.size.height - len/4);
    _btnVolDown.center = CGPointMake(len/4 + offsetX,   frame.size.height - len/2);
    _btnVolUp.center   = CGPointMake(len/4*3 + offsetX, frame.size.height - len/2);
    
    _btnRemoteChUp.center    = CGPointMake(len/2 + offsetX,   frame.size.height - len/4*3);
    _btnRemoteChDown.center  = CGPointMake(len/2 + offsetX,   frame.size.height - len/4);
    _btnRemoteVolDown.center = CGPointMake(len/4 + offsetX,   frame.size.height - len/2);
    _btnRemoteVolUp.center   = CGPointMake(len/4*3 + offsetX, frame.size.height - len/2);
    _btnRemoteMute.center    = CGPointMake(len/2 + offsetX,   frame.size.height - len/2);
    
    CGPoint toggleCenter = self.view.center;
    toggleCenter.x = toggleCenter.x + len/2 - 44.0;
    toggleCenter.y = toggleCenter.y - len/2 + 44.0;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
