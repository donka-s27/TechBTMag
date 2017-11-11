//
//  DetailTextVC.h
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApplicantInfoVC.h"

@interface DetailTextVC : UIViewController<UITextViewDelegate>

@property (nonatomic, retain) NSString *textContent;
@property (nonatomic, retain) NSString *keyword;

@end
