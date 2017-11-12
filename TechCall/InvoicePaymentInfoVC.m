//
//  InvoicePaymentInfoVC.m
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "InvoicePaymentInfoVC.h"
#import "ChargeCreditCardViewController.h"
#import "AppDelegate.h"

@implementation InvoicePaymentInfoVC{
    IBOutlet UILabel *titleLabel, *subTotalLabel, *discountLabel, *taxLabel, *totalLabel;
    IBOutlet UIButton *paymentMethodBtn1, *paymentMethodBtn2, *chargeCreditCardBtn1, *chargeCreditCardBtn2;
    IBOutlet UITextField *refTxtField1, *amountTxtField1, *refTxtField2, *amountTxtField2;
    IBOutlet UIPickerView *methodPicker1, *methodPicker2;
    
    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupUIContents];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
/*
 ChargeCreditCardViewController* chargeController = [segue destinationViewController];
 chargeController.pBillTo = pBillTo;
 chargeController.pAmount = pAmount;
 chargeController.pAddress = pAddress;
 chargeController.pZipcode = pZipcode;
 
 chargeController.serviceCalls = serviceCalls;

 */
- (void)setupUIContents{
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];

    titleLabel.text = [NSString stringWithFormat:@"Invoice # %@", self.dataObject[@"Id"]];
    
    subTotalLabel.text = [NSString stringWithFormat:@"%.02f", [self.dataObject[@"SubTotal"] doubleValue]];
    discountLabel.text = [NSString stringWithFormat:@"%.02f", [self.dataObject[@"Discount"] doubleValue]];
    taxLabel.text = [NSString stringWithFormat:@"%.02f", [self.dataObject[@"Tax"] doubleValue]];
    totalLabel.text = [NSString stringWithFormat:@"%.02f", [self.dataObject[@"Total"] doubleValue]];
    
    titleLabel.font = contentFont;
    subTotalLabel.font = contentFont;
    discountLabel.font = contentFont;
    taxLabel.font = contentFont;
    totalLabel.font = contentFont;
}

#pragma mark - UIPickerView Delegate & Datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSArray *paymentMethodList = [AppDelegate sharedInstance].setupInfo[@"PaymentMethods"];
    return paymentMethodList.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSArray *paymentMethodList = [AppDelegate sharedInstance].setupInfo[@"PaymentMethods"];
    NSDictionary *paymentMethod = paymentMethodList[row];
    NSString *methodString = [NSString stringWithFormat:@"%@", paymentMethod[@"Id"]];
    return methodString;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSArray *paymentMethodList = [AppDelegate sharedInstance].setupInfo[@"PaymentMethods"];
    NSDictionary *paymentMethod = paymentMethodList[row];
    NSString *methodString = [NSString stringWithFormat:@"%@", paymentMethod[@"Id"]];
    
    if (pickerView == methodPicker1) {
        [paymentMethodBtn1 setTitle:methodString forState:UIControlStateNormal];
    }else if (pickerView == methodPicker2){
        [paymentMethodBtn2 setTitle:methodString forState:UIControlStateNormal];
    }
    
    [pickerView setHidden:YES];
}

#pragma mark - IBAction

- (IBAction)ChargeCreditCard:(UIButton*)sender{
    ChargeCreditCardViewController* chargeController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChargeCreditCardVC"];
    
    chargeController.pBillTo = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"BillTo"][@"Id"];
    chargeController.pAddress = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Address"][@"Line1"];
    chargeController.pZipcode = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Address"][@"Zip"];
    chargeController.pName = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"DisplayName"];
    chargeController.invoiceInfo = self.dataObject;
    
    if (sender == chargeCreditCardBtn1) {
        chargeController.pAmount = [NSNumber numberWithDouble:[amountTxtField1.text doubleValue]];
    }else if (sender == chargeCreditCardBtn2) {        
        chargeController.pAmount = [NSNumber numberWithDouble:[amountTxtField2.text doubleValue]];
    }
    
    [self.navigationController pushViewController:chargeController animated:YES];
}

- (IBAction)SelectPaymentMethod:(UIButton*)sender{
    if (sender == paymentMethodBtn1) {
        [methodPicker1 setHidden:NO];
        [methodPicker2 setHidden:YES];
    }else if (sender == paymentMethodBtn2) {
        [methodPicker1 setHidden:YES];
        [methodPicker2 setHidden:NO];
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self keyboardWillShow];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
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
