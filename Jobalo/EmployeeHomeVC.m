//
//  EmployeeHomeVC.m
//  Jobalo
//
//  Created by Maverics on 8/20/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "EmployeeHomeVC.h"
#import "EmployeeProfileVC.h"
#import "FindJobsVC.h"
#import "MyJobsVC-Employee.h"
#import "ContactUsVC.h"
#import "SettingsVC.h"
#import "MapPinAnnotation.h"
#import "JobDetailVC.h"

@interface EmployeeHomeVC (){
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *menuView;
    
    NSTimer *mapTimer;
}

@end

@implementation EmployeeHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [mapView setShowsUserLocation:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMap:)
                                                 name:@"LoadPinsOnMap"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavigationBar];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if (menuView.hidden) {
        [menuView setHidden:NO];
    }else{
        [menuView setHidden:YES];
    }
}

- (IBAction)MyProfile:(id)sender{
    if ([AppDelegate sharedInstance].userInfo) {
        EmployeeProfileVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"EmployeeProfileVC"];
        dest.title = @"EmployeeProfileVC";
        [self.navigationController pushViewController:dest animated:YES];
    }
}

- (IBAction)MyJobs:(id)sender{
    [self getFavorites];
}

- (IBAction)FindJobs:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AppDelegate sharedInstance] getJobsForEmployee];
    });
    
    FindJobsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"FindJobsVC"];
    dest.title = @"Find Jobs";
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Setting:(id)sender{
    SettingsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
    dest.title = @"Settings";
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)ContactUs:(id)sender{
    ContactUsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactUsVC"];
    dest.title = @"Contact Us";
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - User defined methods

- (NSMutableArray*)filterAppliedJobs{
    NSMutableArray *list = [AppDelegate sharedInstance].jobListForEmployee;
    NSMutableArray *appliedJobList = [[NSMutableArray alloc] init];
    
    for (int i=0; i<list.count; i++) {
        NSMutableDictionary *jobObject = [list objectAtIndex:i];
        
        // applied status
        if ([jobObject[@"applied"] integerValue] == 1) {
            [appliedJobList addObject:jobObject];
        }
    }
    
    return appliedJobList;
}

- (void)loadMap:(NSNotification *) notification{
    mapView.delegate = self;
    NSLog(@"JOBS: %@", [AppDelegate sharedInstance].jobListForEmployee);
    
    if ([[notification name] isEqualToString:@"LoadPinsOnMap"]){
        for (int i=0; i<[AppDelegate sharedInstance].jobListForEmployee.count; i++) {
            NSDictionary *jobObject = [AppDelegate sharedInstance].jobListForEmployee[i];
            
            double latValue = [jobObject[@"latitude"] doubleValue];
            double lonValue = [jobObject[@"longitude"] doubleValue];
            
            MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
            ann.title = jobObject[@"title"];
            ann.subtitle = jobObject[@"description"];
            
            ann.coordinate = CLLocationCoordinate2DMake (latValue, lonValue);
            [mapView addAnnotation:ann];
        }
    }
}

#pragma mark - Webservice

- (void)getFavorites{
    [AppDelegate sharedInstance].savedJobs = [[NSMutableArray alloc] init];
    
    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    
    [SVProgressHUD show];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/babysitter/%lu/favorites", BASIC_URL, userId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString
      parameters:@{@"babysitter_id": [NSString stringWithFormat:@"%lu", userId],
                   @"access_token": token}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Saved Jobs-JSON: %@", responseObject);
             
             if ([responseObject[@"result"] intValue] == 1){
                 // success in web service call return
                 [AppDelegate sharedInstance].savedJobs = responseObject[@"data"];
                 
                 MyJobsVC_Employee *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"MyJobsVC_Employee"];
                 dest.title = @"My Jobs";
                 dest.appliedJobList = [AppDelegate sharedInstance].appliedJobs;
                 //[self filterAppliedJobs];
                 dest.savedJobList = [AppDelegate sharedInstance].savedJobs;
                 [self.navigationController pushViewController:dest animated:YES];
             }else{
                 // failure response
             }
             
             [SVProgressHUD dismiss];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
         }
     ];
}

#pragma mark - MKMapView Delegate

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    MKPointAnnotation *annotation = (MKPointAnnotation*)view.annotation;
    
    for (int i=0; i<[AppDelegate sharedInstance].jobListForEmployee.count; i++) {
        NSDictionary *jobObject = [AppDelegate sharedInstance].jobListForEmployee[i];
        
        if ([annotation.title isEqualToString:jobObject[@"title"]]) {
            JobDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"JobDetailVC"];
            dest.title = @"Job listing";
            dest.jobObject = jobObject;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }
}

@end
