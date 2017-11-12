//
//  ScanPartVC.m
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "ScanPartVC.h"
#import "AppDelegate.h"

@implementation ScanPartVC{
    NSString *scanModeSetting, *pickerKey;
    NSMutableDictionary *updateParam, *pickedServiceType, *pickedCategory, *pickedSolution;
    NSMutableArray *pickerContents;
    
    IBOutlet UISwitch *inventorySwitch, *partsUsedSwitch;
    IBOutlet UITextField *partField, *descField, *quantityField;
    IBOutlet UIButton *serviceTypeBtn, *categoryBtn, *solutionCodeBtn;
    
    IBOutlet UITableView *partListTblView;
    IBOutlet UIPickerView *settingPicker;
}

- (void)viewDidLoad{
    scanModeSetting = @"Manual";
    self.dataList = [[NSMutableArray alloc] init];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)setupUI{
    self.title = @"Scan Parts";

    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(createInvoiceDetail)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;

    [[(UIButton*)self.view viewWithTag:1] setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [[(UIButton*)self.view viewWithTag:2] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    
    [inventorySwitch setOn:NO];
    [partsUsedSwitch setOn:NO];
}

/*
 {"Invoice":{"Id":"548"}, "SeqNum": 0, "Category":{"Id":"Material"}, "isInventoryItem": true, "ItemNumber": "21AB",  "ItemDescription": "21AB THERMOSTAT", "ServiceType":{"Id":"COM"}, "ItemQuantity":1,
 "Cost":100, "Discount":10, "SalesAmount":120, "Warehouse":@"", "Equipment":"",
 
 "isTaxable":false, "SolutionCode":{"Id":"", "Sequence":0}, "technician":{"Id":100},
 "isItemUsed":true, "calculatePrice":false}
*/

- (void)setupParam{
    updateParam = [[NSMutableDictionary alloc] init];
    
    [updateParam setObject:@{@"Id": [AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"][@"Id"]} forKey:@"Invoice"];
    [updateParam setObject:@"0" forKey:@"SeqNum"];
    [updateParam setObject:@{@"Id":pickedSolution[@"Id"],
                             @"Sequence":pickedSolution[@"Sequence"]} forKey:@"SolutionCode"];

    //key information
    [updateParam setObject:partField.text forKey:@"ItemNumber"];
    [updateParam setObject:descField.text forKey:@"ItemDescription"];
    [updateParam setObject:quantityField.text forKey:@"ItemQuantity"];
    
    //setup information
    [updateParam setObject:@{@"Id": pickedCategory[@"Id"]} forKey:@"Category"];
    [updateParam setObject:@{@"Id": pickedServiceType[@"Id"]} forKey:@"ServiceType"];
    
    //condition values
    if (inventorySwitch.on)
        [updateParam setObject:@"true" forKey:@"isInventoryItem"];
    else
        [updateParam setObject:@"false" forKey:@"isInventoryItem"];
    
    if (partsUsedSwitch.on){
        [updateParam setObject:@"true" forKey:@"isItemUsed"];
        [updateParam setObject:@"false" forKey:@"calculatePrice"];
    }
    else{
        [updateParam setObject:@"false" forKey:@"isItemUsed"];
        [updateParam setObject:@"true" forKey:@"calculatePrice"];
    }
    
    //empty values
    [updateParam setObject:@"" forKey:@"Cost"];
    [updateParam setObject:@"" forKey:@"Discount"];
    [updateParam setObject:@"" forKey:@"SalesAmount"];
    [updateParam setObject:@"" forKey:@"Warehouse"];
    [updateParam setObject:@"" forKey:@"Equipment"];
    [updateParam setObject:@"" forKey:@"technician"];
}

#pragma mark - IBAction

- (IBAction)SelectServiceType:(id)sender{
    pickerKey = @"ST";
    pickerContents = [AppDelegate sharedInstance].setupInfo[@"ServiceTypes"];
    
    [settingPicker setHidden:!settingPicker.hidden];
    [settingPicker reloadAllComponents];
}

- (IBAction)SelectCategory:(id)sender{
    pickerKey = @"CT";
//    pickerContents = [AppDelegate sharedInstance].setupInfo[@"BillingCategories"];
    pickerContents = [[NSMutableArray alloc] initWithObjects:
                                                                @{@"Id": @"Equipment"},
                                                                @{@"Id": @"Material"}, nil];
    
    [settingPicker setHidden:!settingPicker.hidden];
    [settingPicker reloadAllComponents];
}

- (IBAction)SelectSolutionCode:(id)sender{
    pickerKey = @"SC";
    pickerContents = self.invoiceInfo[@"InvoiceSolutionCode"];
    
    [settingPicker setHidden:!settingPicker.hidden];
    [settingPicker reloadAllComponents];
}

- (IBAction)SearchPart:(id)sender{
    SearchSMVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchSMVC"];
    dest.title = @"Search Part Equipment";
    dest.delegate = self;
    dest.actionKey = @"SEARCH_PART";
    dest.productType = @"X";
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)AddNewItem:(id)sender{
    [self setupParam];
    [self.dataList addObject:updateParam];
    [partListTblView reloadData];
}

- (IBAction)ScanModeSetting:(UIButton*)sender{
    BarcodeViewController *dest = [[BarcodeViewController alloc] initWithNibName:@"BarcodeViewController" bundle:nil];
    dest.delegate = self;
    
    switch (sender.tag) {
        case 1:
            scanModeSetting = @"Manual";
            
            [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:2] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            break;
        case 2:
            scanModeSetting = @"Scan";
            
            [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:1] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            
            [self.navigationController pushViewController:dest animated:YES];

            break;
        default:
            break;
    }
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
    
    if ([pickerKey isEqualToString:@"ST"]) {
        return pickObject[@"Id"];
    }else if ([pickerKey isEqualToString:@"CT"]) {
        return pickObject[@"Id"];
    }else if ([pickerKey isEqualToString:@"SC"]) {
        return pickObject[@"Id"];
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSDictionary *pickObject = pickerContents[row];

    if ([pickerKey isEqualToString:@"ST"]) {
        pickedServiceType = [pickObject mutableCopy];
        [serviceTypeBtn setTitle:pickObject[@"Id"] forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"CT"]) {
        pickedCategory = [pickObject mutableCopy];
        [categoryBtn setTitle:pickObject[@"Id"] forState:UIControlStateNormal];
    }else if ([pickerKey isEqualToString:@"SC"]) {
        pickedSolution = [pickObject mutableCopy];
        [solutionCodeBtn setTitle:pickObject[@"Id"] forState:UIControlStateNormal];
    }
    
    [pickerView setHidden:YES];
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"partCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    NSDictionary *solCodeObject = self.dataList[indexPath.row];
    
    UILabel *mainLabel = [(UILabel*)cell.contentView viewWithTag:1];
    UILabel *subLabel = [(UILabel*)cell.contentView viewWithTag:2];
    
    mainLabel.text = [NSString stringWithFormat:@"%@ %@",
                      solCodeObject[@"ItemNumber"],
                      solCodeObject[@"ItemDescription"]];
    subLabel.text = [NSString stringWithFormat:@"%@", solCodeObject[@"ItemQuantity"]];

    //alternate background color
    if( [indexPath row] % 2)
        [cell setBackgroundColor:[UIColor whiteColor]];
    else
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PartNumberSetting Delegate
- (void)setPartNumInformation:(NSString*)partNum{
    partField.text = partNum;
    descField.text = partNum;
}

#pragma mark - LookUp Delegate

- (void)setLookUpInformation:(NSDictionary*)infoDict{
    descField.text = infoDict[@"Description"];
    partField.text = [NSString stringWithFormat:@"%@", infoDict[@"PartNumber"]];
}

#pragma mark - UITextField & UITextView Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Webservice

- (void)createInvoiceDetail{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, INVOICE_DETAIL];
    NSLog(@"update param = %@", self.dataList);
    
    [manager POST:urlString
       parameters:self.dataList
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



@end
