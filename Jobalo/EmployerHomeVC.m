//
//  EmployerHomeVC.m
//  Jobalo
//
//  Created by Maverics on 8/14/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "EmployerHomeVC.h"
#import "AppDelegate.h"
#import "MyJobsVC.h"
#import "PostJobVC.h"
#import "SettingsVC.h"
#import "ContactUsVC.h"
#import "MyJobDetailVC.h"

@implementation EmployerHomeVC{
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *menuView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [mapView setShowsUserLocation:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadEmployerMap:)
                                                 name:@"LoadPinsOnEmployerMap"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupNavigationBar];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

#pragma mark - User defined methods
- (void)loadEmployerMap:(NSNotification *) notification{
    mapView.delegate = self;
    NSLog(@"JOBS: %@", [AppDelegate sharedInstance].jobListByEmployer);
    
    if ([[notification name] isEqualToString:@"LoadPinsOnEmployerMap"]){
        for (int i=0; i<[AppDelegate sharedInstance].jobListByEmployer.count; i++) {
            NSDictionary *jobObject = [AppDelegate sharedInstance].jobListByEmployer[i];
            
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

#pragma mark - IBAction

- (IBAction)ToggleMenu:(id)sender{
    if (menuView.hidden) {
        [menuView setHidden:NO];
    }else{
        [menuView setHidden:YES];
    }
}

- (IBAction)MyJobs:(id)sender{
    if ([AppDelegate sharedInstance].userInfo && [AppDelegate sharedInstance].userId) {
        MyJobsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"MyJobsVC"];
        dest.title = @"My Jobs";
        dest.postedJobList = [AppDelegate sharedInstance].jobListByEmployer;
        [self.navigationController pushViewController:dest animated:YES];        
    }
}

- (IBAction)PostJob:(id)sender{
    if ([AppDelegate sharedInstance].userInfo && [AppDelegate sharedInstance].userId) {
        PostJobVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"PostJobVC"];
        dest.title = @"Post Job";
        [self.navigationController pushViewController:dest animated:YES];
    }
}

- (IBAction)Setting:(id)sender{
    if ([AppDelegate sharedInstance].userInfo && [AppDelegate sharedInstance].userId) {
        SettingsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
        dest.title = @"Settings";
        [self.navigationController pushViewController:dest animated:YES];
    }
}

- (IBAction)ContactUs:(id)sender{
    if ([AppDelegate sharedInstance].userInfo && [AppDelegate sharedInstance].userId) {
        ContactUsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactUsVC"];
        dest.title = @"Contact Us";
        [self.navigationController pushViewController:dest animated:YES];
    }
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
    
    for (int i=0; i<[AppDelegate sharedInstance].jobListByEmployer.count; i++) {
        NSDictionary *jobObject = [AppDelegate sharedInstance].jobListByEmployer[i];
        
        if ([annotation.title isEqualToString:jobObject[@"title"]]) {
            MyJobDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"MyJobDetailVC"];
            dest.jobDetailInfo = jobObject;
            dest.title = @"Job Applicants";
            [self.navigationController pushViewController:dest animated:YES];
            
            break;
        }
    }
}

@end
