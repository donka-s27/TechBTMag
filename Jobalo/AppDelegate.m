//
//  AppDelegate.m
//  Jobalo
//
//  Created by Maverics on 8/10/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Flurry.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLPlacemark.h>

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation UIDevice( SystemVersion )

- (BOOL)isSystemVersionLowerThan:( NSString * )versionToCompareWith
{
    if( versionToCompareWith.length == 0 )
        return NO;
    
    NSString *deviceSystemVersion = [self systemVersion];
    NSArray *systemVersionComponents = [deviceSystemVersion componentsSeparatedByString: @"."];
    
    uint16_t deviceMajor = 0;
    uint16_t deviceMinor = 0;
    uint16_t deviceBugfix = 0;
    
    NSUInteger nDeviceComponents = systemVersionComponents.count;
    if( nDeviceComponents > 0 )
        deviceMajor = [( NSString * )systemVersionComponents[0] intValue];
    if( nDeviceComponents > 1 )
        deviceMinor = [( NSString * )systemVersionComponents[1] intValue];
    if( nDeviceComponents > 2 )
        deviceBugfix = [( NSString * )systemVersionComponents[2] intValue];
    
    NSArray *versionToCompareWithComponents = [versionToCompareWith componentsSeparatedByString: @"."];
    
    uint16_t versionToCompareWithMajor = 0;
    uint16_t versionToCompareWithMinor = 0;
    uint16_t versionToCompareWithBugfix = 0;
    
    NSUInteger nVersionToCompareWithComponents = versionToCompareWithComponents.count;
    if( nVersionToCompareWithComponents > 0 )
        versionToCompareWithMajor = [( NSString * )versionToCompareWithComponents[0] intValue];
    if( nVersionToCompareWithComponents > 1 )
        versionToCompareWithMinor = [( NSString * )versionToCompareWithComponents[1] intValue];
    if( nVersionToCompareWithComponents > 2 )
        versionToCompareWithBugfix = [( NSString * )versionToCompareWithComponents[2] intValue];
    
    return ( deviceMajor < versionToCompareWithMajor )
    || (( deviceMajor == versionToCompareWithMajor ) && ( deviceMinor < versionToCompareWithMinor ))
    || (( deviceMajor == versionToCompareWithMajor ) && ( deviceMinor == versionToCompareWithMinor ) && ( deviceBugfix < versionToCompareWithBugfix ));
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    [Flurry startSession:FLURRY_KEY];

    if ([self.userDefaults objectForKey:@"appliedJobs"]) {
        self.appliedJobs = [self.userDefaults objectForKey:@"appliedJobs"];
    }else{
        self.appliedJobs = [[NSMutableArray alloc] init];
    }
    
    // Estimate iphone model size
    if ([[UIScreen mainScreen] bounds].size.height == 480)
        _g_bPhone4 = YES;
    else
        _g_bPhone4 = NO;
    

    [self setLocationManager];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self setLocationManager];
    
    [FBSDKAppEvents activateApp];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSString *urlStr = [NSString stringWithFormat:@"%@",url];
    
    NSRange range = [urlStr rangeOfString:@"oauth2"];
    if (range.location == NSNotFound) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    
    return YES;
}

#pragma mark - App Engine methods

+ (AppDelegate*)sharedInstance{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)showAlertMessage:(NSString*)title message:(NSString*)content buttonTitle:(NSString*)cancelButtonTitle{
    if( [[UIDevice currentDevice] isSystemVersionLowerThan:@"8"] ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                                        message: content
                                                       delegate: nil
                                              cancelButtonTitle: cancelButtonTitle
                                              otherButtonTitles: nil];
        [alert show];
    }else{
        // nil titles break alert interface on iOS 8.0, so we'll be using empty strings
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: title == nil ? @"": title
                                                                       message: content
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: cancelButtonTitle
                                                                style: UIAlertActionStyleDefault
                                                              handler: nil];
        [alert addAction: defaultAction];
        
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootViewController presentViewController: alert animated: YES completion: nil];
    }
}

- (NSString*)changeDateFormat:(NSDate*)date format:(NSString*)formatString{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:formatString];
    NSString *result = [df stringFromDate:date];
    
    return result;
}

