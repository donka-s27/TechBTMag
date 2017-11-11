//
//  AppDelegate.h
//  Jobalo
//
//  Created by Maverics on 8/10/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationType1.h"
#import "NavigationType2.h"
#import <AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <CoreLocation/CoreLocation.h>
#import "Define.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>{
    CLLocationManager *curLocManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *businessType, *accountType;
@property (nonatomic, retain) NSUserDefaults *userDefaults;

@property (nonatomic, readwrite) BOOL g_bPhone4, bGetLoc;
@property (nonatomic, readwrite) NSInteger userId;
@property (nonatomic, retain) NSMutableArray *jobListByEmployer, *jobListForEmployee, *savedJobs, *appliedJobs;

@property (strong, nonatomic) CLLocation *startLocation, *postLocation;
@property (nonatomic, retain) NSMutableDictionary *userInfo, *paymentInfo;

+ (AppDelegate*)sharedInstance;
- (void)showAlertMessage:(NSString*)title message:(NSString*)content buttonTitle:(NSString*)cancelButtonTitle;
- (NSString*)changeDateFormat:(NSDate*)date format:(NSString*)formatString;
- (id)reverseGeocode:(CGFloat)lat Longitude:(CGFloat)lon;
- (CLLocationDistance)calculateKiloDistWithLatitude:(double)lat Longitude:(double)lon;
- (void)geoCodeConvert:(NSString*)address;

- (void)getUserInfo;
- (void)getPostedJobsByEmployer;
- (void)getJobsForEmployee;
- (void)getSavedJobs;

@end

