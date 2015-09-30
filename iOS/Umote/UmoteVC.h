//
//  UmoteVC.h
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-05.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>


@interface UmoteVC : UIViewController
{
}

@property (strong, nonatomic) MPMoviePlayerController *player;

@property (weak, nonatomic) IBOutlet UIView *playerView;

@property (assign, nonatomic) BOOL canHideControl;

- (void)updateChannel;
- (void)requestAds;

@end
