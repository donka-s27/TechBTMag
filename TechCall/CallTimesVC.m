//
//  SecondViewController.m
//  TechCall
//
//  Created by Maverics on 7/18/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "CallTimesVC.h"
#import "AppDelegate.h"

@interface CallTimesVC (){
    IBOutlet UITextField *dispatchTimeLabel, *arrivalTimeLabel, *completionTimeLabel, *invoiceLabel;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIButton *outcomeCodeBtn, *rescheduleTechBtn, *rescheduleTimeBtn;
    IBOutlet UISwitch *rescheduleCallSwitch;
    IBOutlet UIView *dataPickView;
    IBOutlet UIPickerView *dataPicker;
    IBOutlet UIDatePicker *datePicker;
    
    NSMutableArray *outcomeCodeList, *techList;
    NSString *pickerKey, *occValue, *rescheduleDate, *rescheduleTechId;
    NSString *dispTime, *arrivalTime, *compTime;
    
    UIFont *defaultFont, *contentFont;
}

@end

@implementation CallTimesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUIContents];
    [self setupNavigationBar];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initiCallTimes];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUIContents{
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];

    NSString *smFirstName = self.callInfoDict[@"Call"][@"ServiceMaster"][@"FirstName"];
    NSString *smLastName = self.callInfoDict[@"Call"][@"ServiceMaster"][@"FirstName"];
    NSString *title = [NSString stringWithFormat:@"%@ %@ Call# %@",
                       smFirstName ? smFirstName : @"",
                       smLastName ? smLastName : @"",
                       self.callInfoDict[@"Call"][@"Id"] ? self.callInfoDict[@"Call"][@"Id"] : @""];
    NSArray *stringComponents = [self.callInfoDict[@"ServiceDate"] componentsSeparatedByString:@"T"];
    NSString *serviceDate;
    if (stringComponents && stringComponents.count > 0)
        serviceDate = [stringComponents objectAtIndex:0];

    titleLabel.text = title;
    titleLabel.font = defaultFont;
    
    dispatchTimeLabel.text = [self changeTimeModeFormat:self.callInfoDict[@"DispatchTime"]];
    arrivalTimeLabel.text = [self changeTimeModeFormat:self.callInfoDict[@"ArrivalTime"]];
    completionTimeLabel.text = [self changeTimeModeFormat:self.callInfoDict[@"CompletionTime"]];
    invoiceLabel.text = self.callInfoDict[@"Call"][@"Invoice"][@"Id"];
    [rescheduleTimeBtn setTitle:serviceDate forState:UIControlStateNormal];
    [outcomeCodeBtn setTitle:self.callInfoDict[@"Call"][@"OutcomeCode"] forState:UIControlStateNormal];
    
    dispatchTimeLabel.font = contentFont;
    arrivalTimeLabel.font = contentFont;
    completionTimeLabel.font = contentFont;
    invoiceLabel.font = contentFont;
    rescheduleTimeBtn.titleLabel.font = contentFont;
    outcomeCodeBtn.titleLabel.font = contentFont;
    
    outcomeCodeList = [AppDelegate sharedInstance].setupInfo[@"OutcomeCodes"];
    techList = [AppDelegate sharedInstance].setupInfo[@"MyTeam"];
    [dataPicker reloadAllComponents];

    if ([self.callInfoDict[@"Call"][@"OutcomeCode"] isEqualToString:@"COM"]){
        [rescheduleCallSwitch setOn:NO];
        [rescheduleCallSwitch setUserInteractionEnabled:NO];
    }else{
        [rescheduleCallSwitch setUserInteractionEnabled:YES];
    }
    
    if (!rescheduleCallSwitch.on) {
        [rescheduleTimeBtn setUserInteractionEnabled:NO];
        [rescheduleTechBtn setUserInteractionEnabled:NO];
    }
    
    if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"A"]) {
        
    }else if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"D"]) {
        [dispatchTimeLabel setUserInteractionEnabled:YES];
    }else if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"P"]) {
        [arrivalTimeLabel setUserInteractionEnabled:YES];
    }else if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"C"]) {
        [completionTimeLabel setUserInteractionEnabled:YES];
    }
}

