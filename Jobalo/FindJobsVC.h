//
//  FindJobsVC.h
//  Jobalo
//
//  Created by Maverics on 8/21/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmployerHomeVC.h"
#import "PickerListVC.h"

@interface FindJobsVC : EmployerHomeVC<UITextFieldDelegate, PickValueDelegate>

@property (nonatomic, retain) NSMutableArray *filteredJobs;

@end
