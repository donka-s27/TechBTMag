//
//  EmployeeProfileVC.m
//  Jobalo
//
//  Created by Maverics on 8/20/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "EmployeeProfileVC.h"
#import <UIImage+BlurredFrame/UIImage+BlurredFrame.h>
#import "AppDelegate.h"
#import "DetailTextVC.h"
#import "ContactAndPaymentVC.h"

#define CONTENT_SIZE 750
@interface EmployeeProfileVC (){
    IBOutlet UIImageView *headerImgView, *thumbImgView;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIScrollView *contentScrView;
    IBOutlet UITextView *bioTxtView, *descTxtView;
    IBOutlet UITableView *infoTblView;
}

@end

@implementation EmployeeProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileInfoItems = [[NSMutableArray alloc] initWithObjects:@"PAST WORK", @"COMPANY / NAME", @"DATE WORKED", nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupHeaderView];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self setupNavigationBar];
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

- (void)setupNavigationBar{
    self.title = @"Profile";
    
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
    
    // Right button
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(Update:)];
    [rightItem setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setupHeaderView{
    //thumbnail-photo imageview circle
    CALayer *roundRect = [thumbImgView layer];
    [roundRect setCornerRadius:thumbImgView.frame.size.width / 2];
    [roundRect setMasksToBounds:YES];
    
    CGRect borderFrame = CGRectMake(thumbImgView.frame.origin.x, thumbImgView.frame.origin.y, (thumbImgView.frame.size.width), (thumbImgView.frame.size.height));
    [roundRect setBackgroundColor:[[UIColor clearColor] CGColor]];
    [roundRect setFrame:borderFrame];
    [roundRect setBorderWidth:9.0f];
    [roundRect setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    // profile photo
    NSString *photoUrl = [AppDelegate sharedInstance].userInfo[@"image_url"];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [photoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:result] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [SVProgressHUD dismiss];
        
        thumbImgView.image = image;
        
        //blur background view
        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
        UIImage *img = [image applyLightEffectAtFrame:frame];
        headerImgView.image = img;
    }];
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@",
                                            [AppDelegate sharedInstance].userInfo[@"firstname"],
                                            [AppDelegate sharedInstance].userInfo[@"lastname"]];
    nameLabel.text = fullName;
}

- (void)setupUI{
    [contentScrView setPagingEnabled:NO];
    [contentScrView setScrollEnabled:YES];
    [contentScrView setContentSize:CGSizeMake(1.0, CONTENT_SIZE)];
    
    bioTxtView.text = [AppDelegate sharedInstance].userInfo[@"description"];
}

#pragma mark IBAction

- (IBAction)Update:(id)sender{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:descTxtView.text forKey:@"phone"];
    [self updateProfile:param];
}

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)ContactAndPayment:(id)sender{
    ContactAndPaymentVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactAndPaymentVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)AddPhoto:(id)sender{
    self.cameraActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:@"Camera"
                                                otherButtonTitles:@"Photo Album", nil];
    
    // Show the actionsheet
    [self.cameraActionSheet showInView:self.view];
}

# pragma mark - getPicture
-(void)getPicture {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)getCamera {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)checkForCamera{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"Device has no camera" buttonTitle:@"OK"] ;
    }else{
        [self getCamera];
    }
}

# pragma mark - UIImagePickerController Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imgToUpload = info[UIImagePickerControllerOriginalImage];
    [thumbImgView setImage:_imgToUpload];
    
    //    // saving image as file
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    imagePath = [documentsDirectory stringByAppendingPathComponent:@"profile.png"];
    //    NSData* data = UIImagePNGRepresentation(_imgToUpload);
    //    [data writeToFile:imagePath atomically:YES];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == _cameraActionSheet){
        switch (buttonIndex) {
            case 0:
                // launch camera
                [self checkForCamera];
                break;
            case 1:
                // load photo album
                [self getPicture];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Webservice

- (void)updateProfile:(NSMutableDictionary*)param{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/babysitter/%lu", BASIC_URL, (long)userId];
    
    [param setObject:token forKey:@"access_token"];
    if (![bioTxtView.text isEqualToString:[AppDelegate sharedInstance].userInfo[@"description"]]) {
        [param setObject:bioTxtView.text forKey:@"description"];
    }
    
    if (self.imgToUpload) {
        // saving image as file
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:@"profile.png"];
        NSData* data = UIImagePNGRepresentation(_imgToUpload);
        [data writeToFile:imgPath atomically:YES];
        NSURL *finalURL = [NSURL fileURLWithPath:imgPath];
        
        [param setObject:finalURL forKey:@"image_url"];
        
        [manager POST:urlString parameters:param
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileURL:finalURL name:@"image_url" error:nil];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                
                if ([responseObject[@"result"] intValue] == 1) {
                    // success in web service call return
                    [[AppDelegate sharedInstance] showAlertMessage:@"Success" message:responseObject[@"message"] buttonTitle:@"Ok"];
                    
                    [self getMe];
                }else{
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
    }else{
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

#pragma mark - UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITableView Delegate & Datasource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        DetailTextVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTextVC"];
        dest.keyword = @"pastwork";
        dest.textContent = [AppDelegate sharedInstance].userInfo[@"phone"];
        [self.navigationController pushViewController:dest animated:YES];
    }else if (indexPath.row == 1) {
        DetailTextVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTextVC"];
        dest.keyword = @"company";
        dest.textContent = [AppDelegate sharedInstance].userInfo[@"address"];
        [self.navigationController pushViewController:dest animated:YES];
    }else if (indexPath.row == 2) {
        DetailTextVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTextVC"];
        dest.keyword = @"dateworked";
        dest.textContent = [AppDelegate sharedInstance].userInfo[@"city"];
        [self.navigationController pushViewController:dest animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.profileInfoItems.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cell_ID = @"profileInfoCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cell_ID];
    cell.textLabel.text = self.profileInfoItems[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


@end
