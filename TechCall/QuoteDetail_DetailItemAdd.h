//
//  QuoteDetail-DetailAdd.h
//  TechCall
//
//  Created by Maverics on 9/22/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchSMVC.h"

@interface QuoteDetail_DetailItemAdd : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, LookUpDelegate>

@property (nonatomic, retain) NSDictionary *quoteDetailObject;
@property (nonatomic, retain) NSString *actionKey, *updateMode;
@property (nonatomic, retain) NSMutableDictionary *param;

@end
