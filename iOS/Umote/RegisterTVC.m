//
//  RegisterTVC.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-08-07.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "RegisterTVC.h"
#import "UmoteModel.h"

@interface RegisterTVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;
@property (weak, nonatomic) IBOutlet UITextField *dob;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *password2;
@property (strong, nonatomic) IBOutlet UIView *datePickerInputView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (strong, nonatomic) NSArray *fields;

@end

@implementation RegisterTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dob.inputView = self.datePickerInputView;
    
    self.fields = [NSArray arrayWithObjects:
                   self.firstName,
                   self.lastName,
                   self.email,
                   self.gender,
                   self.dob,
                   self.userName,
                   self.password,
                   self.password2,
                   nil];
    
    self.tableView.tableHeaderView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectNextResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self selectNextResponder];
    return YES;
}

- (IBAction)onDatePickerDone:(id)sender {
    [self.dob resignFirstResponder];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    self.dob.text = [dateFormat stringFromDate:self.datePicker.date];
    
    [self selectNextResponder];
}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onRegister:(id)sender {
    
    if (![self.password.text isEqualToString:self.password2.text])
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Password mismatched" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        
        self.password.text = nil;
        self.password2.text = nil;
        [self selectNextResponder];
        return;
    }
    
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                                   fromDate:self.datePicker.date];
 
    NSDictionary *dict = @{RegisterUsername: self.userName.text,
                            RegisterPassword: self.password.text,
                            RegisterFirstName: self.firstName.text,
                            RegisterLastName: self.lastName.text,
                            RegisterEmail: self.email.text,
                            RegisterGender: ((self.gender.selectedSegmentIndex == 0) ? RegisterGenderMale : RegisterGenderFemale),
                            RegisterMonth: [NSNumber numberWithInt:[components month]],
                            RegisterDay: [NSNumber numberWithInt:[components day]],
                            RegisterYear: [NSNumber numberWithInt:[components year]],
                            };
    
    [[UmoteModel sharedModel] registerUser:dict completion:^(BOOL succuess, NSDictionary *data, NSString *errMsg) {
        
        if (succuess)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            for (NSString *key in data.keyEnumerator)
            {
                if ([key isEqualToString:RegisterUsername])
                {
                    self.userName.text = nil;
                }
                if ([key isEqualToString:RegisterPassword])
                {
                    self.password.text = nil;
                    self.password2.text = nil;
                }
                if ([key isEqualToString:RegisterFirstName])
                {
                    self.firstName.text = nil;
                }
                if ([key isEqualToString:RegisterLastName])
                {
                    self.lastName.text = nil;
                }
                if ([key isEqualToString:RegisterEmail])
                {
                    self.email.text = nil;
                }
                if ([key isEqualToString:RegisterMonth] ||
                    [key isEqualToString:RegisterDay] ||
                    [key isEqualToString:RegisterYear])
                {
                    self.dob.text = nil;
                }
                
                [self selectNextResponder];
            }
            
            [[[UIAlertView alloc] initWithTitle:nil message:errMsg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        }
    }];
    
}

- (IBAction)onSegmentChanged:(id)sender {
    [self selectNextResponder];
}

- (void)selectNextResponder
{
    self.registerBtn.enabled = NO;
    
    for (id obj in self.fields)
    {
        if ([obj isKindOfClass:[UITextField class]])
        {
            UITextField *field = obj;
            if (field.text.length == 0)
            {
                field.returnKeyType = UIReturnKeyNext;
                [field becomeFirstResponder];
                return;
            }
        }
        else if ([obj isKindOfClass:[UISegmentedControl class]])
        {
            UISegmentedControl *seg = obj;
            if (seg.selectedSegmentIndex < 0)
            {
                return;
            }
        }
    }
    
    self.registerBtn.enabled = YES;
}

@end
