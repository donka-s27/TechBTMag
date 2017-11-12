//
//  SecondViewController.h
//  TechCall
//
//  Created by Maverics on 7/18/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallTimesVC : UIViewController<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, retain) NSDictionary *callInfoDict;

@end

