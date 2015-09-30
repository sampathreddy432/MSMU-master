//
//  UDemandVc.m
//  Umote
//
//  Created by Tony Chang Yi Cheng on 2014-08-07.
//  Copyright (c) 2014 MSMU. All rights reserved.
//

#import "UDemandVc.h"
#import "UmoteModel.h"
#import "UIImageView+WebCache.h"


@interface UDemandCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *lbl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;




@end


@implementation UDemandCell

@end



@interface UDemandVc ()

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) NSArray *lastPageData;

@end

static NSInteger FetchLimit = 10;

@implementation UDemandVc

- (void)fetchPage
{
    if (self.lastPageData && self.lastPageData.count != FetchLimit)
    {
        // last fetch didn't have enough element to make the full page, we must have reach the end.
        return;
    }
    
    NSInteger page = self.data.count/FetchLimit + 1;
    
    [[UmoteModel sharedModel] fetchUDemand:FetchLimit page:page completionHandler:^(NSArray *udemands, NSString *errMsg)
    {
        self.lastPageData = udemands;
        
        if (udemands.count)
        {
            [self.data addObjectsFromArray:udemands];
            [self.collectionView reloadData];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   self.collectionView.allowsMultipleSelection = NO;
   
    
    self.data = [NSMutableArray array];
    [self fetchPage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (NSIndexPath *index in [self.collectionView indexPathsForSelectedItems])
    {
        if ([UmoteModel sharedModel].uDemand == nil)
        {
            [self.collectionView deselectItemAtIndexPath:index animated:NO];
            [self collectionView:self.collectionView didDeselectItemAtIndexPath:index];
        }
    }
}

#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UDemandCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UDemandCell" forIndexPath:indexPath];

    NSDictionary *udemand = self.data[indexPath.row];
    NSString *imgUrlStr = udemand[UDEMAND_posterImage];
    
    [cell.activity startAnimating];
    [cell.imgView setImageWithURL:[NSURL URLWithString:imgUrlStr] placeholderImage:nil success:^(UIImage *image)
    {
        [cell.activity stopAnimating];
    } failure:^(NSError *error) {
        [cell.activity stopAnimating];
    }];
    cell.lbl.text = udemand[UDEMAND_name];
    
    if (indexPath.row == self.data.count -1)
    {
        [self fetchPage];
    }
    
    if (udemand == [UmoteModel sharedModel].uDemand)
    {
        cell.contentView.backgroundColor = [UIColor grayColor];
    }
    else
    {
        cell.contentView.backgroundColor = nil;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *udemand = self.data[indexPath.row];
    [UmoteModel sharedModel].uDemand = udemand;

    UDemandCell *cell = (UDemandCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor grayColor];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UDemandCell *cell = (UDemandCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
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
