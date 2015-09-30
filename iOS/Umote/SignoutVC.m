//
//  SignoutVC.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-13.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "SignoutVC.h"
#import "UmoteModel.h"

@interface SignoutVC ()

@property (weak, nonatomic) IBOutlet UIButton *btnSignOut;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segMode;

@end

@implementation SignoutVC

- (void)updateUI
{
    if ([UmoteModel sharedModel].isSignedIn)
    {
        self.btnSignIn.hidden = YES;
        self.btnSignOut.hidden = NO;
    }
    else
    {
        self.btnSignIn.hidden = NO;
        self.btnSignOut.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

- (IBAction)onLogOut:(id)sender {
    [[UmoteModel sharedModel] signOut];
    [self updateUI];
}

- (IBAction)onSignIn:(id)sender {
}

- (IBAction)onSegChanged:(id)sender {
    [UmoteModel sharedModel].remoteMode = (self.segMode.selectedSegmentIndex == 1);
    
    self.tabBarController.selectedIndex = 0;
}

@end
