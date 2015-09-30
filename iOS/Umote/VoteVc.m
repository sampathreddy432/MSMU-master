//
//  VoteVc.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-12.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "VoteVc.h"
#import "UmoteModel.h"


@interface VoteVc () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *btnVote;

@end

@implementation VoteVc

- (IBAction)onVote:(id)sender {
    NSInteger vote = [self.pickerView selectedRowInComponent:0] + 1;
    
    [[UmoteModel sharedModel] submitVote:vote completionHandler:^(BOOL success, NSString *errMsg) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:nil message:errMsg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]
             show];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:errMsg message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]
             show];
        }
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    


}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    self.btnVote.enabled = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect frame = self.view.frame;
    
    CGFloat len = MIN(self.view.frame.size.height, self.view.frame.size.width);
    CGFloat offsetX = (frame.size.width - len) / 2;
    
    self.pickerView.center = CGPointMake(len/2 + offsetX, frame.size.height - len/3 );
    self.btnVote.center = CGPointMake(len/2 + offsetX, frame.size.height - len/3*2 - 40.0);
}



// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSInteger num = row + 1;
    return [[NSNumber numberWithLong:num] description];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    img.image = [UIImage imageNamed:@"voteCircle"];
    img.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    NSInteger num = row + 1;
    label.font = [UIFont boldSystemFontOfSize:24];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [[NSNumber numberWithLong:num] description];
    label.textColor = [UIColor whiteColor];
    
    [img addSubview:label];
    
    return img;
}


@end
