//
//  SearchSMVC.h
//  TechCall
//
//  Created by Maverics on 9/9/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LookUpDelegate <NSObject>

- (void)setLookUpInformation:(NSDictionary*)infoDict;

@end

@interface SearchSMVC : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSString *actionKey, *searchValue, *productType;
@property (nonatomic, retain) NSMutableArray *searchFieldList, *searchCriteriaList;

@property (nonatomic, weak) id <LookUpDelegate> delegate;

@end
