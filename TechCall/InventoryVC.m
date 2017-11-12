//
//  InventoryVC.m
//  TechCall
//
//  Created by Maverics on 9/9/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "InventoryVC.h"
#import "AppDelegate.h"

@implementation InventoryVC{
    IBOutlet UIPickerView *supPickerView;
    IBOutlet UIView *newInputTextView;
    IBOutlet UITextField *newListTxtField;
    IBOutlet UITableView *tableView;
    
    NSMutableArray *supList, *truckList;
    NSDictionary *pickInfo;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Truck Inventory";
    supList = [AppDelegate sharedInstance].setupInfo[@"MUPListNames"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - IBAction
- (IBAction)NewList:(id)sender{
//    [newInputTextView setHidden:NO];
}

- (IBAction)TextInputOK:(id)sender{
    [newInputTextView setHidden:YES];
    [supList addObject:newListTxtField.text];
    [supPickerView reloadAllComponents];
}

- (IBAction)TextInputCancel:(id)sender{
    [newInputTextView setHidden:YES];
    [supPickerView reloadAllComponents];
}

#pragma mark - Webservice
- (void)PIMyTruckParts{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *param;
    if (pickInfo)
        param = @{@"MUPListId": [NSString stringWithFormat:@"%@", pickInfo[@"Id"]]};
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, MY_TRUCKPARTS];
    [manager GET:urlString
      parameters:param
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 truckList = (NSMutableArray*)responseObject;
                 [tableView reloadData];
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

#pragma mark - UIPickerView Delegate & Datasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return supList.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *tempDict = supList[row];
    return [NSString stringWithFormat:@"%@", tempDict[@"Id"]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    pickInfo = supList[row];
    [self PIMyTruckParts];
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return truckList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"truckCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    NSDictionary *truckObject = truckList[indexPath.row];
    
    UILabel *mainLabel = [(UILabel*)cell.contentView viewWithTag:2];
    mainLabel.text = [NSString stringWithFormat:@"%@", truckObject[@"PartNum"]];
    
    UILabel *subLabel = [(UILabel*)cell.contentView viewWithTag:3];
    subLabel.text = [NSString stringWithFormat:@"%@",
                     truckObject[@"PartDescription"]];
    
    UILabel *disclosureLabel = [(UILabel*)cell.contentView viewWithTag:4];
    disclosureLabel.text = [NSString stringWithFormat:@"%@", truckObject[@"onHand"]];

    UISwitch *optionSwitch = [(UISwitch*)cell.contentView viewWithTag:1];
    BOOL mupPart = [truckObject[@"MupPart"] boolValue];
    [optionSwitch setUserInteractionEnabled:NO];
    [optionSwitch setOn:mupPart];

    //alternate background color
    if( [indexPath row] % 2)
        [cell setBackgroundColor:[UIColor whiteColor]];
    else
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    return cell;
}

#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
