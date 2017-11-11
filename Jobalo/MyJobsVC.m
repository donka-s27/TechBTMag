//
//  MyJobsVC.m
//  Jobalo
//
//  Created by Maverics on 8/14/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIImage+BlurredFrame/UIImage+BlurredFrame.h>
#import "MyJobsVC.h"
#import "MyJobDetailVC.h"
#import "FullJobListVC.h"

#define MORE_CELL_HEIGHT 25

@interface MyJobsVC (){
    NSInteger default_loads1, default_loads2;
    
    IBOutlet UIView *headerView;
    IBOutlet UIImageView *headerBGView, *profileImgView;
    IBOutlet UILabel *nameLabel, *titleLabel;
    
    IBOutlet UILabel *numbPostedJobsLabel, *numCompletedJobsLabel;
    IBOutlet UITableView *postedJobTblView, *completedJobTblView;
}
@end

@implementation MyJobsVC

#pragma mark - UI

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (3 > self.postedJobList.count)
        default_loads1 = self.postedJobList.count + 1;
    else
        default_loads1 = 3;
    
    if (3 > self.compltedJobList.count)
        default_loads2 = self.compltedJobList.count + 1;
    else
        default_loads2 = 3;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupHeaderView];
        [self setupUI];
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)setupHeaderView{
    //thumbnail-photo imageview circle
    CALayer *roundRect = [profileImgView layer];
    [roundRect setCornerRadius:profileImgView.frame.size.width / 2];
    [roundRect setMasksToBounds:YES];
    
    CGRect borderFrame = CGRectMake(profileImgView.frame.origin.x, profileImgView.frame.origin.y, (profileImgView.frame.size.width), (profileImgView.frame.size.height));
    [roundRect setBackgroundColor:[[UIColor clearColor] CGColor]];
    [roundRect setFrame:borderFrame];
    [roundRect setBorderWidth:9.0f];
    [roundRect setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    //profile photo
    NSString *photoUrl = [AppDelegate sharedInstance].userInfo[@"image_url"];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [photoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
   
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:result] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [SVProgressHUD dismiss];
        
        profileImgView.image = image;
        
        //blur background view
        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
        UIImage *img = [image applyLightEffectAtFrame:frame];
        headerBGView.image = img;
    }];    
    
    //extra information
    NSString *name = [NSString stringWithFormat:[AppDelegate sharedInstance].userInfo[@"firstname"],
                      [AppDelegate sharedInstance].userInfo[@"lastname"]];
    nameLabel.text = name;
    titleLabel.text = [AppDelegate sharedInstance].userInfo[@"description"];
}

- (void)setupUI{
    //table view UI manipulation
    CALayer *roundRect = [postedJobTblView layer];
    [roundRect setCornerRadius:10.0];
    [roundRect setMasksToBounds:YES];
    
    roundRect = [completedJobTblView layer];
    [roundRect setCornerRadius:10.0];
    [roundRect setMasksToBounds:YES];

    postedJobTblView.contentInset = UIEdgeInsetsMake(15, 0, 15, 0);
    completedJobTblView.contentInset = UIEdgeInsetsMake(15, 0, 15, 0);
    
    numbPostedJobsLabel.text = [NSString stringWithFormat:@"%lu Jobs Posted", self.postedJobList.count];
    numCompletedJobsLabel.text = [NSString stringWithFormat:@"%lu Jobs Completed", self.compltedJobList.count];
}

#pragma mark - IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Delegate & Datasource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == postedJobTblView) {
        if (indexPath.row == default_loads1 - 1) {
            FullJobListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"FullJobListVC"];
            dest.fullJobList = self.postedJobList;
            [self.navigationController pushViewController:dest animated:YES];

        }else{
            MyJobDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"MyJobDetailVC"];
            dest.jobDetailInfo = self.postedJobList[indexPath.row];
            dest.title = @"Job Applicants";
            [self.navigationController pushViewController:dest animated:YES];
        }
    }else if (tableView == completedJobTblView) {
        if (indexPath.row == default_loads2 - 1) {
            FullJobListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"FullJobListVC"];
            dest.fullJobList = self.compltedJobList;
            [self.navigationController pushViewController:dest animated:YES];

        }else{
            MyJobDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"MyJobDetailVC"];
            dest.jobDetailInfo = self.compltedJobList[indexPath.row];
            dest.title = @"Job Applicants";
            [self.navigationController pushViewController:dest animated:YES];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == postedJobTblView) {
        return default_loads1;
    }else if (tableView == completedJobTblView) {
        return default_loads2;
    }
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cell_ID1 = @"jobCell";
    NSString *cell_ID2 = @"jobExpandCell";
    UITableViewCell *cell;
    CGFloat indent_large_enought_to_hidden = 10000;

    if (tableView == postedJobTblView) {
        if (indexPath.row == default_loads1 - 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:cell_ID2];
            
            cell.textLabel.text = @"More Jobs Saved";
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:14];
            
            cell.separatorInset = UIEdgeInsetsMake(0, indent_large_enought_to_hidden, 0, 0); // indent large engough for separator(including cell' content) to hidden separator
            cell.indentationWidth = indent_large_enought_to_hidden * -1; // adjust the cell's content to show normally
            cell.indentationLevel = 1; // must add this, otherwise default is 0, now actual indentation = indentationWidth * indentationLevel = 10000 * 1 = -10000
        }else{
            NSDictionary *jobObject = self.postedJobList[indexPath.row];

            cell = [tableView dequeueReusableCellWithIdentifier:cell_ID1];
            
            UILabel *nameLabel = [(UILabel*)cell.contentView viewWithTag:1];
            nameLabel.text = jobObject[@"title"];
            
            UILabel *detailLabel = [(UILabel*)cell.contentView viewWithTag:2];
            detailLabel.text = jobObject[@"description"];

            UIImageView *imgView = [(UIImageView*)cell.contentView viewWithTag:3];
            NSString *imgPath = jobObject[@"parent"][@"image_url"];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:imgPath] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                [SVProgressHUD dismiss];
                imgView.image = image;
            }];
        }
    }else if (tableView == completedJobTblView) {
        if (indexPath.row == default_loads2 - 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:cell_ID2];
            cell.textLabel.text = @"More Jobs Saved";
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:14];
            
            cell.separatorInset = UIEdgeInsetsMake(0, indent_large_enought_to_hidden, 0, 0);
            cell.indentationWidth = indent_large_enought_to_hidden * -1;
            cell.indentationLevel = 1;
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:cell_ID1];
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == postedJobTblView) {
        if (indexPath.row == default_loads1 - 1)
            return MORE_CELL_HEIGHT;
    }else if (tableView == completedJobTblView) {
        if (indexPath.row == default_loads2 - 1)
            return MORE_CELL_HEIGHT;
    }

    return 70;
}

@end
