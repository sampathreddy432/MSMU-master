//
//  CommentTVC.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-12.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "CommentTVC.h"
#import "UmoteModel.h"
#import "TextEntryVc.h"
#import "UIImageView+WebCache.h"
#import "UmoteVC.h"

@interface CommentCell()
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;

@end


@implementation CommentCell
@end



@interface CommentTVC () <TextEntryDelegate, UITextFieldDelegate>
{
    UIRefreshControl *_refreshControl;
}

@property (nonatomic, copy) NSArray *comments;

@end

@implementation CommentTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    _refreshControl = [[UIRefreshControl alloc]init];
    [_refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:_refreshControl];
}

- (void)refreshTable
{
    [_refreshControl beginRefreshing];
    
    NSArray *oldComments = self.comments;
    
    [[UmoteModel sharedModel] fetchCommentsWithCompletionHandler:^(NSArray *comments, NSString *errMsg) {

        self.comments = comments;
        
        NSInteger numberOfCommentsToAdd = comments.count - oldComments.count;

        if (numberOfCommentsToAdd >= 0)
        {
            NSMutableArray *paths = [NSMutableArray array];
            
            for (int i = 0; i < numberOfCommentsToAdd; i++)
            {
                [paths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
            
            [self.tableView insertRowsAtIndexPaths:paths
                                  withRowAnimation:UITableViewRowAnimationTop];
        }
        else
        {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
        }
        
        [_refreshControl endRefreshing];
    }];
}


- (IBAction)onComment:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    TextEntryVc *vc = (TextEntryVc *)[storyboard instantiateViewControllerWithIdentifier:@"TextInputVC"];
    vc.view.backgroundColor = [UIColor clearColor];
    vc.delegate = self;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    
    static UIModalPresentationStyle style = UIModalPresentationCurrentContext;
    self.modalPresentationStyle = style;
    self.navigationController.modalPresentationStyle = style;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.presentedViewController == nil)
    {
        [self.tableView scrollsToTop];
        self.comments = nil;
        [self.tableView reloadData];
        
        [self refreshTable];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable)
                                                 name:kUmoteVideoChanged
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
        return self.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"InputCell" forIndexPath:indexPath];
    }
    else
    {
        CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
        
        NSDictionary *commentDict = self.comments[indexPath.row];
    
        commentCell.commentLabel.text = commentDict[@"message"];
        commentCell.timeLabel.text = commentDict[@"date"];
        commentCell.nameLabel.text = [NSString stringWithFormat: @"by %@ %@",
                                 commentDict[@"firstName"],
                                 commentDict[@"lastName"]];
        
        NSURL *url = [NSURL URLWithString:commentDict[@"thumb"]];
        UIImage *placeHolderImg = [UIImage imageNamed:@"ic_comment"];
        [commentCell.avatarImgView setImageWithURL:url placeholderImage:placeHolderImg success:^(UIImage *image) {

        } failure:^(NSError *error) {

        }];
        
        cell = commentCell;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        //[self onComment:self];
    }

    return nil;
}

- (void)didEnterText:(NSString *)text
{
    [[UmoteModel sharedModel] submitComment:text completionHandler:^(BOOL sucess, NSString *errMsg) {
        [self refreshTable];
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UmoteVC *vc = (UmoteVC *)(self.parentViewController.parentViewController);
    vc.canHideControl = NO;
    
    [self.tableView scrollsToTop];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self didEnterText:textField.text];
    [textField resignFirstResponder];
    textField.text = nil;

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UmoteVC *vc = (UmoteVC *)(self.parentViewController.parentViewController);
    vc.canHideControl = YES;
}

@end
