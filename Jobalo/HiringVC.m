//
//  HiringVC.m
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIImage+BlurredFrame/UIImage+BlurredFrame.h>
#import "HiringVC.h"

@interface HiringVC (){
    NSString *feeSetting;
    
    IBOutlet UIImageView *backImgView, *thumbImgView;
    IBOutlet UILabel *nameLabel, *titleLabel, *rateLabel;
    IBOutlet UIButton *contractBtn, *businessBtn, *individualBtn;
}

@end

@implementation HiringVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupHeaderView];
    });
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

- (void)setupHeaderView{
    [SVProgressHUD show];
    //thumbnail-photo imageview circle
    CALayer *roundRect = [thumbImgView layer];
    [roundRect setCornerRadius:thumbImgView.frame.size.width / 2];
    [roundRect setMasksToBounds:YES];
    
    CGRect borderFrame = CGRectMake(thumbImgView.frame.origin.x, thumbImgView.frame.origin.y, (thumbImgView.frame.size.width), (thumbImgView.frame.size.height));
    [roundRect setBackgroundColor:[[UIColor clearColor] CGColor]];
    [roundRect setFrame:borderFrame];
    [roundRect setBorderWidth:9.0f];
    [roundRect setBorderColor:[[UIColor lightGrayColor] CGColor]];
        
    //profile photo
    NSDictionary *babysitterInfo = self.applicantInfo[@"babysitter"];
    NSString *photoUrl = babysitterInfo[@"image_url"];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [photoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:result] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [SVProgressHUD dismiss];
        thumbImgView.image = image;
        
        //blur background view
        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
        image = [image applyLightEffectAtFrame:frame];
        backImgView.image = image;
    }];
    
    //extra information
    NSString *name = [NSString stringWithFormat:babysitterInfo[@"firstname"],
                      babysitterInfo[@"lastname"]];
    nameLabel.text = name;
    titleLabel.text = [NSString stringWithFormat:@"%@", babysitterInfo[@"qbid"]];
    rateLabel.text = [NSString stringWithFormat:@"$%@", self.applicantInfo[@"job"][@"price"]];
}

#pragma mark - IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Hire:(id)sender{
    [self createContract];
}

- (IBAction)BasedOnContract:(UIButton*)sender{
    feeSetting = @"contract";
    
    [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [businessBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [individualBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

- (IBAction)Business:(UIButton*)sender{
    feeSetting = @"business";
    
    [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [contractBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [individualBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

- (IBAction)Individual:(UIButton*)sender{
    feeSetting = @"individual";
    
    [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [contractBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [businessBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

#pragma mark - Webservice
- (void)createContract{
    NSDictionary *babysitterInfo = self.applicantInfo[@"babysitter"];
    NSDictionary *jobInfo = self.applicantInfo[@"job"];
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYEE_CREATE_CONTRACT];
    
    NSDictionary *param = @{@"job_id": jobInfo[@"id"],
                           @"babysitter_id": babysitterInfo[@"id"],
                           @"parent_id": [NSString stringWithFormat:@"%lu", [AppDelegate sharedInstance].userId],
                           @"start_time": jobInfo[@"start_time"],
                           @"end_time": jobInfo[@"deadline"],
                           @"access_token": token
                            };
    NSLog(@"%@", param);
    
    /*
     public function getStartTimeAttribute($value) {
     list($year, $month, $day) = explode("-", $value);
     return $month."/".$day."/".$year;
     }
     
     public function getEndTimeAttribute($value){
     list($year, $month, $day) = explode("-", $value);
     return $month."/".$day."/".$year;
     }
     
     public function setStartTimeAttribute($value) {
     list($month, $day, $year) = explode("/", $value);
     $this->attributes['start_time'] = $year."-".$month."-".$day;
     }
     
     public function setEndTimeAttribute($value){
     list($month, $day, $year) = explode("/", $value);
     $this->attributes['end_time'] = $year."-".$month."-".$day;
     }
     
     */
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlString
       parameters:param
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              if ([responseObject[@"result"] intValue] == 1){
                  // success in web service call return
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[AppDelegate sharedInstance] showAlertMessage:@"Success" message:@"You are hired successfully" buttonTitle:@"Ok"];
                  });
              }else{
                  // failure response
                  NSString *key = [[responseObject[@"message"] allKeys] firstObject];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:[[responseObject[@"message"] objectForKey:key] firstObject] buttonTitle:@"Ok"];
                  });
              }
              
              [SVProgressHUD dismiss];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }
     ];
}

@end
