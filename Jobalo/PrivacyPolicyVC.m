//
//  PrivacyPolicyVC.m
//  Jobalo
//
//  Created by Maverics on 9/20/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "PrivacyPolicyVC.h"
#import "SignupVC.h"

@implementation PrivacyPolicyVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PrivacyPolicy" ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.contentWebView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"Privacy Policy";
}

- (IBAction)Accept:(id)sender{
    SignupVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"SignupVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Decline:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
