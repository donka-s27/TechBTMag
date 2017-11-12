//
//  CallBookVC.h
//  TechCall
//
//  Created by Maverics on 9/28/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallBookVC : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, retain) NSDictionary *smInfo;

@end
