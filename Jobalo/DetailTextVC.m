//
//  DetailTextVC.m
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "DetailTextVC.h"
#import "AppDelegate.h"

@interface DetailTextVC (){
    IBOutlet UITextView *txtView;
}

@end

@implementation DetailTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    txtView.text = self.textContent;
    
    if (self.keyword == NULL || [self.keyword isEqualToString:@""]){
        txtView.editable = NO;
        
    }else{
        // Right button
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(Update:)];
        [rightItem setTintColor:[UIColor darkGrayColor]];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Update:(id)sender{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    if ([self.keyword isEqualToString:@"pastwork"]) {
        [param setObject:txtView.text forKey:@"phone"];
    } else if ([self.keyword isEqualToString:@"company"]) {
        [param setObject:txtView.text forKey:@"address"];
    } else if ([self.keyword isEqualToString:@"dateworked"]) {
        [param setObject:txtView.text forKey:@"city"];
    }
    
    [self updateProfile:param];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    return YES;
}

- (void)updateProfile:(NSMutableDictionary*)param{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/babysitter/%lu", BASIC_URL, (long)userId];

    [param setObject:token forKey:@"access_token"];

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
              [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Job posting is failed" buttonTitle:@"Ok"];
          }
     ];

}

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

@end
