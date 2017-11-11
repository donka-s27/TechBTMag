//
//  NavigationType1.m
//  Jobalo
//
//  Created by Maverics on 8/20/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "NavigationType1.h"

@interface NavigationType1 ()

@end

@implementation NavigationType1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [self viewWillAppear:animated];
    [self setupNavigationBar];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UI

- (void)setupNavigationBar{
    // Unhide the navigation bar
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    // Navbar color
    [self.navigationController.navigationBar setAlpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor groupTableViewBackgroundColor];
    
    // Adjust nav bar title based on current view identifier
    self.navigationController.navigationBar.topItem.title = @"Home";
    
    // Nabvar title tine color
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:[UIColor grayColor],
                                                                      NSFontAttributeName:[UIFont boldSystemFontOfSize:22.0f]
                                                                      }];
    
    // left button
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"logoMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(ToggleMenu:)];
    [leftItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark - IBAction

- (IBAction)ToggleMenu:(id)sender{
}
@end
