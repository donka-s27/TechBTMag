//
//  EquipmentDetailVC.h
//  TechCall
//
//  Created by Maverics on 8/17/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EquipmentDetailVC : UIViewController

@property (nonatomic, retain) NSMutableDictionary *dataObject;
@property (nonatomic, retain) NSMutableArray *keyList;
@property (nonatomic, retain) NSString *keyWord, *actionKeyWord;

@end
