//
//  JobDetailVC.m
//  Jobalo
//
//  Created by Maverics on 8/21/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "JobDetailVC.h"
#import "AppDelegate.h"

#define kOFFSET_KEYBOARD 150

@interface JobDetailVC (){
    IBOutlet UILabel *ageLabel, *wageLabel, *titleLabel, *descLabel;
    IBOutlet UIImageView *jobImgView;
    
    IBOutlet UIView *subContainerView, *applyView;
    IBOutlet UILabel *applyDetailTitleLabel;
    IBOutlet UITextField *applyTxtField;
    IBOutlet UITextView *coverLetterTxtView, *restInfoTxtView;
    IBOutlet UIButton *saveJobBtn, *applyJobBtn;
    
    BOOL bSavedAlready, bAppliedAlready;
}
@end

@implementation JobDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavigationBar];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self judgeSavedAlready];
    [self judgeAppliedAlready];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupUI{
    // profile photo
    NSString *photoUrl = self.jobObject[@"parent"][@"image_url"];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [photoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:result] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [SVProgressHUD dismiss];
        
        jobImgView.image = image;
    }];
    
    titleLabel.text = self.jobObject[@"title"];
    descLabel.text = self.jobObject[@"description"];
    wageLabel.text = [NSString stringWithFormat:@"$%@", self.jobObject[@"price"]];
    
//    NSArray *fromAgeStrComponent = [self.jobObject[@"start_time"] componentsSeparatedByString:@"/"];
//    NSArray *limitAgeStrComponent = [self.jobObject[@"deadline"] componentsSeparatedByString:@"/"];
//    NSString *fromYearValue, *limitYearValue;
//    
//    if (fromAgeStrComponent && fromAgeStrComponent.count > 2) {
//        fromYearValue = fromAgeStrComponent[2];
//    }
//    if (limitAgeStrComponent && limitAgeStrComponent.count > 2) {
//        limitYearValue = limitAgeStrComponent[2];
//    }
    
    ageLabel.text = [NSString stringWithFormat:@"%@-%@", self.jobObject[@"start_time"], self.jobObject[@"deadline"]];
    applyDetailTitleLabel.text = [AppDelegate sharedInstance].userInfo[@"description"];
}

- (void)setupNavigationBar{
    // Unhide the navigation bar
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    // Navbar color
    [self.navigationController.navigationBar setAlpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor groupTableViewBackgroundColor];
    
    // Nabvar title tine color
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:[UIColor grayColor],
                                                                      NSFontAttributeName:[UIFont boldSystemFontOfSize:22.0f]
                                                                      }];
    
    // Left button
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(ToggleMenu:)];
    [leftItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark - IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)SaveJob:(id)sender{
    if (bSavedAlready)
        [self unFavorite];
    else
        [self addFavorite];
}

- (IBAction)ApplyNow:(id)sender{
    [subContainerView setHidden:NO];
    applyView.center = subContainerView.center;
    [subContainerView addSubview:applyView];
}

#pragma mark Apply Modal-Page
- (IBAction)ApplyJob:(id)sender{
    if (bAppliedAlready) {
        [[AppDelegate sharedInstance] showAlertMessage:@"Applied" message:@"You already applied this job." buttonTitle:@"Ok"];
    }else{
        [self applyJob];
    }
}

- (IBAction)CloseApplyView:(id)sender{
    [applyView removeFromSuperview];
    [subContainerView setHidden:YES];
}

- (void)judgeSavedAlready{
    for (int i=0; i<[AppDelegate sharedInstance].savedJobs.count; i++) {
        NSDictionary *savedJob = [AppDelegate sharedInstance].savedJobs[i];
        if ([[self.jobObject[@"id"] stringValue] isEqualToString:[savedJob[@"id"] stringValue]]) {
            bSavedAlready = YES;
        }else{
            bSavedAlready = NO;
        }
    }
    
    if (bSavedAlready) {
        [saveJobBtn setTitle:@"UNSAVE JOB" forState:UIControlStateNormal];
        saveJobBtn.userInteractionEnabled = YES;
    }else{
        [saveJobBtn setTitle:@"SAVE JOB" forState:UIControlStateNormal];
        saveJobBtn.userInteractionEnabled = YES;
    }
}

- (void)judgeAppliedAlready{
    for (int i=0; i<[AppDelegate sharedInstance].appliedJobs.count; i++) {
        NSDictionary *appliedJob = [AppDelegate sharedInstance].appliedJobs[i];
        if ([[self.jobObject[@"id"] stringValue] isEqualToString:[appliedJob[@"id"] stringValue]]) {
            bAppliedAlready = YES;
        }else{
            bAppliedAlready = NO;
        }
    }
    
    if (bAppliedAlready) {
        applyJobBtn.userInteractionEnabled = NO;
        [[AppDelegate sharedInstance] showAlertMessage:@"Applied" message:@"You already applied this job." buttonTitle:@"Ok"];
    }else{
        applyJobBtn.userInteractionEnabled = YES;
    }
}

