//
//  QuoteDetailVC.m
//  TechCall
//
//  Created by Maverics on 9/21/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "QuoteDetailVC.h"
#import "AppDelegate.h"
#import "QuoteDetail_DetailItemsVC.h"
#import "QuoteDetail_SignVC.h"
#import "QuoteDetail_PictureVC.h"

@implementation QuoteDetailVC{
    IBOutlet UIScrollView *mainScrView;
    IBOutlet UITextField *IDField, *givenToField, *jobNameField, *InvSubTotalField, *discoutField, *taxField, *totalField;
    IBOutlet UILabel *taxTypeLabel;
    IBOutlet UITextView *jobDescTxtView;
    IBOutlet UIButton *serviceTypeBtn, *quoteDateBtn ,*priceSheetLaborBtn, *priceSheetMatBtn, *taxCodeBtn;
    IBOutlet UIButton *detailItemsBtn, *signBtn, *pictureBtn, *emailBtn;
    
    IBOutlet UIView *dataPickView;
    IBOutlet UIPickerView *dataPicker;
    IBOutlet UIDatePicker *datePicker;
    
    NSMutableArray *pickerContent;
    NSString *pickerKey;
    NSString *serviceType, *quoteDate, *priceSheetLaborType, *priceSheetMatType, *taxCodeType;
    NSMutableDictionary *updateParam, *pickedValue;
    
    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];

    [self setupScrollView];
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(updateQuoteMaster)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;

    if ([self.actionKey isEqualToString:@"Modify"]) {
        [self setupUIContents];
        
        updateParam = [self.dataObject mutableCopy];
//        [updateParam setObject:self.dataObject[@"Id"] forKey:@"Id"];
    }else{
        updateParam = [[NSMutableDictionary alloc] init];

        [updateParam setObject:@"-1" forKey:@"Id"];
        [updateParam setObject:@{@"Id": [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Id"]} forKey:@"ServiceMaster"];
        
        [detailItemsBtn setUserInteractionEnabled:NO];
        [signBtn setUserInteractionEnabled:NO];
        [pictureBtn setUserInteractionEnabled:NO];
        [emailBtn setUserInteractionEnabled:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)setupScrollView{
    // main scroll view
    [mainScrView setScrollEnabled:YES];
    [mainScrView setPagingEnabled:NO];
    [mainScrView setContentSize:CGSizeMake(1.0, 700)];
}

- (void)setupUIContents{
    NSArray *stringComponent = [self.dataObject[@"CreationDate"] componentsSeparatedByString:@"T"];
    NSString *quoteCreationDate;
    if (stringComponent && stringComponent.count > 0)
        quoteCreationDate = [stringComponent objectAtIndex:0];

    NSDictionary *salesManInfo = self.dataObject[@"Salesman"];
    IDField.text = self.dataObject[@"Id"];
    givenToField.text = salesManInfo[@"Name"];
    [quoteDateBtn setTitle:quoteCreationDate forState:UIControlStateNormal];
    [serviceTypeBtn setTitle:self.dataObject[@"ServiceType"][@"Id"] forState:UIControlStateNormal];
    jobNameField.text = self.dataObject[@"Name"];
    jobDescTxtView.text = self.dataObject[@"Description"];
    InvSubTotalField.text = [self.dataObject[@"SubTotal"] stringValue];
    discoutField.text = [self.dataObject[@"Discount"] stringValue];
    taxTypeLabel.text = [NSString stringWithFormat:@"Tax [%@]", self.dataObject[@"TaxCode"][@"Id"]];
    
    double taxRate = [[self autoCalculateTax][@"TaxRate"] doubleValue];
    double taxValue = [InvSubTotalField.text doubleValue] / 100 * taxRate;
    taxField.text = [NSString stringWithFormat:@"%f", taxValue];
    
    totalField.text = [self.dataObject[@"Total"] stringValue];
    [priceSheetLaborBtn setTitle:self.dataObject[@"PriceSheetLabor"][@"PriceCode"][@"Id"] forState:UIControlStateNormal];
    [priceSheetMatBtn setTitle:self.dataObject[@"PriceSheetMaterial"][@"PriceCode"][@"Id"] forState:UIControlStateNormal];
    
    IDField.font = contentFont;
    givenToField.font = contentFont;
    jobNameField.font = contentFont;
    jobDescTxtView.font = contentFont;
    InvSubTotalField.font = contentFont;
    discoutField.font = contentFont;
    taxTypeLabel.font = contentFont;
    taxField.font = contentFont;
    [quoteDateBtn.titleLabel setFont:contentFont];
    [quoteDateBtn.titleLabel setFont:contentFont];
    [priceSheetLaborBtn.titleLabel setFont:contentFont];
    [priceSheetMatBtn.titleLabel setFont:contentFont];
}

- (void)setupParam{
    [updateParam setObject:jobNameField.text forKey:@"Name"];
    [updateParam setObject:jobDescTxtView.text forKey:@"Description"];

    NSString *totalPriceString = totalField.text;
    if(totalPriceString && ![totalPriceString isEqualToString:@""])
        [updateParam setObject:[NSNumber numberWithDouble:[totalPriceString doubleValue]] forKey:@"Total"];
    
    if(quoteDate && ![quoteDate isEqualToString:@""])
        [updateParam setObject:quoteDate forKey:@"CreationDate"];
    
    if(taxCodeType && ![taxCodeType isEqualToString:@""])
        [updateParam setObject:@{@"Id": taxCodeType} forKey:@"TaxCode"];

    if(serviceType && ![serviceType isEqualToString:@""])
        [updateParam setObject:@{@"Id": serviceType} forKey:@"ServiceType"];
    
    if(priceSheetLaborType && ![priceSheetLaborType isEqualToString:@""])
        [updateParam setObject:@{@"Sequence": @"0", @"PriceCode": @{@"Id": priceSheetLaborType}} forKey:@"PriceSheetLabor"];
    
    if(priceSheetMatType && ![priceSheetMatType isEqualToString:@""])
        [updateParam setObject:@{@"isSigned": @"false", @"PriceCode": @{@"Id": priceSheetMatType}} forKey:@"PriceSheetMaterial"];
}

- (NSDictionary*)autoCalculateTax{
    NSDictionary *taxObject;
    NSMutableArray *taxCodeList = [AppDelegate sharedInstance].setupInfo[@"TaxCodes"];

    for(int i=0; i<taxCodeList.count; i++){
        NSDictionary *tempObject = taxCodeList[i];
        if ([tempObject[@"Id"] isEqualToString:self.dataObject[@"TaxCode"][@"Id"]]) {
            taxObject = tempObject;
        }
    }
    
    return taxObject;
}

#pragma mark - Webservice

- (void)updateQuoteMaster{
    [SVProgressHUD show];
    [self setupParam];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, QUOTE_MASTER];
    NSLog(@"update param = %@", updateParam);
    
    [manager POST:urlString
       parameters:updateParam
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

#pragma mark - IBAction

- (IBAction)CancelDataPicker:(id)sender{
    [dataPickView setHidden:YES];
}

- (IBAction)SetDataPicker:(id)sender{
    if ([pickerKey isEqualToString:@"ServiceType"]) {
        serviceType = pickedValue[@"Id"];
        [serviceTypeBtn setTitle:serviceType forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"PriceSheetLabor"]) {
        priceSheetLaborType = pickedValue[@"Id"];
        [priceSheetLaborBtn setTitle:priceSheetLaborType forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"PriceSheetMaterial"]) {
        priceSheetMatType = pickedValue[@"Id"];
        [priceSheetMatBtn setTitle:priceSheetMatType forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"QuoteDate"]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        quoteDate = [df stringFromDate:datePicker.date];
        
        [quoteDateBtn setTitle:quoteDate forState:UIControlStateNormal];
        [datePicker setHidden:YES];
    }else if ([pickerKey isEqualToString:@"TaxCode"]) {
        taxCodeType = pickedValue[@"Id"];
        [taxTypeLabel setText:[NSString stringWithFormat:@"Tax [%@ %@%%]", pickedValue[@"Id"], pickedValue[@"TaxRate"]]];
    }
    
    [dataPickView setHidden:YES];
}

- (IBAction)SetSelectType:(id)sender{
    [dataPickView setHidden:NO];
    [datePicker setHidden:YES];
    pickerContent = [AppDelegate sharedInstance].setupInfo[@"ServiceTypes"];
    pickerKey = @"ServiceType";
    [dataPicker reloadAllComponents];
}

- (IBAction)SetQuoteDate:(id)sender{
    [dataPickView setHidden:NO];    
    [datePicker setHidden:NO];
    pickerKey = @"QuoteDate";
}

- (IBAction)SetTaxCode:(id)sender{
    [dataPickView setHidden:NO];
    [datePicker setHidden:YES];
    pickerContent = [AppDelegate sharedInstance].setupInfo[@"TaxCodes"];
    pickerKey = @"TaxCode";
    [dataPicker reloadAllComponents];
}

- (IBAction)SetPriceSheetLabor:(id)sender{
    [dataPickView setHidden:NO];
    [datePicker setHidden:YES];
    pickerContent = [AppDelegate sharedInstance].setupInfo[@"PriceSheets"];
    pickerKey = @"PriceSheetLabor";
    [dataPicker reloadAllComponents];
}

- (IBAction)PriceSheetMaterial:(id)sender{
    [dataPickView setHidden:NO];
    [datePicker setHidden:YES];
    pickerContent = [AppDelegate sharedInstance].setupInfo[@"PriceSheets"];
    pickerKey = @"PriceSheetMaterial";
    [dataPicker reloadAllComponents];
}

- (IBAction)Detail:(id)sender{
    QuoteDetail_DetailItemsVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"QuoteDetail_DetailItemsVC"];
    dest.quoteDetailList = self.dataObject[@"Items"];
    dest.quoteMaster = self.dataObject;
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Signature:(id)sender{
    QuoteDetail_SignVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"QuoteDetail_SignVC"];
    dest.quoteObject = self.dataObject;
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Picture:(id)sender{
    QuoteDetail_PictureVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"QuoteDetail_PictureVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Email:(id)sender{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Sample Subject"];
        [mail setMessageBody:@"Here is some main text in the email!" isHTML:NO];
        [mail setToRecipients:@[@"testingEmail@example.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

#pragma mark - MFMailComposeViewController Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextField & UITextView Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    textView.text = @"";
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark - UIPickerView Deleage & Datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerContent.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *pickData = pickerContent[row];
    
    if (pickData[@"Id"] == [NSNull null]) {
        return @"none";
    }
    return pickData[@"Id"];

//    if ([pickerKey isEqualToString:@"ServiceType"]) {
//        if (pickData[@"Id"] == [NSNull null]) {
//            return @"none";
//        }
//        return pickData[@"Id"];
//    }else if ([pickerKey isEqualToString:@"PriceSheetLabor"]) {
//        if (pickData[@"Id"] == [NSNull null]) {
//            return @"none";
//        }
//        return pickData[@"Id"];
//    }else if ([pickerKey isEqualToString:@"PriceSheetMaterial"]) {
//        if (pickData[@"Id"] == [NSNull null]) {
//            return @"none";
//        }
//        return pickData[@"Id"];
//    }else if ([pickerKey isEqualToString:@"TaxCode"]) {
//        if (pickData[@"Id"] == [NSNull null]) {
//            return @"none";
//        }
//        return pickData[@"Id"];
//    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSDictionary *pickData = pickerContent[row];
    pickedValue = [pickData mutableCopy];

//    if ([pickerKey isEqualToString:@"ServiceType"]) {
//        if (pickData[@"Id"] == [NSNull null]) {
//            pickedValue = @"none";
//        }
//        pickedValue = pickData[@"Id"];
//    }else if ([pickerKey isEqualToString:@"PriceSheetLabor"]) {
//        if (pickData[@"Id"] == [NSNull null]) {
//            pickedValue = @"none";
//        }
//        pickedValue = pickData[@"Id"];
//    }else if ([pickerKey isEqualToString:@"PriceSheetMaterial"]) {
//        if (pickData[@"Id"] == [NSNull null]) {
//            pickedValue = @"none";
//        }
//        pickedValue = pickData[@"Id"];
//    }
}

@end

