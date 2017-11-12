//
//  QuoteDetailVC.h
//  TechCall
//
//  Created by Maverics on 9/21/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface QuoteDetailVC : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSDictionary *dataObject;
@property (nonatomic, retain) NSString *actionKey;

@end
