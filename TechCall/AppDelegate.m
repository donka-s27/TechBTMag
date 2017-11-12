//
//  AppDelegate.m
//  TechCall
//
//  Created by Maverics on 7/18/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "AppDelegate.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AppDelegate ()

@end

@implementation UIDevice( SystemVersion )

- (BOOL)isSystemVersionLowerThan:( NSString * )versionToCompareWith{
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
    self.currentDate = [NSDate date];
    self.searchInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                       @"", @"SearchKey",
                       @"", @"SearchField", nil];
    self.ipAddress = @"https://www.saimobile2.com:291";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveData)
                                                 name:@"SaveDataToLocal"
                                               object:nil];

    [self SDSetup];
    [self SDTechCalls:self.currentDate];

    //useless part
    NSPropertyListFormat plistFormat;
    NSError *errorNew;
    NSData *mainData1 = [self.userDefaults objectForKey:@"main"];
    if (mainData1){
        NSMutableArray *mainList = [NSPropertyListSerialization propertyListWithData:mainData1 options:NSPropertyListImmutable format:&plistFormat error:&errorNew];
        self.rootInfo = [[NSMutableArray alloc] initWithArray:mainList];
    }

    NSData *mainData2 = [self.userDefaults objectForKey:@"setup"];
    if (mainData2) {
        NSMutableDictionary *setupData = [NSPropertyListSerialization propertyListWithData:mainData2 options:NSPropertyListImmutable format:&plistFormat error:&errorNew];
        self.setupInfo = [[NSMutableDictionary alloc] initWithDictionary:setupData];
    }

    return YES;
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Location Manager Delegate methods
- (void)setLocationManager{
    self.bGetLoc = NO;
    
    curLocManager = [[CLLocationManager alloc] init];
    curLocManager.delegate = self;
    curLocManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    curLocManager.distanceFilter = kCLDistanceFilterNone;
    // Check for iOS 8
//    if ([curLocManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [curLocManager requestWhenInUseAuthorization];
//    }
    
    [curLocManager requestAlwaysAuthorization];
    [curLocManager startMonitoringSignificantLocationChanges];
    [curLocManager startUpdatingLocation];
}

-(void)resetDistance:(id)sender{
    self.startLocation = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError: %@", error);
    self.bGetLoc = NO;
    
    [curLocManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location_updated = [locations lastObject];
    
    float newLat = [[NSString stringWithFormat:@"%.3f", location_updated.coordinate.latitude] floatValue];
    float newLon = [[NSString stringWithFormat:@"%.3f", location_updated.coordinate.longitude] floatValue];
    float oldLat = [[NSString stringWithFormat:@"%.3f", _startLocation.coordinate.latitude] floatValue];
    float oldLon = [[NSString stringWithFormat:@"%.3f", _startLocation.coordinate.longitude] floatValue];
    
    if (newLat != oldLat || newLon != oldLon)
        self.bGetLoc = NO;
    
    self.startLocation = location_updated;
    if (!self.bGetLoc) {
        NSLog(@"%.3f, %.3f", self.startLocation.coordinate.latitude, self.startLocation.coordinate.longitude);
        
        self.bGetLoc = YES;
        [self TechLocationUpdate:self.startLocation.coordinate.latitude longitude:self.startLocation.coordinate.longitude];
    }
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

- (NSString *)daySuffixForDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dayOfMonth = [calendar component:NSCalendarUnitDay fromDate:date];
    switch (dayOfMonth) {
        case 1:
        case 21:
        case 31: return @"st";
        case 2:
        case 22: return @"nd";
        case 3:
        case 23: return @"rd";
        default: return @"th";
    }
}

- (void)saveData{
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ValidateToken:) userInfo:nil repeats:YES];
}

- (void)SDSetup{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, SETUPINFO];
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             if (responseObject) {
                 // success in web service call return
                 [AppDelegate sharedInstance].setupInfo = responseObject;
                 
                 NSMutableDictionary *setupData = self.setupInfo;
                 NSData *data = [NSPropertyListSerialization dataWithPropertyList:setupData format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
                 [self.userDefaults setObject:data forKey:@"setup"];
                 [self.userDefaults synchronize];

             }else{
                 // failure response
                 [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
         }
     ];
}

- (void)ValidateToken:(NSDate*)date{
    date = self.currentDate;
    
    NSString *dateString = @"2016-06-03";

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    dateString = [df stringFromDate:date];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, SYNC_TOKEN];
    [manager GET:urlString
      parameters:@{@"ServiceDate": dateString}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 if (![responseObject[@"Result"] isEqualToString:self.syncToken]) {
                     [self SDTechCalls:self.currentDate];
                 }
             }else{
                 // failure response
                 //                  [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
                 [SVProgressHUD dismiss];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //             NSLog(@"Error: %@", error);
             NSLog(@"Error: %@", operation.responseObject);
             [SVProgressHUD dismiss];
         }
     ];
}

- (void)SDTechCalls:(NSDate*)date{
    [SVProgressHUD show];
    
    date = self.currentDate;
    NSString *dateString = @"2016-06-03";
    //  @"2016-06-02";
    //  @"2016-04-07";
    //  @"2016-09-20";
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    dateString = [df stringFromDate:date];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, GET_TECHCALLSBYDATE];
    [manager GET:urlString
      parameters:@{@"ServiceDate": dateString}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.rootInfo = [NSMutableArray array];
                 self.syncToken = responseObject[@"SyncToken"];
                 
                 NSMutableArray *list = (NSMutableArray*)responseObject[@"CallsAssignedToTech"];
                 if (list && list.count > 0) {
                     for (NSDictionary *aDict in list){
                         NSMutableDictionary *mutable = [aDict mutableCopy];
                         [self.rootInfo addObject:mutable];
                     }
                     
                     NSMutableArray *dataList = self.rootInfo;
                     NSData *data = [NSPropertyListSerialization dataWithPropertyList:dataList format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
                     [self.userDefaults setObject:data forKey:@"main"];
                     [self.userDefaults synchronize];
                 }

                 [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadRootData" object:self];
             }else{
                 // failure response
                 //                  [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
                 [SVProgressHUD dismiss];

                 [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadRootData" object:self];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"Error: %@", error);
             NSLog(@"Error: %@", operation.responseObject);
             [SVProgressHUD dismiss];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadRootData" object:self];
         }
     ];
}

- (void)TechLocationUpdate:(double)lat longitude:(double)lon{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];

    NSString *urlString = [NSString stringWithFormat:@"%@/api/App/TechLocation", BASIC_URL];
    
    NSLog(@"param = %@", @{@"Latitude": [NSNumber numberWithDouble:lat],
                           @"Longitude": [NSNumber numberWithDouble:lon]});
    [manager POST:urlString
       parameters:@{@"Latitude": [NSNumber numberWithDouble:lat],
                    @"Longitude": [NSNumber numberWithDouble:lon]}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [SVProgressHUD dismiss];
              
              if ([responseObject[@"Result"] isEqualToString:@"SUCCESS"]) {
                  // success in web service call return
                  
              }else{
                  // failure response
                  
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }
     ];
}

@end
