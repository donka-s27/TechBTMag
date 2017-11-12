//
//  CallBookVC.m
//  TechCall
//
//  Created by Maverics on 9/28/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "CallBookVC.h"
#import "AppDelegate.h"

@implementation CallBookVC{
    IBOutlet UITextField *personCallTxtField, *contactPhoneTxtField, *callPOTxtField;
    IBOutlet UITextView *callReasonTxtView, *specInstTxtView;
    IBOutlet UIButton *taskCodeBtn, *serviceTypeBtn, *timePromisedBtn, *sourceCodeBtn, *breakBtn1, *breakBtn2;

    IBOutlet UIPickerView *valuePicker;
    IBOutlet UIScrollView *mainScrView;
    
    NSString *pickerKey;
    NSMutableArray *pickerContents;
    NSDictionary *tcDict, *stDict, *tpDict, *scDict, *brDict1, *brDict2;
}

- (void)viewDidLoad{
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(callBook)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    [self setupScrollView];
    [self setupUIContents];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)setupScrollView{
    // main scroll view
    [mainScrView setScrollEnabled:YES];
    [mainScrView setPagingEnabled:NO];
    [mainScrView setContentSize:CGSizeMake(1.0, 600)];
}

- (void)setupUIContents{
    personCallTxtField.text = _smInfo[@"DisplayName"];
    contactPhoneTxtField.text = _smInfo[@"HomePhone"];

    NSLog(@"break inforamtion = %@", _smInfo[@"GLBreak"]);
    NSLog(@"appdelegate inforamtion = %@", [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"GLBreak"]);
    
    [serviceTypeBtn setTitle:_smInfo[@"ServiceType"] ? _smInfo[@"ServiceType"] : @"Select" forState:UIControlStateNormal];
    [breakBtn1 setTitle:_smInfo[@"GLBreak"][@"Break1Value"] ? _smInfo[@"GLBreak"][@"Break1Value"] : @"Select" forState:UIControlStateNormal];
    [breakBtn2 setTitle:_smInfo[@"GLBreak"][@"Break2Value"] ? _smInfo[@"GLBreak"][@"Break2Value"] : @"Select" forState:UIControlStateNormal];
}

/*
{"PersonCalling":"Luis", , "ServiceType": "COM", "SpecialInstructions": "Special INstruction", "ServiceMasterId" : "52",  "Source": "X","PO":"", }
 
 
DIFFERENT WITH UI
 "ProblemDescription": "This is problem descr"  ->  ReasonForCall
 "DatePromised": "2016-09-04T23:28:56.782Z"     ->  CurrentDate
 "TechnicianId":"100",                          ->  Empty
 "QuoteNumber":"",                              ->  Empty
 "BookCallTo":"100"                             ->  Empty
 "CustomerNumber":50,                           ->  ServiceMaster[BillTo][Id]
 "ContactPhoneNumberType": "H",                 ->  H
 "ContactPerson": "My Contact",                 ->  personCalling TextField
 "ContactPhoneNumber": "321123123",             ->  contactPhone TextField
 "Location":"01",                               ->  ServiceMaster[Break1]
 "Division":"01",                               ->  ServiceMaster[Break2]
 "Function":"TXT",                              ->  TaskCode[FunctionCode]
 "Component":"ASD",                             ->  TaskCode[ComponentCode]
 
DIFFERENT VALUE FORAMT
"TimePromised":"2016-09-04T23:28:56.782Z"       ->  TimePromised[Id]
 
*/
- (NSMutableDictionary*)setupParam{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];

    [param setObject:_smInfo[@"Id"] forKey:@"ServiceMasterId"];
    [param setObject:_smInfo[@"BillTo"][@"Id"] forKey:@"CustomerNumber"];

    //setup information
    if (tcDict) {
        [param setObject:tcDict[@"FunctionCode"] forKey:@"Function"];
        [param setObject:tcDict[@"ComponentCode"] forKey:@"Component"];
    }

    if (stDict) {
        [param setObject:stDict[@"Id"] forKey:@"ServiceType"];
    }
    
    if (scDict) {
        [param setObject:scDict[@"Id"] forKey:@"Source"];
    }

    if (tpDict) {
        [param setObject:tpDict[@"Id"] forKey:@"TimePromised"];
    }

    if (brDict1) {
        [param setObject:brDict1[@"Id"] forKey:@"Location"];
    }else{
        [param setObject:_smInfo[@"GLBreak"][@"Break1Value"] forKey:@"Location"];
    }

    if (brDict2) {
        [param setObject:brDict2[@"Id"] forKey:@"Division"];
    }else{
        [param setObject:_smInfo[@"GLBreak"][@"Break2Value"] forKey:@"Division"];
    }


    //entered information
    [param setObject:personCallTxtField.text forKey:@"PersonCalling"];
    [param setObject:specInstTxtView.text forKey:@"SpecialInstructions"];
    [param setObject:callReasonTxtView.text forKey:@"ProblemDescription"];
    [param setObject:callPOTxtField.text forKey:@"PO"];
    [param setObject:personCallTxtField.text forKey:@"ContactPerson"];
    [param setObject:contactPhoneTxtField.text forKey:@"ContactPhoneNumber"];
    
    //current date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *todayString = [df stringFromDate:[NSDate date]];
    [param setObject:todayString forKey:@"CurrentDate"];
    [param setObject:todayString forKey:@"DatePromised"];

    //default information
    [param setObject:@"H" forKey:@"ContactPhoneNumberType"];
    [param setObject:@"" forKey:@"TechnicianId"];
    [param setObject:@"" forKey:@"QuoteNumber"];
    [param setObject:@"" forKey:@"BookCallTo"];

    return param;
}

