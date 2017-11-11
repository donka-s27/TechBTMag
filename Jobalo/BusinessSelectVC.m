//
//  EmployerVC.m
//  Jobalo
//
//  Created by Maverics on 8/14/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "BusinessSelectVC.h"
#import "AppDelegate.h"

@implementation BusinessSelectVC

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"GoToLogin"]) {
        
    }
}

#pragma mark - IBAction

- (IBAction)Business:(id)sender{
    [AppDelegate sharedInstance].businessType = @"BUSINESS";
    [self performSegueWithIdentifier:@"GoToLogin" sender:self];
}

- (IBAction)Individual:(id)sender{
    [AppDelegate sharedInstance].businessType = @"INDIVIDUAL";
    [self performSegueWithIdentifier:@"GoToLogin" sender:self];
}

@end
