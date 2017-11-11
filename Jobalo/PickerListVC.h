//
//  PickerListVC.h
//  Jobalo
//
//  Created by Maverics on 9/13/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickValueDelegate <NSObject>

- (void)setPickerValue:(NSString*)pickedValue key:(NSString*)keyword;

@end

@interface PickerListVC : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>{
    IBOutlet UILabel *titleLabel;
    IBOutlet UIPickerView *pickerView;
    

}

@property (nonatomic, retain) NSString *keyword;
@property (nonatomic, retain) NSMutableArray *pickerContentList;
@property (nonatomic, retain) id delegate;

@end
