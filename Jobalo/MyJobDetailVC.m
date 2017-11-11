//
//  MyJobDetailVC.m
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "MyJobDetailVC.h"
#import "ApplicantInfoVC.h"

@interface MyJobDetailVC (){
    
    IBOutlet UITableView *appTblView;
    IBOutlet UILabel *numAppLabel;
}

@end

@implementation MyJobDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self getApplicants];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI{
    //table view UI manipulation
    CALayer *roundRect = [appTblView layer];
    [roundRect setCornerRadius:10.0];
    [roundRect setMasksToBounds:YES];
    
    appTblView.tableHeaderView.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Webservice
- (void)getApplicants{
    NSString *jobId = self.jobDetailInfo[@"id"];
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/job/%@/applications", BASIC_URL, jobId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString
      parameters:@{@"access_token": token}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Job Applicants - JSON: %@", responseObject);
             
             if ([responseObject[@"result"] integerValue] == 1) {
                 // success in web service call return
                 if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                     self.applicantList = [NSMutableArray arrayWithObject:responseObject[@"data"]];
                 }else if ([responseObject[@"data"] isKindOfClass:[NSArray class]]){
                     self.applicantList = [NSMutableArray arrayWithArray:responseObject[@"data"]];
                 }
                 
                 numAppLabel.text = [NSString stringWithFormat:@"%lu Job Applicants", self.applicantList.count];
                 [appTblView reloadData];
             }else{
                 // failure response
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[AppDelegate sharedInstance] showAlertMessage:@"No Applicants" message:@"" buttonTitle:@"Ok"];
                 });
             }
             
             [SVProgressHUD dismiss];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
         }
     ];
}


#pragma mark - IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Delegate & Datasource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ApplicantInfoVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ApplicantInfoVC"];
    dest.applicantInfo = self.applicantList[indexPath.row];
    dest.title = @"Profile";
    [self.navigationController pushViewController:dest animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.applicantList.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cell_ID = @"applicationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_ID];
    
    NSDictionary *applicantObject = self.applicantList[indexPath.row];
    NSDictionary *babysitterInfo = applicantObject[@"babysitter"];

    //thumbnail-photo imageview circle
    UIImageView *thumbImgView = (UIImageView*)[cell.contentView viewWithTag:1];
    CALayer *roundRect = [thumbImgView layer];
    [roundRect setCornerRadius:thumbImgView.frame.size.width / 2];
    [roundRect setMasksToBounds:YES];
    
    //profile photo
    NSString *photoUrl = babysitterInfo[@"image_url"];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [photoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:result] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [SVProgressHUD dismiss];
        thumbImgView.image = image;
    }];
    
    //extra information
    UILabel *nameLabel = (UILabel*)[cell.contentView viewWithTag:2];
    NSString *name = [NSString stringWithFormat:babysitterInfo[@"firstname"],
                      babysitterInfo[@"lastname"]];
    nameLabel.text = name;
    
    UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:3];
    titleLabel.text = [babysitterInfo[@"qbid"] stringValue];

    return cell;
}

@end
