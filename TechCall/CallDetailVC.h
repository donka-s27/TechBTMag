//
//  CallDetailVC.h
//  TechCall
//
//  Created by Maverics on 9/7/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallDetailVC : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, retain) NSDictionary *callInfoDict;

@end
