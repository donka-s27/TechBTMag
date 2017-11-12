//
//  DocumentDetailVC.m
//  TechCall
//
//  Created by Maverics on 9/22/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "DocumentDetailVC.h"
#import "AppDelegate.h"
#import "UIImage+PDF.h"

@implementation DocumentDetailVC{
    IBOutlet UIImageView *docImgView;
    IBOutlet UILabel *titleLabel;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self SDCallDocument];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)SDCallDocument{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    NSLog(@"token -------- %@", [AppDelegate sharedInstance].token);
    
    NSInteger callNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"] integerValue];
    NSInteger docID = [self.dataObject[@"Id"] integerValue];

    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALL_DOCUMENT];
    [manager GET:urlString
      parameters:@{@"CallNumber": [NSNumber numberWithInteger:callNo],
                   @"DocId": [NSNumber numberWithInteger:docID]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.title = responseObject[@"Name"];
                 titleLabel.text = responseObject[@"FileName"];
                 
                 NSString *imgDataString = responseObject[@"File"];
                 NSData *dataImage = [[NSData alloc] initWithBase64EncodedString:imgDataString options:0];
                 UIImage *image = [UIImage originalSizeImageWithPDFData:dataImage];
                 
                 docImgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                 docImgView.image = image;
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

@end
