//
//  SignupVC.m
//  Jobalo
//
//  Created by Maverics on 8/30/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "SignupVC.h"
#import "AppDelegate.h"
#define CONTENT_SIZE 750

@implementation SignupVC{
    IBOutlet UIScrollView *contentScrView;
    IBOutlet UIView *datePickerView;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UITextField *emailTxtField, *passTxtField, *fstNameTxtField, *lstNameTxtField, *titleTxtField;
    IBOutlet UILabel *descLabel;
    IBOutlet UITextView *descTxtView;
    IBOutlet UIButton *dateBtn, *profileBtn;
    IBOutlet UIImageView *imgView;

    UIImagePickerController *imgPickerCtrl;
    UIActionSheet *actionSheet;
    NSString *imgFilePath, *dateString;
    
    NSMutableDictionary *parameter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews{
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)setupUI{
    [contentScrView setPagingEnabled:NO];
    [contentScrView setScrollEnabled:YES];
    [contentScrView setContentSize:CGSizeMake(1.0, CONTENT_SIZE)];
    
//    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
//        [descLabel setHidden:YES];
//        [descTxtView setHidden:YES];
//    }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
//        [descLabel setHidden:NO];
//        [descTxtView setHidden:NO];
//    }
    
    descTxtView.layer.cornerRadius = 5.0;
    descTxtView.layer.borderWidth = 1.2;
    descTxtView.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)setupNavigationBar{
    // Unhide the navigation bar
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    // Navbar color
    [self.navigationController.navigationBar setAlpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor groupTableViewBackgroundColor];
    
    // Adjust nav bar title based on current view identifier
    self.navigationController.navigationBar.topItem.title = @"SignUp";
    
    // Nabvar title tine color
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:[UIColor grayColor],
                                                                      NSFontAttributeName:[UIFont boldSystemFontOfSize:22.0f]
                                                                      }];
    
    // left button
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"logoMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(ToggleMenu:)];
    [leftItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark - IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)AddPhoto:(id)sender{
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera" otherButtonTitles:@"Photo Album", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)SignUpNow:(id)sender{
    [self signup];
}

- (IBAction)ShowDatePicker:(id)sender{
    [datePickerView setHidden:NO];
}

- (IBAction)OkDateSetting:(id)sender{
    dateString = [[AppDelegate sharedInstance] changeDateFormat:datePicker.date format:@"MM/dd/yyyy"];
    [dateBtn setTitle:dateString forState:UIControlStateNormal];
    [datePickerView setHidden:YES];
}

- (IBAction)CancelDateSetting:(id)sender{
    [datePickerView setHidden:YES];
}

#pragma mark - Webservice
- (void)signup{
    NSString *urlString;
    NSString *lonString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].startLocation.coordinate.longitude];
    NSString *latString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].startLocation.coordinate.latitude];

    // saving image as file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    imgFilePath = [documentsDirectory stringByAppendingPathComponent:@"profile.png"];
    NSData* data = UIImagePNGRepresentation(imgView.image);
    [data writeToFile:imgFilePath atomically:YES];

    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
        urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYER_SIGNUP];
    }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
        urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYEE_SIGNUP];
    }
    
    // save image to local path
    if (imgFilePath && emailTxtField.text && passTxtField.text){
        [SVProgressHUD show];
        NSURL *filePath = [NSURL fileURLWithPath:imgFilePath];
        
        parameter = [NSMutableDictionary dictionaryWithDictionary:@{@"username": emailTxtField.text,
                                                                    @"password": passTxtField.text,
                                                                    @"image_url": filePath,
                                                                    @"firstname": fstNameTxtField.text,
                                                                    @"lastname": lstNameTxtField.text,
                                                                    @"email": emailTxtField.text,
                                                                    @"dob": dateString,
                                                                    @"latitude": latString,
                                                                    @"longitude": lonString,
                                                                    @"description": descTxtView.text,                                                                    
                                                                    @"qbid": titleTxtField.text,
                                                                    @"phone": @"None",
                                                                    @"address": @"None",
                                                                    @"user_status": @"Yes",
                                                                    @"city": @"None",
                                                                    @"state": @"None",
                                                                    @"credit_card": @"None"}];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:urlString
           parameters:parameter
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileURL:filePath name:@"image_url" error:nil];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"SignUp - JSON: %@", responseObject);
                
                if ([responseObject[@"result"] intValue] == 1) {
                    // success in web service call return
                    [SVProgressHUD dismiss];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Successfully signed up" buttonTitle:@"Ok"];
                    });
                }else{
                    // failure response
                    [SVProgressHUD dismiss];
                    NSString *key = [[responseObject[@"message"] allKeys] firstObject];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:[[responseObject[@"message"] objectForKey:key] firstObject] buttonTitle:@"Ok"];
                    });
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                [SVProgressHUD dismiss];
            }
         ];
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"Warning" message:@"No image!" buttonTitle:@"Ok"];
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    imgPickerCtrl = [[UIImagePickerController alloc] init];
    imgPickerCtrl.delegate = self;
    
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera]) {
            imgPickerCtrl.allowsEditing = NO;
            imgPickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera ;
            imgPickerCtrl.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            imgPickerCtrl.showsCameraControls = YES;
        }
        [self presentViewController:imgPickerCtrl animated:YES completion:Nil];
    }else if(buttonIndex == 1){
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            imgPickerCtrl.allowsEditing = NO;
            imgPickerCtrl.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        [self presentViewController:imgPickerCtrl animated:YES completion:Nil];
    }else{
        
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - UIImagePickerController Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    imgView.image = image;
    imgView.layer.cornerRadius = imgView.frame.size.width / 2;
    imgView.layer.masksToBounds = YES;
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    // Unable to save the image
    if (error)
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Unable to save image to Photo Album." buttonTitle:@"OK"];
    else // All is well
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"Image saved to Photo Album." buttonTitle:@"OK"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [imgPickerCtrl dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [datePickerView setHidden:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

#pragma mark - UITextView delegate methods
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [datePickerView setHidden:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
