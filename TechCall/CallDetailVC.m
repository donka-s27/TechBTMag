//
//  CallDetailVC.m
//  TechCall
//
//  Created by Maverics on 9/7/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "CallDetailVC.h"
#import "AppDelegate.h"
#import "CallPartsVC.h"
#import "CallPicturesVC.h"

@implementation CallDetailVC{
    UIScrollView *mainScrView;
    IBOutlet UITextView *probDescTxtView, *specInstTxtView;
    IBOutlet UIButton *serviceTypeBtn;
    IBOutlet UITextField *cpTxtField;
    IBOutlet UILabel *taskLabel, *sourceLabel, *quoteAmountLabel, *quotePriceLabel;
    
    IBOutlet UIButton *callPartsBtn, *purchaseOrderBtn, *callPictBtn, *taskListBtn, *documentBtn;
    
    IBOutlet UIView *contentPickView;
    IBOutlet UIPickerView *pickerView;
    
    NSMutableArray *serviceTypeList;
    NSString *pickValue;
    
    UIFont *defaultFont, *contentFont;
}

#pragma mark - Lifecycle methods

- (void)viewDidLoad{
    [super viewDidLoad];

    [self setupUI];
    [self setupUIContents];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)setupUI{
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(updateCallDetail)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    cpTxtField.delegate = self;
    probDescTxtView.delegate = self;
    specInstTxtView.delegate = self;
    
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];
    
    if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0){
        // Avoid the top UITextView space, iOS7 (~bug?)
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)setupUIContents{
    probDescTxtView.text = self.callInfoDict[@"Call"][@"ProblemDescription"];
    probDescTxtView.font = contentFont;
    specInstTxtView.text = self.callInfoDict[@"Call"][@"SpecialInstruction"];
    specInstTxtView.font = contentFont;
    
    pickValue = self.callInfoDict[@"Call"][@"ServiceType"];
    [serviceTypeBtn setTitle:pickValue forState:UIControlStateNormal];
    serviceTypeBtn.titleLabel.font = contentFont;
    
    cpTxtField.text = self.callInfoDict[@"Call"][@"PO"];
    cpTxtField.font = contentFont;
    taskLabel.text = self.callInfoDict[@"Call"][@"TaskCode"];
    taskLabel.font = contentFont;
    sourceLabel.text = self.callInfoDict[@"Call"][@"Source"];
    sourceLabel.font = contentFont;
    
    NSDictionary *quoteInfo = self.callInfoDict[@"Call"][@"Quote"];
    quoteAmountLabel.text = [NSString stringWithFormat:@"%@", quoteInfo[@"Id"]];
    quoteAmountLabel.font = contentFont;
    quotePriceLabel.text = [NSString stringWithFormat:@"%@", quoteInfo[@"Total"]];
    quotePriceLabel.font = contentFont;
    
    serviceTypeList = [AppDelegate sharedInstance].setupInfo[@"ServiceTypes"];
    NSLog(@"%@", serviceTypeList);
}

#pragma mark - IBAction
- (IBAction)CallParts:(id)sender{
    CallPartsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"CallPartsVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)PurchaseOrder:(id)sender{
    
}

- (IBAction)CallPictures:(id)sender{
    CallPicturesVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"CallPicturesVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)ServiceType:(id)sender{
    [contentPickView setHidden:NO];
}

- (IBAction)Select:(id)sender{
    [contentPickView setHidden:YES];
    [serviceTypeBtn setTitle:pickValue forState:UIControlStateNormal];
}

- (IBAction)Cancel:(id)sender{
    [contentPickView setHidden:YES];
    pickValue = self.callInfoDict[@"Call"][@"ServiceType"];
}

#pragma mark - Webservice
- (void)updateCallDetail{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALLMASTER];
    NSDictionary *tempDict = @{@"Id": self.callInfoDict[@"Call"][@"Id"],
                               @"ProblemDescription": probDescTxtView.text,
                               @"ServiceType": pickValue,
                               @"PO": cpTxtField.text,
                               @"SpecialInstructions": specInstTxtView.text};
    NSLog(@"update param = %@", tempDict);
    
    [manager PUT:urlString
       parameters:tempDict
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              [SVProgressHUD dismiss];
              
              if (responseObject) {
                  // success in web service call return
                  [[AppDelegate sharedInstance] showAlertMessage:@"Ok" message:@"Updated" buttonTitle:@"Ok"];
              }else{
                  // failure response
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              [SVProgressHUD dismiss];
          }
     ];
}

#pragma mark - UIPickerView Delegate & Datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return serviceTypeList.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *serviceType = serviceTypeList[row];
    NSString *temp = serviceType[@"Id"];
    return temp;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSDictionary *serviceType = serviceTypeList[row];
    pickValue = serviceType[@"Id"];
}

#pragma mark - UITextField & UITextView Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"])
        [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    
    return YES;
}

@end
