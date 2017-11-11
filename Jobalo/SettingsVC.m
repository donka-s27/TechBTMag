//
//  SettingsVC.m
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC (){
    IBOutlet UISwitch *notifSwitch;
}
@end

@implementation SettingsVC

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

#pragma mark IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)DeleteAccount:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DELETE ACCOUNT"
                                                                   message:@"Are you sure to delete the account?"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: @"Yes"
                                                            style: UIAlertActionStyleDefault
                                                          handler: ^(UIAlertAction *action){
                                                              [self DeleteAccount];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"No"
                                                           style: UIAlertActionStyleDefault
                                                         handler: ^(UIAlertAction *action){
                                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
    [alert addAction: defaultAction];
    [alert addAction: cancelAction];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController: alert animated: YES completion: nil];

}

- (IBAction)NotificationSetting:(id)sender{
    if (notifSwitch.on) {
        
    }else{
        
    }
}

#pragma mark - Webservice
- (void)DeleteAccount{
    [SVProgressHUD show];
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSInteger userId = [[AppDelegate sharedInstance].userInfo[@"user_id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%lu", BASIC_URL, USER ,userId];
    
    [manager DELETE:urlString
         parameters:@{@"access_token": token}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                [SVProgressHUD dismiss];
                
                if (responseObject) {
                    // success in web service call return
                    [self.navigationController popToRootViewControllerAnimated:YES];
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
