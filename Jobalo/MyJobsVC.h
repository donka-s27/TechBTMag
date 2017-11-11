//
//  MyJobsVC.h
//  Jobalo
//
//  Created by Maverics on 8/14/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmployerHomeVC.h"

@interface MyJobsVC : EmployerHomeVC <UITableViewDelegate, UITableViewDataSource>{

}

@property (nonatomic, retain) NSMutableArray *postedJobList, *compltedJobList;

@end
