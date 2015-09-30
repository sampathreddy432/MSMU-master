//
//  TextEntryVc.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-15.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "TextEntryVc.h"

@interface TextEntryCell()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end


@implementation TextEntryCell
@end


@interface TextEntryVc () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TextEntryVc


- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onComment:(id)sender {
    [self.delegate didEnterText:self.textView.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 44.0;
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        {
            return 88.0;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 480.0)
        {
            return 128.0;
        }
        else
        {
            return 172.0;
        }
    }
}

- (void)applyRoundCorner:(UIRectCorner)corner toCell:(UITableViewCell *)cell
{
    float cornerSize = 11.0; // change this if necessary

    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(cornerSize, cornerSize)];
    
    CAShapeLayer *mlayer = [[CAShapeLayer alloc] init];
    mlayer.frame = cell.bounds;
    mlayer.path = maskPath.CGPath;
    cell.layer.mask = mlayer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    

    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
        
        [self applyRoundCorner:(UIRectCornerTopLeft | UIRectCornerTopRight) toCell:cell];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        
        [self applyRoundCorner:(UIRectCornerBottomLeft | UIRectCornerBottomRight) toCell:cell];
        
        self.textView = ((TextEntryCell *)cell).textView;
        [self.textView becomeFirstResponder];
    }
    
    return cell;

}

#pragma mark - view life cycle


- (BOOL) shouldAutorotate
{
    return NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        CGPoint center = self.tableView.center;
        center.y = 110;
        self.tableView.center = center;
    }
    else
    {

    }
    
    [self setNeedsStatusBarAppearanceUpdate];
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

@end
