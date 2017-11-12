//
//  InvoiceDetailVC.h
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecommendationDetailVC.h"

@interface InvoiceDetailVC : UIViewController<UITextViewDelegate, DescriptionDelegate>

@property (nonatomic, retain) NSMutableDictionary *invoiceData;

@end
