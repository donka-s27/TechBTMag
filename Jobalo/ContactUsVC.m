//
//  ContactUsVC.m
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "ContactUsVC.h"
#import "AppDelegate.h"

@interface ContactUsVC ()

@end

@implementation ContactUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    // Unhide the navigation bar
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    // Navbar color
    [self.navigationController.navigationBar setAlpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor groupTableViewBackgroundColor];
    
    // Adjust nav bar title based on current view identifier
    self.navigationController.navigationBar.topItem.title = @"Contact Us";
    
    // Nabvar title tine color
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                      NSFontAttributeName:[UIFont boldSystemFontOfSize:22.0f]
                                                                      }];
    
    // Left button
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(ToggleMenu:)];
    [leftItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Facebook:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/Jobalo-Jobs-1784660628413193/"]];
}

- (IBAction)Twitter:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/JobaloJobs"]];
}

- (IBAction)Instagram:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.instagram.com/jobalojobs/?hl=en"]];
}

- (IBAction)Website:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.jobalojobs.net"]];

}

@end
