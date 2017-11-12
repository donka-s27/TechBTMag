//
//  QuoteDetail-DetailAdd.m
//  TechCall
//
//  Created by Maverics on 9/22/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "QuoteDetail_DetailItemAdd.h"
#import "AppDelegate.h"

@implementation QuoteDetail_DetailItemAdd{
    IBOutlet UILabel *idLabel, *quantityLabel, *invLabel, *descLabel;
    IBOutlet UITextField *partNoField, *totalField, *quantityField, *unitCostField, *discountField;
    IBOutlet UITextView *partDescTxtView;
    IBOutlet UISwitch *visibleSwitch, *taxableSwitch;

    IBOutlet UIView *laborView;
    IBOutlet UIPickerView *typePicker;
    IBOutlet UIButton *typePickBtn;
    
    NSArray *laborTypeList;
    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Quote Detail";
    
    laborTypeList = [[NSArray alloc] initWithObjects:@"Regular", @"Overtime", @"Doubletime", nil];
    
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];

    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)setupUI{
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(updateQuoteItem)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;

    if([self.updateMode isEqualToString:@"Labor"]){
        [visibleSwitch setHidden:YES];
        [invLabel setHidden:YES];
        
        [partNoField setHidden:YES];
        [idLabel setHidden:YES];
        
        [partDescTxtView setHidden:YES];
        [descLabel setHidden:YES];
        
        [laborView setHidden:NO];
        quantityLabel.text = @"Hours";
    }else{
        [laborView setHidden:YES];
        quantityLabel.text = @"Quantity";
        
        if ([self.updateMode isEqualToString:@"Material"] ||
            [self.updateMode isEqualToString:@"Equipment"]) {
            
            [invLabel setHidden:NO];
            [visibleSwitch setHidden:NO];
            idLabel.text = @"Part Number";
            
        }else if([self.updateMode isEqualToString:@"Miscellaneous"]){
            [visibleSwitch setHidden:YES];
            [invLabel setHidden:YES];
            idLabel.text = @"Id";
        }
    }
    
    if ([self.actionKey isEqualToString:@"Modify"]) {
        NSLog(@"%@", self.quoteDetailObject);
        partNoField.text = self.quoteDetailObject[@"Category"];
        partNoField.font = contentFont;
        partDescTxtView.text = self.quoteDetailObject[@"CategoryDescription"];
        partDescTxtView.font = contentFont;
        
        totalField.text = [self.quoteDetailObject[@"SalesPrice"] stringValue];
        totalField.font = contentFont;
        quantityField.text = [self.quoteDetailObject[@"Quantity"] stringValue];
        quantityField.font = contentFont;
        unitCostField.text = [self.quoteDetailObject[@"UnitCost"] stringValue];
        unitCostField.font = contentFont;
        discountField.text = [self.quoteDetailObject[@"Discount"] stringValue];
        discountField.font = contentFont;
        
        if ([self.quoteDetailObject[@"isInventory"] boolValue])
            [visibleSwitch setOn:YES];
        
        if ([self.quoteDetailObject[@"isTaxable"] boolValue])
            [taxableSwitch setOn:YES];
    }
}

- (void)setupParam{
    if([self.updateMode isEqualToString:@"Labor"]){
        NSInteger index = [typePicker selectedRowInComponent:0];
        [self.param setObject:laborTypeList[index] forKey:@"LaborType"];
        [self.param setObject:@"Labor" forKey:@"Category"];
        [self.param setObject:@"Labor" forKey:@"CategoryDescription"];
    }else{
        [self.param setObject:partNoField.text forKey:@"Category"];
        [self.param setObject:partDescTxtView.text forKey:@"CategoryDescription"];
    }
    
    [self.param setObject:quantityField.text forKey:@"Quantity"];
    [self.param setObject:unitCostField.text forKey:@"UnitCost"];
    [self.param setObject:totalField.text forKey:@"SalesPrice"];
    
    if (taxableSwitch.on) {
        [self.param setObject:@"true" forKey:@"IsTaxable"];
    }
    
    if (![discountField.text isEqualToString:@""]) {
        [self.param setObject:discountField.text forKey:@"Discount"];
    }
}

#pragma mark - IBAction

- (IBAction)SetType:(id)sender{
    [typePicker setHidden:NO];
}

- (IBAction)Lookup:(id)sender{
    SearchSMVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchSMVC"];
    dest.title = @"Search Part Equipment";
    dest.delegate = self;
    dest.actionKey = @"SEARCH_PART";
    dest.productType = _updateMode;
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - LookUp Delegate

- (void)setLookUpInformation:(NSDictionary*)infoDict{
    NSLog(@"%@", infoDict);
    
    partDescTxtView.text = infoDict[@"Description"];
    partNoField.text = [NSString stringWithFormat:@"%@", infoDict[@"PartNumber"]];
    unitCostField.text = [NSString stringWithFormat:@"%@", infoDict[@"UnitCost"]];
}

#pragma mark - Webservice

- (void)updateQuoteItem{
    [SVProgressHUD show];
    [self setupParam];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, QUOTE_ITEM];
    
    NSLog(@"update param = %@", self.param);
    
    [manager POST:urlString
       parameters:self.param
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
    return laborTypeList.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return laborTypeList[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [typePickBtn setTitle:laborTypeList[row] forState:UIControlStateNormal];
    [typePicker setHidden:YES];
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

@end
