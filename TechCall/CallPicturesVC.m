//
//  CallPicturesVC.m
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "CallPicturesVC.h"
#import "PictureDetailVC.h"
#import "AppDelegate.h"

@implementation UIImage (Extended)

- (NSString *)base64String {
    NSData * data = [UIImagePNGRepresentation(self) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithUTF8String:[data bytes]];
}
@end


@implementation CallPicturesVC{
    UIImagePickerController *imgPickerCtrl;

    IBOutlet UITableView *callPicturesTblView;
    IBOutlet UIView *addPictureView;
    IBOutlet UITextField *pictDescTxtField;
}

- (void)viewDidLoad{
    [self SDGetCallPictures];
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(AddPicture:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;

    pictDescTxtField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    
}

#pragma mark - IBAction
- (IBAction)SetPictureDescription:(id)sender{
    [addPictureView setHidden:YES];
    [self displayAlertView];
}

- (IBAction)CancelPictureDescription:(id)sender{
    [addPictureView setHidden:YES];
}

- (void)AddPicture:(UIButton*)sender{
    [addPictureView setHidden:NO];
}

- (void)displayAlertView{
    imgPickerCtrl = [[UIImagePickerController alloc] init];
    imgPickerCtrl.delegate = self;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Add CallPicture"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *button1 = [UIAlertAction actionWithTitle:@"Load Photo" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        if ([UIImagePickerController isSourceTypeAvailable:
                                                             UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                                                            imgPickerCtrl.allowsEditing = NO;
                                                            imgPickerCtrl.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                                                        }
                                                        [self presentViewController:imgPickerCtrl animated:YES completion:Nil];
                                                    }];
    UIAlertAction *button2 = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        if ([UIImagePickerController isSourceTypeAvailable:
                                                             UIImagePickerControllerSourceTypeCamera]) {
                                                            imgPickerCtrl.allowsEditing = NO;
                                                            imgPickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera ;
                                                            imgPickerCtrl.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
                                                            imgPickerCtrl.showsCameraControls = YES;
                                                        }
                                                        [self presentViewController:imgPickerCtrl animated:YES completion:Nil];
                                                    }];
    UIAlertAction *button3 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                    }];
    [alert addAction:button1];
    [alert addAction:button2];
    [alert addAction:button3];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    NSString *imgDataString = [image base64String];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *encodedString = [imageData base64Encoding];
    NSLog(@"%@", encodedString);
    
    [self dismissViewControllerAnimated:YES completion:Nil];
    
    [self updateCallPicture:encodedString];
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

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.callPictList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"callPictCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSDictionary *callPictObject = self.callPictList[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", callPictObject[@"Description"]];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //alternate background color
    if( [indexPath row] % 2)
        [cell setBackgroundColor:[UIColor whiteColor]];
    else
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PictureDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"PictureDetailVC"];
    dest.pictureInfo = self.callPictList[indexPath.row];
    [self.navigationController pushViewController:dest animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self SDDeleteCallPict:indexPath.row];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Webservice
- (void)updateCallPicture:(NSString*)imgDataString{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALL_PICTURE];
    NSDictionary *tempDict = @{@"CallMaster": @{@"Id" :[AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"]},
                               @"Sequence": @"-1",
                               @"Description": pictDescTxtField.text,
                               @"Image": imgDataString};
    NSLog(@"update param = %@", tempDict);
    
    [manager POST:urlString
      parameters:tempDict
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 [[AppDelegate sharedInstance] showAlertMessage:@"Ok" message:@"Updated" buttonTitle:@"Ok"];
                 [self SDGetCallPictures];
             }else{
                 // failure response
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
         }
     ];
}

- (void)SDGetCallPictures{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSInteger callNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALL_PICTURE];
    [manager GET:urlString
      parameters:@{@"CallNumber": [NSNumber numberWithInteger:callNo]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.callPictList = (NSMutableArray*)responseObject;
                 [callPicturesTblView reloadData];
             }else{
                 // failure response
                 [SVProgressHUD dismiss];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
         }
     ];
}

- (void)SDDeleteCallPict:(NSInteger)index{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *callPictObject = self.callPictList[index];
    NSInteger callMasterNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"] integerValue];
    NSInteger seqNo = [callPictObject[@"Sequence"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALL_PICTURE];
    
    [manager DELETE:urlString
         parameters:@{@"CallMasterId": [NSNumber numberWithInteger:callMasterNo],
                      @"Sequence": [NSNumber numberWithInteger:seqNo]}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                [SVProgressHUD dismiss];
                
                if (responseObject) {
                    // success in web service call return
                    NSMutableArray *tempList = [self.callPictList mutableCopy];
                    [tempList removeObjectAtIndex:index];
                    self.callPictList = tempList;

                    [callPicturesTblView reloadData];
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
