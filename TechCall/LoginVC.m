//
//  LoginVC.m
//  TechCall
//
//  Created by Maverics on 8/17/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "LoginVC.h"
#import "AppDelegate.h"

@interface LoginVC ()<UITextFieldDelegate>{
    IBOutlet UITextField *idTextField, *passTextField, *ipTextField;
    IBOutlet UIView *ipAddressView;
}

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [[AppDelegate sharedInstance] setLocationManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI{
    self.title = @"Sign in";
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Server Address" style:UIBarButtonItemStylePlain target:self action:@selector(ServerAddress:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    idTextField.text = @"heatherv3";
    passTextField.text = @"abc1234";
    ipTextField.text = @"https://www.saimobile2.com:291";
    [AppDelegate sharedInstance].ipAddress = ipTextField.text;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"LOGIN"]) {

    }
}

#pragma mark - IBAction

- (IBAction)Login:(id)sender{
    [self login];
}

- (IBAction)ServerAddress:(id)sender{
    [ipAddressView setHidden:NO];
}

- (IBAction)SetIPAddress:(id)sender{
    [ipAddressView setHidden:YES];
    [ipTextField resignFirstResponder];
    [AppDelegate sharedInstance].ipAddress = ipTextField.text;
}

- (IBAction)CancelIPAddress:(id)sender{
    [ipAddressView setHidden:YES];
    [ipTextField resignFirstResponder];
}

#pragma mark - Webservice

- (void)login{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/App/Token", BASIC_URL];
    
    //heatherv2?pPassword=may1234
    [manager POST:urlString
       parameters:@{@"pUser": idTextField.text,
                    @"pPwd": passTextField.text}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [SVProgressHUD dismiss];
              
              if ([responseObject[@"CompanyName"] isEqualToString:@"Test Company"]) {
                  // success in web service call return
                  [AppDelegate sharedInstance].token = responseObject[@"Token"];
                  
                  [[AppDelegate sharedInstance] SDTechCalls:[AppDelegate sharedInstance].currentDate];
                  [[AppDelegate sharedInstance] SDSetup];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveDataToLocal" object:self];

                  [[AppDelegate sharedInstance] TechLocationUpdate:[AppDelegate sharedInstance].startLocation.coordinate.latitude
                                 longitude:[AppDelegate sharedInstance].startLocation.coordinate.longitude];

                  [self performSegueWithIdentifier:@"LOGIN" sender:self];
              }else{
                  // failure response
                  
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }
     ];
}

#pragma mark - UITextField & UITextView Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField != ipTextField)
        [self keyboardWillShow];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField != ipTextField)
        [self keyboardWillHide];
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
