//
//  PickerListVC.m
//  Jobalo
//
//  Created by Maverics on 9/13/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "PickerListVC.h"

@implementation PickerListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.keyword isEqualToString:@"Location"]) {
        titleLabel.text = @"Location";
    }else if ([self.keyword isEqualToString:@"Age"]) {
        titleLabel.text = @"Age";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}

#pragma mark - UIPickerView delegate & datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pickerContentList.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _pickerContentList[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
}

#pragma mark - IBAction
- (IBAction)Choose:(id)sender{
    NSString *value = _pickerContentList[[pickerView selectedRowInComponent:0]];
    [self.delegate setPickerValue:value key:self.keyword];
    
    [self.navigationController popViewControllerAnimated:YES];    
}

@end
