//
//  demandVc.m
//  Umote
//
//  Created by sampath on 2015-02-03.
//  Copyright (c) 2015 MSMU. All rights reserved.
//

#import "demandVc.h"
#import "UmoteModel.h"
#import "UIImageView+WebCache.h"
@interface demandCELL()

@property (weak, nonatomic) IBOutlet UIImageView *imView;
@property (weak, nonatomic) IBOutlet UILabel *labl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actvity;



@end
@implementation demandCELL

@end
@interface demandVc ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) NSArray *lastPageData;

@end
static NSInteger FetchLimit = 10;

@implementation demandVc
- (void)fetchPage
{
    if (self.lastPageData && self.lastPageData.count != FetchLimit)
    {
        // last fetch didn't have enough element to make the full page, we must have reach the end.
        return;
    }
    
    NSInteger page = self.data.count/FetchLimit + 1;
    
    [[UmoteModel sharedModel] fetchdemand:FetchLimit page:page completionHandler:^(NSArray *udemands, NSString *errMsg)
     {
         self.lastPageData = udemands;
         
         if (udemands.count)
         {
             [self.data addObjectsFromArray:udemands];
             [self.collectionView  reloadData];
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
    demandCELL *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UDemandCell" forIndexPath:indexPath];
    
    NSDictionary *udemand = self.data[indexPath.row];
    NSString *imgUrlStr = udemand[UDEMAND_posterImage];
    
    [cell.actvity startAnimating];
    [cell.imView setImageWithURL:[NSURL URLWithString:imgUrlStr] placeholderImage:nil success:^(UIImage *image)
     {
         [cell.actvity stopAnimating];
     } failure:^(NSError *error) {
         [cell.actvity stopAnimating];
     }];
    cell.labl.text = udemand[UDEMAND_name];
    
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
    
    demandCELL *cell = (demandCELL *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor grayColor];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    demandCELL *cell = (demandCELL *)[collectionView cellForItemAtIndexPath:indexPath];
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


