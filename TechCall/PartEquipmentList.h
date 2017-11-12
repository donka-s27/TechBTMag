//
//  PartEquipmentList.h
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartEquipmentList : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) NSDictionary *invoiceInfo;

@end
