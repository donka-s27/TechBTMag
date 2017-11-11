//
//  Define.h
//  Jobalo
//
//  Created by Maverics on 8/25/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#ifndef Define_h
#define Define_h

#import "UIImageView+WebCache.h"

#pragma mark - HOSTING INFORMATION
#define BASIC_URL @"http://jobalojobs.com/public"
#define SUPPORT_EMAIL @"key_doz@keydoz.com"

#pragma mark - PROJECT INFORMATION
#define kOFFSET_KEYBOARD 190
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#pragma mark - THIRD API INFORMATION
#define FLURRY_KEY @"TBP3RN7Q4PSKW9P29SZ6"

#pragma mark - BACKEND API INFORMATION

#define MAPQUEST_KEY @"S0ibMtzqfSTbihAubGLuNQFFhBayPjx7"
#define CLIENT_ID @"f3d259ddd3ed8ff3843839b"
#define CLIENT_SECRET @"4c7f6f8fa93d59c45502c0ae8c4a95b"

#define USER @"api/user"
#define EMPLOYER_SIGNUP @"api/parent"
#define EMPLOYER_LOGIN @"api/parentlogin"
#define EMPLOYER_JOB @"api/job"
#define EMPLOYER_GETUSERID @"api/userid"

#define EMPLOYER_FORGOTPASS @"api/password/reset"

#define EMPLOYEE_SIGNUP @"api/babysitter"
#define EMPLOYEE_LOGIN @"api/babysitterlogin"
#define EMPLOYEE_ADD_FAVORITE @"api/job/favorite"
#define EMPLOYEE_DIS_FAVORITE @"api/job/disfavorite"
#define EMPLOYEE_JOB_APPLY @"api/applyJob"
#define EMPLOYEE_CREATE_CONTRACT @"api/contract"


#define GET_BABYSITTERS @"api/babysitters"
#define LEAVE_FEEDBACK @"api/feedback/babysitter"
#define EMAIL_SEND @"api/email"
#define GET_QBID @"api/qbidByEmail"

#endif /* Define_h */