- (NSString*)reverseGeocode:(CGFloat)lat Longitude:(CGFloat)lon{
    id locationData;
    NSString *locationString = [[NSString alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.mapquestapi.com/geocoding/v1/reverse?key=%@&callback=renderReverse&location=%f,%f", MAPQUEST_KEY, lat, lon];
    NSLog(@"user string = %@", urlString);
    
    // Send a synchronous request
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil){
        // Parse data here
        NSString *convertedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // remove useless characters for JSON parsing
        NSArray *components = [convertedString componentsSeparatedByString:@"("];
        convertedString = components[1];
        convertedString = [convertedString substringToIndex:[convertedString length] - 1];
        
        // turn edited string into data for parsing
        NSData *data = [convertedString dataUsingEncoding:NSUTF8StringEncoding];
        
        // JSON parsed result
        id parseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        // extract location unit
        if (parseData[@"results"] && [parseData[@"results"] count] > 0) {
            NSMutableDictionary *tempDict = [parseData[@"results"] firstObject];
            locationData = [tempDict[@"locations"] firstObject];
            
            NSString *street = locationData[@"street"];
            NSString *city = locationData[@"adminArea5"];
            NSString *county = locationData[@"adminArea4"];
            NSString *state = locationData[@"adminArea3"];
            NSString *country = locationData[@"adminArea1"];
            
            locationString = [NSString stringWithFormat:@"%@, %@, %@, %@, %@",
                              street, city, county, state, country];
        }
    } else {
        locationString = @"";
    }
    
    return locationString;
}

- (CLLocationDistance)calculateKiloDistWithLatitude:(double)lat Longitude:(double)lon{
    CLLocation *endLoc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    CLLocationDistance distance = [[AppDelegate sharedInstance].startLocation distanceFromLocation:endLoc];
    double distanceKM = distance / 1000;
    return distanceKM;
}

#pragma mark - Global web service methods

- (void)getJobsForEmployee{
    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *lonString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].startLocation.coordinate.longitude];
    NSString *latString = [NSString stringWithFormat:@"%f", [AppDelegate sharedInstance].startLocation.coordinate.latitude];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/babysitter/%lu/jobs", BASIC_URL, (long)userId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString
      parameters:@{@"latitude": latString,
                   @"longitude": lonString,
                   @"access_token": token}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Jobs for Employee - JSON: %@", responseObject);
             
             if (responseObject) {
                 // success in web service call return
                 if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                     self.jobListForEmployee = [NSMutableArray arrayWithObject:responseObject[@"data"]];
                 }else if ([responseObject[@"data"] isKindOfClass:[NSArray class]]){
                     self.jobListForEmployee = responseObject[@"data"];
                 }
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadPinsOnMap" object:self];
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

- (void)getPostedJobsByEmployer{
    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/parent/%lu/jobs", BASIC_URL, (long)userId];

//EMPLOYER_JOB
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:urlString
      parameters:@{@"access_token": token}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Jobs by Employer - JSON: %@", responseObject);
             
             if ([responseObject[@"message"] isEqualToString:@"success"]) {
                 // success in web service call return
                 if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                     self.jobListByEmployer = [NSMutableArray arrayWithObject:responseObject[@"data"]];
                 }else if ([responseObject[@"data"] isKindOfClass:[NSArray class]]){
                     self.jobListByEmployer = responseObject[@"data"];
                 }
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadPinsOnEmployerMap" object:self];
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateJobs" object:self];

             }else{
                 // failure response
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }
     ];
}

- (void)getSavedJobs{
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

- (void)getUserInfo{
    NSInteger userId = [AppDelegate sharedInstance].userId;
    NSString *token = [[AppDelegate sharedInstance].userDefaults objectForKey:@"token"];
    
    NSString *urlString;

    if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYEE"]) {
        urlString = [NSString stringWithFormat:@"%@/api/babysitter/%lu", BASIC_URL, (long)userId];        
    }else if ([[AppDelegate sharedInstance].accountType isEqualToString:@"EMPLOYER"]) {
        urlString = [NSString stringWithFormat:@"%@/api/parent/%lu", BASIC_URL, (long)userId];
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString
      parameters:@{@"access_token": token}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Userinfo - JSON: %@", responseObject);
             
             if ([responseObject[@"result"] intValue] == 1){
                 self.userInfo = responseObject[@"data"];
             }else{
                 
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }
     ];
}


#pragma mark - Location Manager Delegate methods
- (void)geoCodeConvert:(NSString*)address{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray *placemarks, NSError *error){
                     for (CLPlacemark* aPlacemark in placemarks){
                         // Process the placemark.
                         NSString *latDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.latitude];
                         NSString *lngDest1 = [NSString stringWithFormat:@"%.4f",aPlacemark.location.coordinate.longitude];
                         
                         self.postLocation = aPlacemark.location;
                     }
                 }
     ];
}

- (void)setLocationManager{
    _bGetLoc = NO;
    
    curLocManager = [[CLLocationManager alloc] init];
    curLocManager.desiredAccuracy = kCLLocationAccuracyBest;
    curLocManager.delegate = self;
    curLocManager.distanceFilter = kCLDistanceFilterNone;
    [curLocManager requestWhenInUseAuthorization];
    [curLocManager startMonitoringSignificantLocationChanges];
    
    // Override point for customization after application launch.
//    if (IS_OS_8_OR_LATER){
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
//                                                                                             |UIRemoteNotificationTypeSound
//                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    }else{
//        //register to receive notifications
//        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
//    }
    
//    SEL requestSelector = NSSelectorFromString(@"requestAlwaysAuthorization");
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
//        [curLocManager respondsToSelector:requestSelector]) {
//        [curLocManager performSelector:requestSelector withObject:NULL];
//    } else {
//        [curLocManager startUpdatingLocation];
//    }
    
    [curLocManager startUpdatingLocation];
}

-(void)resetDistance:(id)sender{
    self.startLocation = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError: %@", error);
    _bGetLoc = NO;
    
    [self setLocationManager];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location_updated = [locations lastObject];
    
    float newLat = [[NSString stringWithFormat:@"%.3f", location_updated.coordinate.latitude] floatValue];
    float newLon = [[NSString stringWithFormat:@"%.3f", location_updated.coordinate.longitude] floatValue];
    float oldLat = [[NSString stringWithFormat:@"%.3f", _startLocation.coordinate.latitude] floatValue];
    float oldLon = [[NSString stringWithFormat:@"%.3f", _startLocation.coordinate.longitude] floatValue];
    
    if (newLat != oldLat || newLon != oldLon)
        _bGetLoc = NO;
    
    self.startLocation = location_updated;
    if (!_bGetLoc) {
        NSLog(@"%.3f, %.3f", _startLocation.coordinate.latitude, _startLocation.coordinate.longitude);
        _bGetLoc = YES;
    }
}

@end