- (void)setupNavigationBar{
    NSString *barButtonItemTitle;
    if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"A"]) {
        barButtonItemTitle = @"Dispatch Now!";
    }else if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"D"]) {
        barButtonItemTitle = @"Arrive Now!";
    }else if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"P"]) {
        barButtonItemTitle = @"Complete Now!";
    }else if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"C"]) {
        barButtonItemTitle = @"Save!";
    }
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:barButtonItemTitle style:UIBarButtonItemStylePlain target:self action:@selector(UpdateCall:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

- (NSString*)changeTimeModeFormat:(NSString*)timeString{
    NSString *result = @"00:00 AM";
    
    if(timeString && timeString.length > 5){
        result = [timeString substringToIndex:5];

        NSString *hourPart = [result substringToIndex:2];
        NSString *minPart = [result substringFromIndex:3];
        int fixedHourValue = [hourPart intValue];
        int fixedMinValue = [minPart intValue];
        
        if (fixedHourValue > 12) {
            fixedHourValue = fixedHourValue - 12;
            result = [NSString stringWithFormat:@"%d:%d PM", fixedHourValue, fixedMinValue];

            if (fixedHourValue < 10)
                result = [NSString stringWithFormat:@"0%d:%d PM", fixedHourValue, fixedMinValue];
            
            if (fixedMinValue < 10)
                result = [NSString stringWithFormat:@"%d:0%d PM", fixedHourValue, fixedMinValue];
        }else{
            result = [NSString stringWithFormat:@"%@ AM", result];
        }
    }
    
    return result;
}

#pragma mark - IBAction

- (IBAction)CancelDataPicker:(id)sender{
    [dataPickView setHidden:YES];
    [datePicker setHidden:YES];
}

- (IBAction)SetDataPicker:(id)sender{
    if ([pickerKey isEqualToString:@"OCC"]){
        [outcomeCodeBtn setTitle:occValue forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"RSD"]){
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        rescheduleDate = [df stringFromDate:datePicker.date];
        
        [rescheduleTimeBtn setTitle:rescheduleDate forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"RST"]){
        [rescheduleTechBtn setTitle:rescheduleTechId forState:UIControlStateNormal];
    }
    
    [dataPickView setHidden:YES];
    [datePicker setHidden:YES];
}

- (IBAction)SetOutComeCode:(id)sender{
    pickerKey = @"OCC";
    if (![self.callInfoDict[@"Call"][@"OutcomeCode"] isEqualToString:@"COM"]){
        [dataPickView setHidden:NO];
        
        [datePicker setHidden:YES];
        [dataPicker setHidden:NO];

        [dataPicker reloadAllComponents];
    }
}

- (IBAction)SetRescheduleDate:(id)sender{
    pickerKey = @"RSD";
    [dataPickView setHidden:NO];
    
    [datePicker setHidden:NO];
    [dataPicker setHidden:YES];
}

- (IBAction)SetRescheduleTech:(id)sender{
    pickerKey = @"RST";
    [dataPickView setHidden:NO];
    
    [datePicker setHidden:YES];
    [dataPicker setHidden:NO];
    
    [dataPicker reloadAllComponents];
}

- (IBAction)SetRescheduleOption:(UISwitch*)sender{
    if(sender.on){
        [rescheduleTimeBtn setUserInteractionEnabled:YES];
        [rescheduleTechBtn setUserInteractionEnabled:YES];
    }else{
        [rescheduleTimeBtn setUserInteractionEnabled:NO];
        [rescheduleTechBtn setUserInteractionEnabled:NO];
    }
}

- (IBAction)UpdateCall:(id)sender{
    [self updateInformation];
}

#pragma mark - Webservice
- (void)updateInformation{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALLTIMES];
    NSMutableDictionary *paramDict;
    
    NSArray *stringComponent;
    NSString *simpleFormatDate;
    stringComponent = [self.callInfoDict[@"ServiceDate"] componentsSeparatedByString:@"T"];
    if (stringComponent && stringComponent.count > 0)
        simpleFormatDate = [stringComponent objectAtIndex:0];

    if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"A"]) {
        if (self.callInfoDict[@"DispatchTime"])
            dispTime = self.callInfoDict[@"DispatchTime"];
        
        paramDict = [NSMutableDictionary dictionaryWithDictionary:@{@"CallNum" : self.callInfoDict[@"Call"][@"Id"],
                                                        @"CallSeqNum" : self.callInfoDict[@"Sequence"],
                                                        @"ServiceDate" : simpleFormatDate,
                                                        @"CallStatus" : @"D",
                                                        @"TimeToUpdate": dispTime}];
        

    }else if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"D"]) {
        if (self.callInfoDict[@"ArrivalTime"])
            arrivalTime = self.callInfoDict[@"ArrivalTime"];

        paramDict = [NSMutableDictionary dictionaryWithDictionary:@{@"CallNum" : self.callInfoDict[@"Call"][@"Id"],
                                                        @"CallSeqNum" : self.callInfoDict[@"Sequence"],
                                                        @"ServiceDate" : simpleFormatDate,
                                                        @"CallStatus" : @"P",
                                                        @"Invoice" : self.callInfoDict[@"Call"][@"Invoice"][@"Id"],
                                                        @"TimeToUpdate": arrivalTime}];

    }else if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"P"]) {
        if (self.callInfoDict[@"CompletionTime"])
            compTime = self.callInfoDict[@"CompletionTime"];

        paramDict = [NSMutableDictionary dictionaryWithDictionary:@{@"CallNum" : self.callInfoDict[@"Call"][@"Id"],
                                                        @"CallSeqNum" : self.callInfoDict[@"Sequence"],
                                                        @"ServiceDate" : simpleFormatDate,
                                                        @"CallStatus" : @"C",
                                                        @"Invoice" : self.callInfoDict[@"Call"][@"Invoice"][@"Id"],
                                                        @"TimeToUpdate": compTime,
                                                        @"Outcome": self.callInfoDict[@"Call"][@"OutcomeCode"]}];
        
    }else if ([self.callInfoDict[@"TechCallStatus"] isEqualToString:@"C"]) {
        if (self.callInfoDict[@"CompletionTime"])
            compTime = self.callInfoDict[@"CompletionTime"];

        paramDict = [NSMutableDictionary dictionaryWithDictionary:@{@"CallNum" : self.callInfoDict[@"Call"][@"Id"],
                                                                    @"CallSeqNum" : self.callInfoDict[@"Sequence"],
                                                                    @"ServiceDate" : simpleFormatDate,
                                                                    @"CallStatus" : @"C",
                                                                    @"Invoice" : self.callInfoDict[@"Call"][@"Invoice"][@"Id"],
                                                                    @"TimeToUpdate": compTime,
                                                                    @"Outcome": self.callInfoDict[@"Call"][@"OutcomeCode"]}];
    }
    
    if (![self.callInfoDict[@"Call"][@"OutcomeCode"] isEqualToString:@"COM"]
        && [rescheduleCallSwitch isOn]){
        [paramDict setObject:[NSNumber numberWithBool:rescheduleCallSwitch.on] forKey:@"RescheduleCall"];
        [paramDict setObject:rescheduleDate forKey:@"RescheduleDate"];
        [paramDict setObject:rescheduleTechId forKey:@"RescheduleTech"];
    }

    NSLog(@"%@", paramDict);
    [manager POST:urlString
       parameters:paramDict
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [SVProgressHUD dismiss];
              
              if (responseObject) {
                  // success in web service call return
                  if ([responseObject[@"AllowToChangeTime"] boolValue] &&
                      [responseObject[@"TechCallStatus"] isEqualToString:@"C"]) {
                      [completionTimeLabel setUserInteractionEnabled:YES];
                  }else{
                      [completionTimeLabel setUserInteractionEnabled:NO];
                  }
                  
                  if ([responseObject[@"AllowToChangeTime"] boolValue] &&
                      [responseObject[@"TechCallStatus"] isEqualToString:@"P"]) {
                      [arrivalTimeLabel setUserInteractionEnabled:YES];
                  }else{
                      [arrivalTimeLabel setUserInteractionEnabled:NO];
                  }
                  
                  if ([responseObject[@"AllowToModifyInvoice"] boolValue]) {
                      [invoiceLabel setUserInteractionEnabled:YES];
                  }else{
                      [invoiceLabel setUserInteractionEnabled:NO];
                  }

                  if ([responseObject[@"AllowToPickOCCode"] boolValue]) {
                      [outcomeCodeBtn setUserInteractionEnabled:YES];
                  }else{
                      [outcomeCodeBtn setUserInteractionEnabled:NO];
                  }
                  
                  if ([responseObject[@"TechCallStatus"] isEqualToString:@"D"]) {
                      dispTime = responseObject[@"TimeToSet"];
                      [dispatchTimeLabel setText:[self changeTimeModeFormat:dispTime]];
                  }else if ([responseObject[@"TechCallStatus"] isEqualToString:@"P"]) {
                      arrivalTime = responseObject[@"TimeToSet"];
                      [arrivalTimeLabel setText:[self changeTimeModeFormat:arrivalTime]];
                  }else if ([responseObject[@"TechCallStatus"] isEqualToString:@"C"]) {
                      compTime = responseObject[@"TimeToSet"];
                      [completionTimeLabel setText:[self changeTimeModeFormat:compTime]];
                  }else if ([responseObject[@"TechCallStatus"] isEqualToString:@"X"]){
                      arrivalTime = responseObject[@"ArriveTime"];
                      compTime = responseObject[@"CompleteTime"];
                      dispTime = responseObject[@"DispatchTime"];
                      
                      [arrivalTimeLabel setText:[self changeTimeModeFormat:responseObject[@"ArriveTime"]]];
                      [completionTimeLabel setText:[self changeTimeModeFormat:responseObject[@"CompleteTime"]]];
                      [dispatchTimeLabel setText:[self changeTimeModeFormat:responseObject[@"DispatchTime"]]];
                  }
                  
                  [invoiceLabel setText:responseObject[@"InvoiceNum"]];
                  [outcomeCodeBtn setTitle:responseObject[@"OutcomeCode"] forState:UIControlStateNormal];
                  
                  [[AppDelegate sharedInstance] showAlertMessage:@"Ok" message:@"Updated" buttonTitle:@"Ok"];
              }else{
                  // failure response
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", operation.responseObject);
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }
     ];
}

