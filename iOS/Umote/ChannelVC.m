//
//  ChannelVC.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-04-06.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "ChannelVC.h"
#import "UmoteModel.h"
#import "UmoteVC.h"
#import "UIImageView+WebCache.h"

@interface ChannelCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImg;

@end


@implementation ChannelCell

@end


@interface ChannelVC ()

@property (nonatomic, readonly) NSArray *dataArray;

@end

@implementation ChannelVC


- (NSArray *)dataArray
{
    return [UmoteModel sharedModel].channels;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSInteger i = [UmoteModel sharedModel].curChannelIdx;
    if (i >= 0)
    {
        if (self.dataArray.count)
        {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tabBarController.tabBar setBackgroundColor:[UIColor clearColor]];
    [self.tabBarController.tabBar.superview setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChannelCell *cell = (ChannelCell *)[tableView dequeueReusableCellWithIdentifier:@"ChannelCell" forIndexPath:indexPath];
    
    NSDictionary *ch = self.dataArray[indexPath.row];
    
    cell.nameLabel.text = ch[CHANNEL_shortName];
    cell.idLabel.text = [NSString stringWithFormat:@"Channel %@", ch[CHANNEL_chanID]];
    
    cell.backgroundColor = [UIColor clearColor];
    
    NSString *str = ch[CHANNEL_logo];
    
    [cell.logoImg setImageWithURL:[NSURL URLWithString:str]
                    placeholderImage:[UIImage imageNamed:@"appIcon"]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UmoteModel sharedModel].curChannelIdx = indexPath.row;
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
