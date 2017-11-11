//
//  MyJobDetailVC.h
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmployerHomeVC.h"

@interface MyJobDetailVC : EmployerHomeVC<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSDictionary *jobDetailInfo;
@property (nonatomic, retain) NSMutableArray *applicantList;

@end