#pragma mark - Webservice

- (void)applyJob{
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYEE_JOB_APPLY];
    
    if ((applyTxtField.text.length < 1) ||
        (coverLetterTxtView.text.length < 1)){
        [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Please fill out the information." buttonTitle:@"Ok"];
    }else{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString
           parameters:@{@"babysitter_id": [NSString stringWithFormat:@"%lu", (long)[AppDelegate sharedInstance].userId],
                        @"job_id": _jobObject[@"id"],
                        @"price": [applyTxtField.text substringFromIndex:1],
                        @"price_type": self.jobObject[@"price_type"],
                        @"start_time": @"None",
                        @"end_time": @"None",
                        @"cover_letter": coverLetterTxtView.text,
                        @"access_token": token
                        }
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Apply Job State - JSON: %@", responseObject);
                  
                  if ([responseObject[@"result"] intValue] == 1){
                      // success in web service call return
                      [[AppDelegate sharedInstance] showAlertMessage:@"Success" message:responseObject[@"message"] buttonTitle:@"Ok"];

                      NSMutableArray *appliedJobList = [[AppDelegate sharedInstance].appliedJobs mutableCopy];
                      [appliedJobList addObject:self.jobObject];
                      [AppDelegate sharedInstance].appliedJobs = appliedJobList;
                      [[AppDelegate sharedInstance].userDefaults setObject:[AppDelegate sharedInstance].appliedJobs forKey:@"appliedJobs"];
                      [[AppDelegate sharedInstance].userDefaults synchronize];
                      
                      [applyView removeFromSuperview];
                      [subContainerView setHidden:YES];
                  }else{
                      // failure response
                      NSLog(@"Failure");

                      // failure response
                      NSString *key = [[responseObject[@"message"] allKeys] firstObject];
                      [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:[[responseObject[@"message"] objectForKey:key] firstObject] buttonTitle:@"Ok"];
                  }
                  
                  [SVProgressHUD dismiss];
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
                  
                  [SVProgressHUD dismiss];
              }
         ];
    }
}

- (void)addFavorite{
    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *jobId = [NSString stringWithFormat:@"%@", self.jobObject[@"id"]];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYEE_ADD_FAVORITE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlString
       parameters:@{@"babysitter_id": [NSString stringWithFormat:@"%lu", userId],
                    @"job_id": jobId,
                    @"access_token": token}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Saved Status - JSON: %@", responseObject);
              
              if ([responseObject[@"result"] intValue] == 1){
                  NSLog(@"success");

                  [[AppDelegate sharedInstance] showAlertMessage:@"Success" message:@"This job is saved." buttonTitle:@"Ok"];

                  // success in web service call return
                  NSMutableArray *tempList = [[AppDelegate sharedInstance].savedJobs mutableCopy];
                  [tempList addObject:self.jobObject];
                  [AppDelegate sharedInstance].savedJobs = tempList;
                  
                  [saveJobBtn setTitle:@"UNSAVE JOB" forState:UIControlStateNormal];
//                  saveJobBtn.userInteractionEnabled = NO;
              }else{
                  // failure response
                  NSLog(@"failure");
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }
     ];
}

- (void)unFavorite{
    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *jobId = self.jobObject[@"id"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYEE_DIS_FAVORITE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlString
       parameters:@{@"babysitter_id": [NSString stringWithFormat:@"%lu", (long)userId],
                    @"job_id": jobId,
                    @"access_token": token}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              
              if (responseObject[@"result"]){
                  // success in web service call return
                  NSLog(@"success");
                  
                  [[AppDelegate sharedInstance] showAlertMessage:@"Success" message:@"This job is unsaved." buttonTitle:@"Ok"];
                  
                  NSMutableArray *tempList = [[AppDelegate sharedInstance].savedJobs mutableCopy];
                  for (int i=0; i<tempList.count; i++) {
                      NSDictionary *tempJob = tempList[i];
                      if (tempJob == self.jobObject) {
                          [tempList removeObject:tempJob];
                      }
                  }
                  [AppDelegate sharedInstance].savedJobs = tempList;
                  
                  [saveJobBtn setTitle:@"SAVE JOB" forState:UIControlStateNormal];
              }else{
                  // failure response
                  NSLog(@"failure");
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }
     ];
}

#pragma mark - UITextField & UITextView Delegate
// Set the currency symbol if the text field is blank when we start to edit.
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == applyTxtField) {
        if (textField.text.length  == 0){
            textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == applyTxtField) {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        // Make sure that the currency symbol is always at the beginning of the string:
        if (![newText hasPrefix:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]]){
            return NO;
        }
    }
    
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self keyboardWillShow];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self keyboardWillHide];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self keyboardWillHide];
    }
    return YES;
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        //        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0){
        //        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp){
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_KEYBOARD;
    }
    else{
        // revert back to the normal state.
        rect.origin.y += kOFFSET_KEYBOARD;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end
