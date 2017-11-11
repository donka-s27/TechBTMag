//
//  EmployerLoginVC.m
//  Jobalo
//
//  Created by Maverics on 8/14/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "EmployerLoginVC.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "TermsOfUseVC.h"

@implementation EmployerLoginVC{
    IBOutlet UITextField *emailTxtField, *passTxtField;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"LOGIN"]) {
        
    }else if ([segue.identifier isEqualToString:@"FBLOGIN"]) {
        
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //save login credential
    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
        emailTxtField.text = [[AppDelegate sharedInstance].userDefaults objectForKey:@"EMPLOYEE_username"];
        passTxtField.text = [[AppDelegate sharedInstance].userDefaults objectForKey:@"EMPLOYEE_password"];
    }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
        emailTxtField.text = [[AppDelegate sharedInstance].userDefaults objectForKey:@"EMPLOYER_username"];
        passTxtField.text = [[AppDelegate sharedInstance].userDefaults objectForKey:@"EMPLOYER_password"];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - IBAction

- (IBAction)Login:(id)sender{
    [self login];
}

- (IBAction)FacebookLogin:(id)sender{
    [self onLoginWithFacebookAccount];
}

- (IBAction)Singup:(id)sender{
    TermsOfUseVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsOfUseVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - Webservice
- (void)login{
    [SVProgressHUD show];
    
    NSString *urlString;
    
    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
        urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYEE_LOGIN];
    }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
        urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYER_LOGIN];
    }
    
    NSLog(@"%@", @{@"username": emailTxtField.text,
                   @"password": passTxtField.text,
                   @"grant_type" : @"password",
                   @"client_id": CLIENT_ID,
                   @"client_secret": CLIENT_SECRET});
   
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlString
       parameters:@{@"username": emailTxtField.text,
                    @"password": passTxtField.text,
                    @"grant_type" : @"password",
                    @"client_id": CLIENT_ID,
                    @"client_secret": CLIENT_SECRET}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"LOGIN - JSON: %@", responseObject);
              
              if (responseObject) {
                  // success in web service call return
                  NSString *token = responseObject[@"access_token"];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self getUserId:token];
                  });
                                 
                  [[AppDelegate sharedInstance].userDefaults setObject:responseObject[@"access_token"] forKey:@"token"];
                  [[AppDelegate sharedInstance].userDefaults setObject:emailTxtField.text forKey:@"email"];
                  [[AppDelegate sharedInstance].userDefaults setObject:passTxtField.text forKey:@"pass"];
                  [[AppDelegate sharedInstance].userDefaults synchronize];
                  
                  if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
                      [self performSegueWithIdentifier:@"EmployeeMode" sender:self];
                  }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
                      [self performSegueWithIdentifier:@"EmployerMode" sender:self];
                  }
              }else{
                  // failure response
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Login is failed" buttonTitle:@"Ok"];
                  });
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error.description);
              [SVProgressHUD dismiss];
              dispatch_async(dispatch_get_main_queue(), ^{
                  [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Login is failed" buttonTitle:@"Ok"];
              });
          }
     ];
}

- (void)getUserId:(NSString*)token{
    [SVProgressHUD show];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYER_GETUSERID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString
      parameters:@{@"access_token": token}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             [SVProgressHUD dismiss];
             NSLog(@"UserID - JSON: %@", responseObject);
             
             if ([responseObject[@"result"] intValue] == 1){
                 NSInteger parentId = [responseObject[@"data"] integerValue];
                 [AppDelegate sharedInstance].userId = parentId;
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[AppDelegate sharedInstance] getUserInfo];
                 });

                 dispatch_async(dispatch_get_main_queue(), ^{
                     if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
                         [[AppDelegate sharedInstance] getJobsForEmployee];
                         [[AppDelegate sharedInstance] getSavedJobs];
                     }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
                         [[AppDelegate sharedInstance] getPostedJobsByEmployer];
                     }
                 });
                 
                 [SVProgressHUD dismiss];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [SVProgressHUD dismiss];
             NSLog(@"Error: %@", error);
         }
     ];
}


