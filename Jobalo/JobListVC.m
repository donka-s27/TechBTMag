//
//  JobListVC.m
//  Jobalo
//
//  Created by Maverics on 8/21/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "JobListVC.h"
#import "JobDetailVC.h"

@interface JobListVC (){
    IBOutlet UITableView *jobTblView;
}

@end

@implementation JobListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.jobList = [[NSArray alloc] initWithObjects:@"BIO", @"PAST WORK", @"REFERENCES", @"EXTRA", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI{
    //table view UI manipulation
    CALayer *roundRect = [jobTblView layer];
    [roundRect setCornerRadius:10.0];
    [roundRect setMasksToBounds:YES];
    
    jobTblView.tableHeaderView.hidden = YES;
    jobTblView.tableHeaderView = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Delegate & Datasource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JobDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"JobDetailVC"];
    dest.title = @"Job listing";
    dest.jobObject = self.jobList[indexPath.row];
    [self.navigationController pushViewController:dest animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.jobList.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cell_ID = @"jobCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_ID];
    
    //thumbnail-photo imageview circle
//    CALayer *roundRect = [thumbImgView layer];
//    [roundRect setCornerRadius:thumbImgView.frame.size.width / 2];
//    [roundRect setMasksToBounds:YES];
    
    NSDictionary *jobObject = self.jobList[indexPath.row];
    
    UILabel *nameLabel = [(UILabel*)cell.contentView viewWithTag:2];
    nameLabel.text = jobObject[@"title"];
    
    UILabel *detailLabel = [(UILabel*)cell.contentView viewWithTag:3];
    detailLabel.text = jobObject[@"description"];
    
    UIImageView *imgView = [(UIImageView*)cell.contentView viewWithTag:1];
    NSString *imgPath = jobObject[@"parent"][@"image_url"];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:imgPath] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [SVProgressHUD dismiss];
        imgView.image = image;
    }];
    
    return cell;
}

@end