- (void)loadPickerContent{
    if ([pickerKey isEqualToString:@"TC"]) {
        pickerContents = [AppDelegate sharedInstance].setupInfo[@"TaskCodes"];
    }else if ([pickerKey isEqualToString:@"ST"]) {
        pickerContents = [AppDelegate sharedInstance].setupInfo[@"ServiceTypes"];
    }else if ([pickerKey isEqualToString:@"TP"]) {
        pickerContents = [AppDelegate sharedInstance].setupInfo[@"TimesPromised"];
    }else if ([pickerKey isEqualToString:@"SC"]) {
        pickerContents = [AppDelegate sharedInstance].setupInfo[@"SourceCodes"];
    }else if ([pickerKey isEqualToString:@"BR1"]) {
        pickerContents = [AppDelegate sharedInstance].setupInfo[@"Breaks1"];
    }else if ([pickerKey isEqualToString:@"BR2"]) {
        pickerContents = [AppDelegate sharedInstance].setupInfo[@"Breaks2"];
    }
    [valuePicker setHidden:!valuePicker.hidden];
    [valuePicker reloadAllComponents];
}

#pragma mark - IBAction
- (IBAction)SetTaskCode:(id)sender{
    pickerKey = @"TC";
    [self loadPickerContent];
}

- (IBAction)SetServiceType:(id)sender{
    pickerKey = @"ST";
    [self loadPickerContent];
}

- (IBAction)SetTimePromised:(id)sender{
    pickerKey = @"TP";
    [self loadPickerContent];
}

- (IBAction)SetSourceCode:(id)sender{
    pickerKey = @"SC";
    [self loadPickerContent];
}

- (IBAction)SetBreak1:(id)sender{
    pickerKey = @"BR1";
    [self loadPickerContent];
}

- (IBAction)SetBreak2:(id)sender{
    pickerKey = @"BR2";
    [self loadPickerContent];
}


#pragma mark - UIPickerView Delegate & Datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerContents.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *pickObject = pickerContents[row];
    
    if ([pickerKey isEqualToString:@"TC"]) {
        return [NSString stringWithFormat:@"%@.%@", pickObject[@"FunctionCode"], pickObject[@"ComponentCode"]];
    }else if ([pickerKey isEqualToString:@"ST"]) {
        return pickObject[@"Id"];
    }else if ([pickerKey isEqualToString:@"TP"]) {
        return pickObject[@"Id"];
    }else if ([pickerKey isEqualToString:@"SC"]) {
        return pickObject[@"Id"];
    }else if ([pickerKey isEqualToString:@"BR1"]) {
        return pickObject[@"Name"];
    }else if ([pickerKey isEqualToString:@"BR2"]) {
        return pickObject[@"Name"];
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSDictionary *pickObject = pickerContents[row];

    if ([pickerKey isEqualToString:@"TC"]) {
        tcDict = pickObject;
        [taskCodeBtn setTitle:[NSString stringWithFormat:@"%@.%@", pickObject[@"FunctionCode"], pickObject[@"ComponentCode"]]forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"ST"]) {
        stDict = pickObject;
        [serviceTypeBtn setTitle:pickObject[@"Id"] forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"TP"]) {
        tpDict = pickObject;
        [timePromisedBtn setTitle:pickObject[@"Id"] forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"SC"]) {
        scDict = pickObject;
        [sourceCodeBtn setTitle:pickObject[@"Id"] forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"BR1"]) {
        brDict1 = pickObject;
        [breakBtn1 setTitle:pickObject[@"Name"] forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"BR2"]) {
        brDict2 = pickObject;
        [breakBtn2 setTitle:pickObject[@"Name"] forState:UIControlStateNormal];
    }

    [pickerView setHidden:YES];
}


#pragma mark - Webservice

- (void)callBook{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALLBOOK];
    NSLog(@"update param = %@", [self setupParam]);
    
    [manager POST:urlString
       parameters:[self setupParam]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [SVProgressHUD dismiss];
              
              if (responseObject) {
                  // success in web service call return
                  [[AppDelegate sharedInstance] showAlertMessage:@"Call" message:@"Booked" buttonTitle:@"Ok"];
              }else{
                  // failure response
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }
     ];
}


#pragma mark - UITextField & UITextView Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == callPOTxtField)
        [self keyboardWillShow];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == callPOTxtField)
        [self keyboardWillHide];
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
