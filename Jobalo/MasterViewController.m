//
//  MasterViewController.m
//  Jobalo
//
//  Created by Maverics on 8/10/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "MasterViewController.h"
#import "AppDelegate.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

#pragma mark - UI
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar{

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"GoToBusinessSelect"]) {

    }
}

#pragma mark - IBAction

- (IBAction)PostJob:(id)sender{
    [AppDelegate sharedInstance].accountType = @"EMPLOYER";
    [self performSegueWithIdentifier:@"GoToBusinessSelect" sender:self];
}

- (IBAction)FindJob:(id)sender{
    [AppDelegate sharedInstance].accountType = @"EMPLOYEE";
    [self performSegueWithIdentifier:@"LOGIN" sender:self];
}

@end
