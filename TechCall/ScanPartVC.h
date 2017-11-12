//
//  ScanPartVC.h
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchSMVC.h"
#import "BarcodeViewController.h"

@interface ScanPartVC : UIViewController<PartNumberSettingDelegate, LookUpDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic, retain) NSDictionary *invoiceInfo;

@end
