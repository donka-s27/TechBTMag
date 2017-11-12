//
//  SolutionCodeListVC.h
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SolutionCodeListVC : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *solCodeList;
@property (nonatomic, retain) NSDictionary *invoiceInfo;

@end
