//
//  FullJobListVC.m
//  Jobalo
//
//  Created by Maverics on 8/22/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "FullJobListVC.h"
#import "MyJobDetailVC.h"
#import "JobDetailVC.h"
#import "AppDelegate.h"

@interface FullJobListVC ()

@end

@implementation FullJobListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Delegate & Datasource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *jobObject = self.fullJobList[indexPath.row];

    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
        MyJobDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"MyJobDetailVC"];
        dest.title = @"Job Applicants";
        dest.jobDetailInfo = jobObject;
        [self.navigationController pushViewController:dest animated:YES];
    }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]){
        JobDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"JobDetailVC"];
        dest.title = @"Job listing";
        dest.jobObject = jobObject;
        [self.navigationController pushViewController:dest animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fullJobList.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cell_ID = @"jobCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cell_ID];
    NSDictionary *jobObject = self.fullJobList[indexPath.row];
    
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

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
        return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            //add code here for when you hit delete
            [self DeleteJob:indexPath.row];
        }
    }
}

#pragma mark - DELTE
- (void)DeleteJob:(NSInteger)index{
    [SVProgressHUD show];
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
   
    NSDictionary *jobObject = self.fullJobList[index];
    NSInteger jobId = [jobObject[@"id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%lu", BASIC_URL, EMPLOYER_JOB ,jobId];

    [manager DELETE:urlString
         parameters:@{@"access_token": token}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                [SVProgressHUD dismiss];
                
                if (responseObject) {
                    // success in web service call return
                    NSMutableArray *tempList = [self.fullJobList mutableCopy];
                    [tempList removeObjectAtIndex:index];
                    self.fullJobList = tempList;
                    [self.jobTblView reloadData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[AppDelegate sharedInstance] getPostedJobsByEmployer];
                    });
                }else{
                    // failure response
                    [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                [SVProgressHUD dismiss];
                
                [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
            }
     ];
}

@end
