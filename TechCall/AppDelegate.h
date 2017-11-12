//
//  AppDelegate.h
//  TechCall
//
//  Created by Maverics on 7/18/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SVProgressHUD.h>
#import <AFNetworking.h>
#import <CoreLocation/CoreLocation.h>

#import "Define.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>{
    CLLocationManager *curLocManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSUserDefaults *userDefaults;

@property (nonatomic, retain) NSString *token, *syncToken, *ipAddress;

@property (nonatomic, retain) NSMutableDictionary *currentInfo, *setupInfo, *searchInfo;
@property (nonatomic, retain) NSMutableArray *rootInfo;
@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, readwrite) NSInteger currentIndex;

//location variables
@property (nonatomic, readwrite) BOOL bGetLoc;
@property (strong, nonatomic) CLLocation *startLocation;


+ (AppDelegate*)sharedInstance;
- (void)showAlertMessage:(NSString*)title message:(NSString*)content buttonTitle:(NSString*)cancelButtonTitle;
- (void)TechLocationUpdate:(double)lat longitude:(double)lon;
- (NSString *)daySuffixForDate:(NSDate *)date;
- (void)SDTechCalls:(NSDate*)date;
- (void)SDSetup;
- (void)setLocationManager;
- (void)ValidateToken:(NSDate*)date;

@end
