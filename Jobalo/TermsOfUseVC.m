//
//  TermsOfUseVC.m
//  Jobalo
//
//  Created by Maverics on 9/20/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "TermsOfUseVC.h"
#import "PrivacyPolicyVC.h"

@implementation TermsOfUseVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TermsofUse" ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.contentWebView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"Terms of Use";
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - IBAction
- (IBAction)Accept:(id)sender{
    PrivacyPolicyVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyPolicyVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Decline:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
