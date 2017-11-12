//
//  EquipmentDetailVC.m
//  TechCall
//
//  Created by Maverics on 8/17/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "EquipmentDetailVC.h"
#import "AppDelegate.h"

@interface EquipmentDetailVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    IBOutlet UITableView *dataTblView;
    IBOutlet UIView *pickerView;
    IBOutlet UIDatePicker *datePicker;

    NSMutableDictionary *tempDict;
    UIFont *defaultFont, *contentFont;
}

@end

@implementation EquipmentDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(Submit:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;

    if ([self.keyWord isEqualToString:@"Equip"]) {
        self.keyList = [[NSMutableArray alloc] initWithObjects:@"Manufacturer", @"ModelNum", @"SerialNum",
                        @"UnitNum", @"System", @"Description",
                        @"Location", @"OurInstallation", @"InstallationDate",
                        @"LastRepairDate", @"ManufacturerWarrantyDate", @"ExtendedWarrantyDate", @"IsEquipmentAttachedToCall", nil];
    }else if([self.keyWord isEqualToString:@"Contact"]){
        self.keyList = [[NSMutableArray alloc] initWithObjects:@"ContactName", @"Email", @"PhoneNumber",
                        @"MobilNumber", nil];
    }

    tempDict = [self.dataObject mutableCopy];
    if (!tempDict){
        NSInteger serviceMasterNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Id"] integerValue];

        tempDict = [[NSMutableDictionary alloc] init];
        NSDictionary *emptyDict = @{};
        
        [tempDict setObject:emptyDict forKey:@"Contract"];
        [tempDict setObject:emptyDict forKey:@"EquipmentMiscFields"];
        [tempDict setObject:emptyDict forKey:@"Job"];
        [tempDict setObject:@{@"Id" : [NSNumber numberWithInteger:serviceMasterNo]} forKey:@"ServiceMaster"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark - IBAction
#pragma mark -

- (IBAction)Submit:(id)sender{
    [self updateInformation];
}


#pragma mark - Time Setting
- (IBAction)TimeSetting:(UIButton*)sender{
    [pickerView setHidden:NO];
    pickerView.tag = sender.tag;
}

#pragma mark - OurInstallation / IsEquipmentAttachedToCall Switch Setting
- (IBAction)SwitchOption:(UISwitch*)sender{
    NSInteger selectedIndex = sender.tag;
    NSString *selectedKey = self.keyList[selectedIndex];

    //parameter setting
    if (sender.on)
        [tempDict setObject:@"Y" forKey:selectedKey];
    else
        [tempDict setObject:@"N" forKey:selectedKey];
}

#pragma mark - Date Picker View
- (IBAction)DoneTimeSetting:(id)sender{
    [pickerView setHidden:YES];
    
    NSInteger selectedIndex = pickerView.tag;
    NSString *selectedKey =  self.keyList[selectedIndex];
    
    //time format string
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *timeString = [df stringFromDate:datePicker.date];
    
    //parameter setting
    [tempDict setObject:timeString forKey:selectedKey];
    
    //button title
    NSMutableDictionary *cacheDict = [self.dataObject mutableCopy];
    [cacheDict setObject:[NSString stringWithFormat:@"%@", timeString] forKey:selectedKey];
    self.dataObject = cacheDict;

    [dataTblView reloadData];
}

- (IBAction)CancelTimeSetting:(id)sender{
    [pickerView setHidden:YES];

}

#pragma mark - Webservice

- (void)updateInformation{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];

    NSInteger serviceMasterNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Id"] integerValue];
    NSString *urlString;
    
    if([self.keyWord isEqualToString:@"Equip"]){
        urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EQUIPMENT];
    }else if([self.keyWord isEqualToString:@"Contact"]){
        [tempDict setObject:[NSNumber numberWithInteger:serviceMasterNo] forKey:@"ServiceMasterNum"];
        urlString = [NSString stringWithFormat:@"%@/%@?ServiceMasterNum=%lu", BASIC_URL, CONTACT, serviceMasterNo];
    }
    
    NSLog(@"update param = %@", tempDict);

    [manager POST:urlString
       parameters:tempDict
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [SVProgressHUD dismiss];
              
              if (responseObject) {
                  // success in web service call return
                  [[AppDelegate sharedInstance] showAlertMessage:@"Ok" message:@"Updated" buttonTitle:@"Ok"];
                  [[AppDelegate sharedInstance] SDTechCalls:[AppDelegate sharedInstance].currentDate];
              }else{
                  // failure response
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }
     ];
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.keyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"detailInfoCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    }
    
    for (UIView *subView in cell.subviews){
        [subView removeFromSuperview];
    }
    
    //alternate background color
    if( [indexPath row] % 2)
        [cell setBackgroundColor:[UIColor whiteColor]];
    else
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    //left-side title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, cell.frame.size.height)];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = self.keyList[indexPath.row];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor darkGrayColor];
    [cell addSubview:titleLabel];
    
    //right-side value text field
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, cell.frame.size.width-110, cell.frame.size.height)];
    textField.delegate = self;
    textField.font = contentFont;
    textField.tag = indexPath.row;

    //value extract
    id value;
    if ([self.actionKeyWord isEqualToString:@"Modify"])
        value = self.dataObject[titleLabel.text];
    else
        value = tempDict[titleLabel.text];

    if([self.keyWord isEqualToString:@"Equip"]){
        if (indexPath.row >= 8 && indexPath.row <= 11) {
            //time setting button for "InstallationDate", "LastRepairDate", "ManufactureWarrantyDate", "ExtendedWarrantyDate"
            UIButton *timeBtn = [[UIButton alloc] initWithFrame:CGRectMake(110, 0, cell.frame.size.width-110, cell.frame.size.height)];
            timeBtn.tag = indexPath.row;
            [timeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [timeBtn addTarget:self action:@selector(TimeSetting:) forControlEvents:UIControlEventTouchUpInside];

            NSArray *stringComponents = [value componentsSeparatedByString:@"T"];
            NSString *dateString;
            if (stringComponents && stringComponents.count > 0)
                dateString = [stringComponents objectAtIndex:0];

            if (dateString || [dateString isEqualToString:@""])
                [timeBtn setTitle:dateString forState:UIControlStateNormal];
            else
                [timeBtn setTitle:@"Select Time" forState:UIControlStateNormal];

            [cell addSubview:timeBtn];
        }else if (indexPath.row == 7 || indexPath.row == 12){
            //switch for "OurInstallation" / "IsEquipmentAttachedToCall" setting
            UISwitch *optionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(110, 0, 10, 10)];
            optionSwitch.tag = indexPath.row;
            optionSwitch.on = NO;
            [optionSwitch addTarget:self action:@selector(SwitchOption:) forControlEvents:UIControlEventValueChanged];
            
            if (value && [value isKindOfClass:[NSString class]]
                      && [value isEqualToString:@"Y"])
                [optionSwitch setOn:YES];
            else
                [optionSwitch setOn:NO];
            
            [cell addSubview:optionSwitch];
        }else{
            if (value && [value isKindOfClass:[NSString class]])
                textField.text = self.dataObject[titleLabel.text];
            else
                textField.text = @"";
            
            [cell addSubview:textField];
        }
    }else{
        if (value && [value isKindOfClass:[NSString class]])
            textField.text = self.dataObject[titleLabel.text];
        else
            textField.text = @"";
        
        [cell addSubview:textField];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextField & UITextView Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag > 5) {
        [self keyboardWillShow];
    }
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    NSInteger selectedIndex = textField.tag;
//    NSString *selectedKey =  self.keyList[selectedIndex];
//    [tempDict setObject:textField.text forKey:selectedKey];
//    
//    [textField resignFirstResponder];
//    return YES;
//}

//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    NSInteger selectedIndex = textField.tag;
//    NSString *selectedKey =  self.keyList[selectedIndex];
//    [tempDict setObject:textField.text forKey:selectedKey];
//
//    if (textField.tag > 5) {
//        [self keyboardWillHide];
//    }
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger selectedIndex = textField.tag;
    NSString *selectedKey =  self.keyList[selectedIndex];
    [tempDict setObject:[NSString stringWithFormat:@"%@%@", textField.text, string] forKey:selectedKey];

    if (textField.tag > 5) {
        [self keyboardWillHide];
    }

    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        //        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0){
        //        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp){
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_KEYBOARD;
    }
    else{
        // revert back to the normal state.
        rect.origin.y += kOFFSET_KEYBOARD;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end