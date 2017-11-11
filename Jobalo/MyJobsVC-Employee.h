//
//  MyJobsVC-Employee.h
//  Jobalo
//
//  Created by Maverics on 8/21/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmployerHomeVC.h"

@interface MyJobsVC_Employee : EmployerHomeVC <UITableViewDelegate, UITableViewDataSource>{
    
}


@property (nonatomic, retain) NSMutableArray *savedJobList, *appliedJobList;

@end