#pragma mark - Facebook LOGIN
-(void)onLoginWithFacebookAccount{
//    [SVProgressHUD show];
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for(NSHTTPCookie *cookie in [storage cookies]){
        NSString *domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        
        if(domainRange.length > 0){
            [storage deleteCookie:cookie];
        }
    }
    
    NSArray *permissions = @[@"public_profile", @"email"];
    // if the session is closed, then we open it here, and establish a handler for state changes
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    //    login.loginBehavior = FBSDKLoginBehaviorNative;
    [login logOut];
    [login logInWithReadPermissions:permissions fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            [SVProgressHUD dismiss];
        } else if (result.isCancelled) {
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD dismiss];
            if ([FBSDKAccessToken currentAccessToken])
            {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email, gender, picture, first_name, last_name"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                 {
                     if (!error){
                         NSLog(@"%@",result);
                         [SVProgressHUD dismiss];
                        
                         NSString *email = [result objectForKey:@"email"];
                         if (email.length  > 0) {

                             NSString *client_id = [result objectForKey:@"id"];
                             NSString *imgURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", client_id];
                             
                             SDWebImageManager *manager = [SDWebImageManager sharedManager];
                             [manager downloadImageWithURL:[NSURL URLWithString:imgURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                 [self signupWithSocialInfo:result image:image];
                             }];

                         }
                         else{
                             [[AppDelegate sharedInstance] showAlertMessage:@"Your email is not avaiable, please config to login with this account." message:@"JOBALO" buttonTitle:@"Ok"];
                             [SVProgressHUD dismiss];
                         }
                     }
                     else{
                         [SVProgressHUD dismiss];
                     }
                 }];
            }
            else{
                NSLog(@"Not granted");
                [SVProgressHUD dismiss];
            }
        }
    }];
}

- (void)signupWithSocialInfo:(id)result image:(UIImage*)img{
    NSString *urlString, *imgPath;
    NSString *lonString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].startLocation.coordinate.longitude];
    NSString *latString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].startLocation.coordinate.latitude];
    
    // saving image as file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    imgPath = [documentsDirectory stringByAppendingPathComponent:@"profile.png"];
    NSData* data = UIImagePNGRepresentation(img);
    [data writeToFile:imgPath atomically:YES];

    
    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
        urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYER_SIGNUP];
    }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
        urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYEE_SIGNUP];
    }
    
    // save image to local path
    if (result){
        [SVProgressHUD show];
        NSURL *webImgPath = [NSURL fileURLWithPath:imgPath];
        
        NSDictionary *parameter = [NSMutableDictionary dictionaryWithDictionary:@{@"username": [result objectForKey:@"email"],
                                                                    @"password": @"facebook",
                                                                    @"image_url": webImgPath,
                                                                    @"firstname": [result objectForKey:@"first_name"],
                                                                    @"lastname": [result objectForKey:@"last_name"],
                                                                    @"description": @"None",
                                                                    @"email": [result objectForKey:@"email"],
                                                                    @"dob": @"None",
                                                                    @"latitude": latString,
                                                                    @"longitude": lonString,
                                                                    @"phone": @"None",
                                                                    @"address": @"None",
                                                                    @"user_status": @"Yes",
                                                                    @"city": @"None",
                                                                    @"state": @"None",
                                                                    @"credit_card": @"None",
                                                                    @"qbid": @"123123"}];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString
           parameters:parameter
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileURL:webImgPath name:@"image_url" error:nil];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Social SignUp - JSON: %@", responseObject);
                
                [SVProgressHUD dismiss];

                dispatch_async(dispatch_get_main_queue(), ^{
                    emailTxtField.text = [result objectForKey:@"email"];
                    passTxtField.text = @"facebook";
                    [self login];
                });

//                if ([responseObject[@"result"] intValue] == 1) {
//                    // success in web service call return
//                    [SVProgressHUD dismiss];
//                    
//                    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
//                        [self performSegueWithIdentifier:@"EmployeeMode" sender:self];
//                    }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
//                        [self performSegueWithIdentifier:@"EmployerMode" sender:self];
//                    }
//                }else{
//                    // failure response
//                    [SVProgressHUD dismiss];
//                    
////                    NSString *key = [[responseObject[@"message"] allKeys] firstObject];
////                    [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:[[responseObject[@"message"] objectForKey:key] firstObject] buttonTitle:@"Ok"];
//
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        emailTxtField.text = [result objectForKey:@"email"];
//                        passTxtField.text = @"facebook";
//                        [self login];
//                    });
//                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                [SVProgressHUD dismiss];
            }
         ];
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"Warning" message:@"No image!" buttonTitle:@"Ok"];
    }
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    //save login credential
    if (textField == emailTxtField) {
        if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
            [[AppDelegate sharedInstance].userDefaults setObject:emailTxtField.text forKey:@"EMPLOYEE_username"];
        }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
            [[AppDelegate sharedInstance].userDefaults setObject:emailTxtField.text forKey:@"EMPLOYER_username"];
        }
    }else if (textField == passTxtField) {
        if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
            [[AppDelegate sharedInstance].userDefaults setObject:passTxtField.text forKey:@"EMPLOYEE_password"];
        }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
            [[AppDelegate sharedInstance].userDefaults setObject:passTxtField.text forKey:@"EMPLOYER_password"];
        }
    }
}

@end
