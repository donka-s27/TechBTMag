//
//  PostJobVC.m
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "PostJobVC.h"
#define CONTENT_SIZE 710
//#define kOFFSET_KEYBOARD 150

@interface PostJobVC (){
    UIImagePickerController *imgPickerCtrl;
    UIActionSheet *actionSheet;
    NSString *ageSelKey, *ageFrom, *ageTo, *contractType;
    
    IBOutlet UIScrollView *contentScrView;
    IBOutlet UIImageView *imgView;
    IBOutlet UITextField *titleField, *wageField, *fromAgeField, *toAgeField;
    IBOutlet UIButton *ageFromBtn, *ageToBtn;
    IBOutlet UIButton *contractBtn, *partTimeBtn, *fullTimeBtn;
    IBOutlet UITextView *addressTxtView, *descTxtView;

    IBOutlet UIView *viewDatePicker;
    IBOutlet UIDatePicker *datePicker;
}

@end

@implementation PostJobVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews{
    [self setupUI];
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
    [contentScrView setPagingEnabled:NO];
    [contentScrView setScrollEnabled:YES];
    [contentScrView setContentSize:CGSizeMake(1.0, CONTENT_SIZE)];
    
    // Set photo view
    CALayer *roundRect = [imgView layer];
    [roundRect setCornerRadius:imgView.frame.size.width / 2];
    [roundRect setMasksToBounds:YES];

    NSString *photoUrl = [AppDelegate sharedInstance].userInfo[@"image_url"];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [photoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:result] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [SVProgressHUD dismiss];
        
        imgView.image = image;
    }];
}

#pragma mark - IBAction 

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)AddPhoto:(id)sender{
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera" otherButtonTitles:@"Photo Album", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)PostIt:(id)sender{
    [self postJob];
}

//- (IBAction)AgeFrom:(id)sender{
//    ageSelKey = @"From";
//    [viewDatePicker setHidden:NO];
//}

//- (IBAction)AgeTo:(id)sender{
//    ageSelKey = @"To";
//    [viewDatePicker setHidden:NO];
//}

//- (IBAction)DoneDatePicker:(id)sender{
//    //Result setting into date-button
//    NSString *dateString = [[AppDelegate sharedInstance] changeDateFormat:datePicker.date format:@"MM/dd/yyyy"];
//    if ([ageSelKey isEqualToString:@"From"]) {
//        ageFrom = dateString;
//        [ageFromBtn setTitle:dateString forState:UIControlStateNormal];
//    }else if ([ageSelKey isEqualToString:@"To"]) {
//        ageTo = dateString;
//        [ageToBtn setTitle:dateString forState:UIControlStateNormal];
//    }
//    ageSelKey = @"";
//
//    //UI process
//    [viewDatePicker setHidden:YES];
//    
//    [titleField resignFirstResponder];
//    [wageField resignFirstResponder];
//    [descTxtView resignFirstResponder];
//    [addressTxtView resignFirstResponder];
//    
//    [self keyboardWillHide];
//}

- (IBAction)CancelDatePicker:(id)sender{
    ageSelKey = @"";
    
    //UI process
    [viewDatePicker setHidden:YES];
    
    [titleField resignFirstResponder];
    [wageField resignFirstResponder];
    [descTxtView resignFirstResponder];
    [addressTxtView resignFirstResponder];
    
    [self keyboardWillHide];
}

#pragma mark JOB FILTER
- (IBAction)Contract:(UIButton*)sender{
    contractType = @"contract";
    
    [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [partTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [fullTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

- (IBAction)PartTime:(UIButton*)sender{
    contractType = @"parttime";
    
    [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [contractBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [fullTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

- (IBAction)FullTime:(UIButton*)sender{
    contractType = @"fulltime";
    
    [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [contractBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [partTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

#pragma mark - Webservice

- (void)postJob{
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *lonString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].postLocation.coordinate.longitude];
    NSString *latString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].postLocation.coordinate.latitude];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EMPLOYER_JOB];
    
    if ((titleField.text.length == 0) ||
        (wageField.text.length == 0) ||
        (descTxtView.text.length == 0) ||
        (addressTxtView.text.length == 0) ||
        contractType == nil ||
        fromAgeField.text == nil ||
        toAgeField.text == nil ||
        imgView.image == nil){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Please fill out the information." buttonTitle:@"Ok"];
        });
    }else{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSLog(@"jobs = %@", @{@"access_token": token,
                       @"parent_id": [NSString stringWithFormat:@"%lu", (long)[AppDelegate sharedInstance].userId],
                       @"title": titleField.text,
                       @"price": [wageField.text substringFromIndex:1],
                       @"description": descTxtView.text,
                       @"start_time": fromAgeField.text,
                       @"deadline": toAgeField.text,
                       @"latitude": latString,
                       @"longitude": lonString,
                       @"location": addressTxtView.text,
                       @"price_type": contractType});
        
        [manager POST:urlString
           parameters:@{@"access_token": token,
                        @"parent_id": [NSString stringWithFormat:@"%lu", (long)[AppDelegate sharedInstance].userId],
                        @"title": titleField.text,
                        @"price": [wageField.text substringFromIndex:1],
                        @"description": descTxtView.text,
                        @"start_time": fromAgeField.text,
                        @"deadline": toAgeField.text,
                        @"latitude": latString,
                        @"longitude": lonString,
                        @"location": addressTxtView.text,
                        @"price_type": contractType}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"Job Posted - JSON: %@", responseObject);
                  
                  if ([responseObject[@"result"] intValue] == 1){
                      // success in web service call return
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [[AppDelegate sharedInstance] showAlertMessage:@"Success" message:responseObject[@"message"] buttonTitle:@"Ok"];
                          [[AppDelegate sharedInstance] getPostedJobsByEmployer];
                      });
                  }else{
                      // failure response
                      NSString *key = [[responseObject[@"message"] allKeys] firstObject];
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:[[responseObject[@"message"] objectForKey:key] firstObject] buttonTitle:@"Ok"];
                      });
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Job posting is failed" buttonTitle:@"Ok"];
                  });
              }
         ];
    }
}

#pragma mark - UITextField & UITextView Delegate
// Set the currency symbol if the text field is blank when we start to edit.
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == titleField) {
        
    }else{
        if (textField == wageField) {
            if (textField.text.length  == 0){
                textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
            }
        }

        [self keyboardWillShow];
    }
    [viewDatePicker setHidden:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == wageField) {
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
    if (textField == titleField) {
        
    }else{
        [self keyboardWillHide];
    }
    [textField resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self keyboardWillShow];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView == addressTxtView) {
        [[AppDelegate sharedInstance] geoCodeConvert:addressTxtView.text];
    }
    
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

@end
