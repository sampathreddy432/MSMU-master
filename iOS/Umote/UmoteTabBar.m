//
//  UmoteTabBar.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-08-18.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "UmoteTabBar.h"
#import "UmoteModel.h"
#import "VoteVc.h"
#import "CommentTVC.h"

@interface UmoteTabBar () <UITabBarControllerDelegate, UIActionSheetDelegate>

@end

@implementation UmoteTabBar


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
}

NSString *kLogInStr = @"Log In";


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kLogInStr])
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
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([UmoteModel sharedModel].isSignedIn == NO)
    {
        if ([viewController isKindOfClass:[CommentTVC class]])
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Please log in to comment" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kLogInStr, nil];
            
            [actionSheet showFromTabBar:self.tabBar];
            
            return NO;
        }
            
    }
    
    if ([UmoteModel sharedModel].videoId == nil)
    {
        NSString *err;
        
        if ([viewController isKindOfClass:[VoteVc class]])
        {
            err = @"Unable to Vote at this time! Please try again later!";
        }
        else if ([viewController isKindOfClass:[CommentTVC class]])
        {
            err = @"Unable to Comment at this time! Please try again later!";
        }
        
        if (err)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:err delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
            return NO;
        }
    }
    
    return YES;
}

@end