- (void)initiCallTimes{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALLTIMES];
    [manager GET:urlString
      parameters:@{@"CallNumber" : self.callInfoDict[@"Call"][@"Id"],
                   @"CallSequence" : self.callInfoDict[@"Sequence"]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 if ([responseObject[@"AllowToChangeTime"] boolValue] &&
                     [responseObject[@"TechCallStatus"] isEqualToString:@"C"]) {
                     [completionTimeLabel setUserInteractionEnabled:YES];
                 }else{
                     [completionTimeLabel setUserInteractionEnabled:NO];
                 }
                 
                 if ([responseObject[@"AllowToChangeTime"] boolValue] &&
                     [responseObject[@"TechCallStatus"] isEqualToString:@"P"]) {
                     [arrivalTimeLabel setUserInteractionEnabled:YES];
                 }else{
                     [arrivalTimeLabel setUserInteractionEnabled:NO];
                 }
                 
                 if ([responseObject[@"AllowToModifyInvoice"] boolValue]) {
                     [invoiceLabel setUserInteractionEnabled:YES];
                 }else{
                     [invoiceLabel setUserInteractionEnabled:NO];
                 }
                 
                 if ([responseObject[@"AllowToPickOCCode"] boolValue]) {
                     [outcomeCodeBtn setUserInteractionEnabled:YES];
                 }else{
                     [outcomeCodeBtn setUserInteractionEnabled:NO];
                 }
                 
                 if ([responseObject[@"TechCallStatus"] isEqualToString:@"D"]) {
                     dispTime = responseObject[@"TimeToSet"];
                     [dispatchTimeLabel setText:[self changeTimeModeFormat:dispTime]];
                 }else if ([responseObject[@"TechCallStatus"] isEqualToString:@"P"]) {
                     arrivalTime = responseObject[@"TimeToSet"];
                     [arrivalTimeLabel setText:[self changeTimeModeFormat:arrivalTime]];
                 }else if ([responseObject[@"TechCallStatus"] isEqualToString:@"C"]) {
                     compTime = responseObject[@"TimeToSet"];
                     [completionTimeLabel setText:[self changeTimeModeFormat:compTime]];
                 }else if ([responseObject[@"TechCallStatus"] isEqualToString:@"X"]){
                     arrivalTime = responseObject[@"ArriveTime"];
                     compTime = responseObject[@"CompleteTime"];
                     dispTime = responseObject[@"DispatchTime"];
                     
                     [arrivalTimeLabel setText:[self changeTimeModeFormat:responseObject[@"ArriveTime"]]];
                     [completionTimeLabel setText:[self changeTimeModeFormat:responseObject[@"CompleteTime"]]];
                     [dispatchTimeLabel setText:[self changeTimeModeFormat:responseObject[@"DispatchTime"]]];
                 }
                 
                 [invoiceLabel setText:responseObject[@"InvoiceNum"]];
                 [outcomeCodeBtn setTitle:responseObject[@"OutcomeCode"] forState:UIControlStateNormal];
             }else{
                 // failure response
                 [SVProgressHUD dismiss];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
         }
     ];
}

#pragma mark - UIPickerView Deleage & Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerKey isEqualToString:@"OCC"]){
        return outcomeCodeList.count;
    }else if ([pickerKey isEqualToString:@"RST"]){
        NSLog(@"%@", techList);
        return techList.count;
    }
    return 0;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if ([pickerKey isEqualToString:@"OCC"]){
        NSDictionary *outcomeCode = outcomeCodeList[row];
        if (outcomeCode[@"OcType"] == [NSNull null]) {
            return @"none";
        }
        return outcomeCode[@"OcType"];
    }else if ([pickerKey isEqualToString:@"RST"]){
        NSDictionary *techCode = techList[row];
        if (techCode[@"Id"] == [NSNull null]) {
            return @"none";
        }
        return techCode[@"Id"];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if ([pickerKey isEqualToString:@"OCC"]){
        NSDictionary *outcomeCode = outcomeCodeList[row];
        occValue = outcomeCode[@"OcType"];
    }else if ([pickerKey isEqualToString:@"RST"]){
        NSDictionary *techCode = techList[row];
        rescheduleTechId = techCode[@"Id"];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
