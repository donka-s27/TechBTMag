//
//  DetailListVC.h
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailListVC : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSMutableArray *detailList;

@end