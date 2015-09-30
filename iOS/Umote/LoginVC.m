//
//  LoginVC.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-15.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "LoginVC.h"
#import "UmoteModel.h"

@interface LoginVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@end
@implementation LoginVC

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onLogIn:textField];
    return YES;
}

- (IBAction)onDismissKeypad:(id)sender {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

- (IBAction)onLogIn:(id)sender {
    
    if ([_username.text isEqualToString:@""] || [_password.text isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Log in error"
                                                          message:@"Enter Username and Password"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
    
    if (self.username.text.length == 0)
    {
        [self.username becomeFirstResponder];
    }
    else if (self.password.text.length == 0)
    {
        [self.password becomeFirstResponder];
        
    }
    else
    {
        
        [self.activity startAnimating];
        [[UmoteModel sharedModel] userLogIn:self.username.text password:self.password.text completion:^(BOOL success, NSString *errMsg)
         
         {
             [self.activity stopAnimating];
             
             if (success)
             {
                 [[NSUserDefaults standardUserDefaults] setObject:self.username.text forKey:@"UserName"];
                 [[NSUserDefaults standardUserDefaults] setObject:self.password.text forKey:@"Password"];
                 
                 if (self.presentingViewController)
                 {
                     [self dismissViewControllerAnimated:YES completion:nil];
                     
                 }
                 else
                 {
                    
                     [self performSegueWithIdentifier:@"LogIn" sender:self];
                     
                                      }
             }
             else
             {
                 [[[UIAlertView alloc] initWithTitle:@"Log in error" message:errMsg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
             }
         }];
        
    }
}




- (IBAction)onSkip:(id)sender {
    
    if ([UmoteModel sharedModel].channels.count == 0)
    {
        return;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"LogIn" sender:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.username.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    self.password.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        self.navigationController.navigationBarHidden = YES;
    else
        self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotate
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return YES;

    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
