//
//  QuoteDetail_SignVC.m
//  TechCall
//
//  Created by Maverics on 9/22/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "QuoteDetail_SignVC.h"
#import <PPSSignatureView/PPSSignatureView.h>
#import "AppDelegate.h"

@implementation QuoteDetail_SignVC{
    IBOutlet UILabel *addressLabel, *termsLabel, *IDLabel, *amountLabel;
    IBOutlet UITextField *signedByField;
    IBOutlet PPSSignatureView *signView;
    IBOutlet UIImageView *signImgView;
    
    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(Save:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    [self setupUIContent];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)setupUIContent{
    self.title = @"Quote Signature";
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];
    
    NSString *title = [NSString stringWithFormat:@"%@ %@ %@",
                       [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Id"],
                       [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"DisplayName"],
                       [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Address"][@"Line1"]];
    addressLabel.text = title;
    addressLabel.font = contentFont;
    
//    NSDictionary *signObject = self.quoteObject[@"Signature"];
//    signedByField.text = signObject[@"SignedBy"];
//    amountLabel.text = [self.quoteObject[@"Total"] stringValue];
//    IDLabel.text = self.quoteObject[@"Id"];
//    
//    NSString *imgDataString = signObject[@"Image"];
//    NSData *imgData = [[NSData alloc] initWithBase64EncodedString:imgDataString options:0];
//    UIImage *signImage = [UIImage imageWithData:imgData];
//
//    signImgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    signImgView.image = signImage;
    
}

#pragma mark - IBAction

- (IBAction)Save:(id)sender{
    [self SDCreateSignature];
}

- (IBAction)ClearSign:(id)sender{
    [signView erase];
}


#pragma mark - Webservice

- (void)SDCreateSignature{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    //115
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, INVOICE_SIGNATURE];
    
    //parameter data
    NSLog(@"%@", [AppDelegate sharedInstance].currentInfo[@"Call"]);
    
    NSInteger seqNo = [[AppDelegate sharedInstance].currentInfo[@"Sequence"] integerValue];
    NSInteger callNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"] integerValue];
    NSInteger invoiceNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"][@"Id"] integerValue];

    //signature image data
    NSData *imageData = UIImageJPEGRepresentation(signView.signatureImage, 1.0);
    NSString *encodedString = [imageData base64Encoding];
    
    NSDictionary *signDict = @{@"SignedBy": self.quoteObject[@"Signature"][@"SignedBy"],
                               @"Signature": encodedString};
    NSDictionary *invoiceDict = @{@"Id": [NSNumber numberWithInteger:invoiceNo],
                                   @"Signature": signDict};
    NSDictionary *callDict = @{@"ID": [NSNumber numberWithInteger:callNo],
                               @"Invoice": invoiceDict};
    NSDictionary *param = @{@"Sequence": [NSNumber numberWithInteger:seqNo],
                            @"Call": callDict};
    NSLog(@"param = %@", param);
    
    [manager POST:urlString
       parameters:param
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [SVProgressHUD dismiss];
              
              if (responseObject) {
                  // success in web service call return
                  [[AppDelegate sharedInstance] showAlertMessage:@"Ok" message:@"Updated" buttonTitle:@"Ok"];
              }else{
                  // failure response
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }
     ];
}

@end
