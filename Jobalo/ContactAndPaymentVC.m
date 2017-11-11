//
//  ContactAndPaymentVC.m
//  Jobalo
//
//  Created by Maverics on 9/13/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "ContactAndPaymentVC.h"
#import "AppDelegate.h"

@implementation ContactAndPaymentVC{
    IBOutlet UITextField *addressTxtField, *phoneTxtField, *emailTxtField, *paypalTxtField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadInformation];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavigationBar];
}

- (void)setupNavigationBar{
    self.title = @"Contact and Payment";
    
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

    // Right button
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(Update:)];
    [rightItem setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)loadInformation{
    if (![AppDelegate sharedInstance].paymentInfo){
        [AppDelegate sharedInstance].paymentInfo = [[NSMutableDictionary alloc] init];
    }

    
    NSString *sep = @"&&&&";
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:sep];
    NSArray *temp = [[AppDelegate sharedInstance].userInfo[@"credit_card"] componentsSeparatedByCharactersInSet:set];
    
    if (temp && temp.count > 3) {
        emailTxtField.text = temp[0];
        phoneTxtField.text = temp[1];
        addressTxtField.text = temp[2];
        paypalTxtField.text = temp[3];
    }
}

#pragma mark - IBAction

- (IBAction)Update:(id)sender{
    if (![AppDelegate sharedInstance].paymentInfo)
        [AppDelegate sharedInstance].paymentInfo = [[NSMutableDictionary alloc] init];

    if ([emailTxtField.text isEqualToString:@""])
        [[AppDelegate sharedInstance].paymentInfo setObject:@"n/a" forKey:@"email"];
    else
        [[AppDelegate sharedInstance].paymentInfo setObject:emailTxtField.text forKey:@"email"];

    if ([phoneTxtField.text isEqualToString:@""])
        [[AppDelegate sharedInstance].paymentInfo setObject:@"n/a" forKey:@"phone"];
    else
        [[AppDelegate sharedInstance].paymentInfo setObject:phoneTxtField.text forKey:@"phone"];
    
    if ([addressTxtField.text isEqualToString:@""])
        [[AppDelegate sharedInstance].paymentInfo setObject:@"n/a" forKey:@"address"];
    else
        [[AppDelegate sharedInstance].paymentInfo setObject:addressTxtField.text forKey:@"address"];
    
    if ([paypalTxtField.text isEqualToString:@""])
        [[AppDelegate sharedInstance].paymentInfo setObject:@"n/a" forKey:@"paypal"];
    else
        [[AppDelegate sharedInstance].paymentInfo setObject:paypalTxtField.text forKey:@"paypal"];
    
    [self updateProfile];
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Webservice

- (void)getMe{
    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/babysitter/%lu", BASIC_URL, userId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString
      parameters:@{@"access_token": token}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             
             if ([responseObject[@"result"] intValue] == 1) {
                 [AppDelegate sharedInstance].userInfo = responseObject[@"data"];
                 [self.navigationController popViewControllerAnimated:YES];
             }else{
                 
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }
     ];
}

- (void)updateProfile{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];

    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/babysitter/%lu", BASIC_URL, (long)userId];
    
    [param setObject:token forKey:@"access_token"];
    
    if ([AppDelegate sharedInstance].paymentInfo) {
        NSString *paymentInfo = [NSString stringWithFormat:@"%@&%@&%@&%@",
                                 [AppDelegate sharedInstance].paymentInfo[@"email"],
                                 [AppDelegate sharedInstance].paymentInfo[@"phone"],
                                 [AppDelegate sharedInstance].paymentInfo[@"address"],
                                 [AppDelegate sharedInstance].paymentInfo[@"paypal"]];
        [param setObject:paymentInfo forKey:@"credit_card"];

        [manager POST:urlString parameters:param
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"JSON: %@", responseObject);
                  
                  if ([responseObject[@"result"] intValue] == 1){
                      // success in web service call return
                      [[AppDelegate sharedInstance] showAlertMessage:@"Success" message:responseObject[@"message"] buttonTitle:@"Ok"];
                      [self getMe];
                  }else{
                      // failure response
                      NSString *key = [[responseObject[@"message"] allKeys] firstObject];
                      [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:[[responseObject[@"message"] objectForKey:key] firstObject] buttonTitle:@"Ok"];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
                  [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Profile update is failed" buttonTitle:@"Ok"];
              }
         ];
    }
}

@end
