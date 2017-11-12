//
//  QuoteDetail_PictureVC.m
//  TechCall
//
//  Created by Maverics on 9/22/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "QuoteDetail_PictureVC.h"
#import "AppDelegate.h"

@implementation QuoteDetail_PictureVC{
    IBOutlet UIImageView *imgView;
    
    NSArray *imageInformation;
    NSInteger imageIndex;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Call Pictures";
    
//    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(AddQuoteDetail:)];
//    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    [self SDCallPictures];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - IBAction
- (IBAction)NextImage:(id)sender{
    if (imageIndex < imageInformation.count - 1) {
        imageIndex ++;
        
        NSDictionary *imgDict = imageInformation[imageIndex];
        NSString *imgDataString = imgDict[@"Image"];
        NSData *dataImage = [[NSData alloc] initWithBase64EncodedString:imgDataString options:0];
        UIImage *image = [UIImage imageWithData:dataImage];
        
        imgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        imgView.image = image;
    }
}

- (IBAction)BackImage:(id)sender{
    if (imageIndex > 0) {
        imageIndex --;
        
        NSDictionary *imgDict = imageInformation[imageIndex];
        NSString *imgDataString = imgDict[@"Image"];
        NSData *dataImage = [[NSData alloc] initWithBase64EncodedString:imgDataString options:0];
        UIImage *image = [UIImage imageWithData:dataImage];
        
        imgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        imgView.image = image;
    }
}

#pragma mark - Webservice

- (void)SDCallPictures{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSInteger callNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"] integerValue];  //115
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALL_PICTURE];
    [manager GET:urlString
      parameters:@{@"CallNumber": [NSNumber numberWithInteger:callNo]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 imageInformation = (NSArray*)responseObject;
                 
                 NSDictionary *firstImage = [imageInformation firstObject];
                 imageIndex = 0;
                 
                 NSString *imgDataString = firstImage[@"Image"];
                 NSData *dataImage = [[NSData alloc] initWithBase64EncodedString:imgDataString options:0];
                 UIImage *image = [UIImage imageWithData:dataImage];
                 
                 imgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                 imgView.image = image;
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
