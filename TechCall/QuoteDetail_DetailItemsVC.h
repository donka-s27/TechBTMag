//
//  QuoteDetail-Detail.h
//  TechCall
//
//  Created by Maverics on 9/22/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuoteDetail_DetailItemsVC : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *quoteDetailList;
@property (nonatomic, retain) NSDictionary *quoteMaster;

@end
