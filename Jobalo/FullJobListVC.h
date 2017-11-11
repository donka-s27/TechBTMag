//
//  FullJobListVC.h
//  Jobalo
//
//  Created by Maverics on 8/22/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullJobListVC : UIViewController

@property (nonatomic, retain) NSMutableArray *fullJobList;
@property (nonatomic, retain) IBOutlet UITableView *jobTblView;
@end
