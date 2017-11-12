//
//  SearchSMVC.m
//  TechCall
//
//  Created by Maverics on 9/9/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "SearchSMVC.h"
#import "AppDelegate.h"
#import "ServiceMasterDetail.h"
#import "ListVC.h"
#import "MapViewController.h"
#import "CallBookVC.h"

@implementation SearchSMVC{
    IBOutlet UITextField *serachValueTxtField;
    IBOutlet UIButton *searchFieldBtn, *searchCriteriaBtn;
    
    IBOutlet UIView *dataPickView;
    IBOutlet UIPickerView *pickerView;
    IBOutlet UITableView *searchResultTblView;

    NSString *pickerKey, *searchFieldValue, *searchCriteriaValue;
    NSMutableArray *searchResult;
    NSDictionary *smInfoDict;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if ([self.actionKey isEqualToString:@"SEARCH_SM"]){
        self.searchFieldList = [[NSMutableArray alloc] initWithObjects:@"sm#", @"phone", @"company", @"fname", @"lname", @"address", nil];
        self.searchCriteriaList = [[NSMutableArray alloc] initWithObjects:@"like", @"=", nil];
    }else if ([self.actionKey isEqualToString:@"SEARCH_PART"]){
        self.searchFieldList = [[NSMutableArray alloc] initWithObjects:@"Part Num", @"Description", @"UPC", @"Model", @"Product Line", nil];
        self.searchCriteriaList = [[NSMutableArray alloc] initWithObjects:@"like", @"=", nil];
    }
    
    if ([[AppDelegate sharedInstance].searchInfo[@"SearchKey"] isEqualToString:self.actionKey]){
        searchFieldValue = [AppDelegate sharedInstance].searchInfo[@"SearchField"];
        [searchFieldBtn setTitle:searchFieldValue forState:UIControlStateNormal];
    }
    
    searchCriteriaValue = @"like";
    [searchCriteriaBtn setTitle:searchCriteriaValue forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)popupMenu{
    ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Menu"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *button1 = [UIAlertAction actionWithTitle:@"Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (smInfoDict) {
            ServiceMasterDetail *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ServiceMasterDetail"];
            dest.smInfo = smInfoDict;
            dest.title = @"Service Master";
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];
    
    UIAlertAction *button2 = [UIAlertAction actionWithTitle:@"History" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (smInfoDict) {
            NSArray *historyList = smInfoDict[@"Calls"];
            
            dest.smInfoDict = [smInfoDict mutableCopy];
            dest.title = @"History";
            dest.keyWord = @"History";
            dest.dataList = (NSMutableArray*)historyList;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];
    
    UIAlertAction *button3 = [UIAlertAction actionWithTitle:@"Equipment" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (smInfoDict) {
            NSArray *equipmentList = smInfoDict[@"EquipmentList"];
            
            dest.smInfoDict = [smInfoDict mutableCopy];
            dest.title = @"Equipments";
            dest.keyWord = @"Equipments";
            dest.dataList = (NSMutableArray*)equipmentList;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];
    
    UIAlertAction *button4 = [UIAlertAction actionWithTitle:@"Contract" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (smInfoDict) {
            NSArray *contractList = smInfoDict[@"Contracts"];
            
            dest.smInfoDict = [smInfoDict mutableCopy];
            dest.title = @"Service Contracts";
            dest.keyWord = @"Contracts";
            dest.dataList = (NSMutableArray*)contractList;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];
    
    UIAlertAction *button5 = [UIAlertAction actionWithTitle:@"Recommendation" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (smInfoDict) {
            NSArray *recommList = smInfoDict[@"Recommendations"];
            dest.smInfoDict = [smInfoDict mutableCopy];
            dest.title = @"Recommendation";
            dest.keyWord = @"Recommendation";
            dest.dataList = (NSMutableArray*)recommList;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];

    UIAlertAction *button6 = [UIAlertAction actionWithTitle:@"Book Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (smInfoDict) {
            CallBookVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"CallBookVC"];
            dest.smInfo = [smInfoDict mutableCopy];
            dest.title = @"Book Call";
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];

    UIAlertAction *button7 = [UIAlertAction actionWithTitle:@"Quote" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (smInfoDict) {
            NSArray *quoteList = smInfoDict[@"Quotes"];

            dest.smInfoDict = [smInfoDict mutableCopy];
            dest.title = @"Quotes";
            dest.keyWord = @"Quotes";
            dest.dataList = (NSMutableArray*)quoteList;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];
    
    UIAlertAction *button8 = [UIAlertAction actionWithTitle:@"Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (smInfoDict) {
            NSString *service_address = [NSString stringWithFormat:@"%@\n%@, %@ %@"
                                         ,smInfoDict[@"Address"][@"Line1"]
                                         ,smInfoDict[@"Address"][@"City"]
                                         ,smInfoDict[@"Address"][@"State"]
                                         ,smInfoDict[@"Address"][@"Zip"]];
            
            MapViewController *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            dest.addresString = service_address;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];
    
    UIAlertAction *button9 = [UIAlertAction actionWithTitle:@"Contact" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (smInfoDict) {
            NSArray *contactList = smInfoDict[@"ContactList"];
            
            dest.smInfoDict = [smInfoDict mutableCopy];
            dest.title = @"Contacts";
            dest.keyWord = @"Contacts";
            dest.dataList = (NSMutableArray*)contactList;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];

    UIAlertAction *button10 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:button1];
    [alert addAction:button2];
    [alert addAction:button3];
    [alert addAction:button4];
    [alert addAction:button5];
    [alert addAction:button6];
    [alert addAction:button7];
    [alert addAction:button8];
    [alert addAction:button9];
    [alert addAction:button10];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - IBAction

- (IBAction)SearchNow:(id)sender{
    if ([self.actionKey isEqualToString:@"SEARCH_SM"]){
        [self searchSM];
    }else if ([self.actionKey isEqualToString:@"SEARCH_PART"]){
        [self searchPartEquipment];
    }
}

- (IBAction)SearchField:(id)sender{
    pickerKey = @"field";
    [dataPickView setHidden:NO];
    [pickerView reloadAllComponents];
}

- (IBAction)SearchCriteria:(id)sender{
    pickerKey = @"criteria";
    [dataPickView setHidden:NO];
    [pickerView reloadAllComponents];
}

- (IBAction)DonePick:(id)sender{
    NSInteger selectedRow = [pickerView selectedRowInComponent:0];
    if ([pickerKey isEqualToString:@"field"]) {
        searchFieldValue = self.searchFieldList[selectedRow];
        [searchFieldBtn setTitle:searchFieldValue forState:UIControlStateNormal];
        
        [[AppDelegate sharedInstance].searchInfo setObject:searchFieldValue forKey:@"SearchField"];
        [[AppDelegate sharedInstance].searchInfo setObject:self.actionKey forKey:@"SearchKey"];
    }else if ([pickerKey isEqualToString:@"criteria"]){
        searchCriteriaValue = self.searchCriteriaList[selectedRow];
        [searchCriteriaBtn setTitle:searchCriteriaValue forState:UIControlStateNormal];
    }
    
    [dataPickView setHidden:YES];
}

- (IBAction)CancelPick:(id)sender{
    [dataPickView setHidden:YES];
}

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UIPickerView deleate & datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerKey isEqualToString:@"field"]) {
        return _searchFieldList.count;
    }else if ([pickerKey isEqualToString:@"criteria"]){
        return _searchCriteriaList.count;
    }
    return 1;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if ([pickerKey isEqualToString:@"field"]) {
        return _searchFieldList[row];
    }else if ([pickerKey isEqualToString:@"criteria"]){
        return _searchCriteriaList[row];
    }

    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if ([pickerKey isEqualToString:@"field"]) {
        searchFieldValue = _searchFieldList[row];
    }else if ([pickerKey isEqualToString:@"criteria"]){
        searchCriteriaValue = _searchCriteriaList[row];
    }
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return searchResult.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cell_ID = @"searchResultCell";

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_ID];
    if (!cell){
        cell = [tableView dequeueReusableCellWithIdentifier:cell_ID];
    }
    
    NSDictionary *object = searchResult[indexPath.row];
    
    if ([self.actionKey isEqualToString:@"SEARCH_PART"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ OnHand: %@",
                               object[@"PartNumber"],
                               object[@"OnHand"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, UnitCost: $%@", object[@"Description"], object[@"UnitCost"]];
    }else if ([self.actionKey isEqualToString:@"SEARCH_SM"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                               object[@"Id"],
                               object[@"DisplayName"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@",
                                     object[@"Address"][@"Line1"],
                                     object[@"Address"][@"City"],
                                     object[@"Address"][@"Zip"]];
    }
    
    //alternate background color
    if( [indexPath row] % 2)
        [cell setBackgroundColor:[UIColor whiteColor]];
    else
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *object = searchResult[indexPath.row];
    
    if ([self.actionKey isEqualToString:@"SEARCH_PART"]) {
        [self.delegate setLookUpInformation:object];
        [self.navigationController popViewControllerAnimated:YES];
    }else if ([self.actionKey isEqualToString:@"SEARCH_SM"]){
        [self popupMenu];
        [self SDGetServiceMaster:object[@"Id"]];
    }
}


#pragma mark - Webservice

- (void)searchSM{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *param = @{@"SearchField" : searchFieldValue,
                            @"SearchCriteria" : searchCriteriaValue,
                            @"SearchValue" : serachValueTxtField.text};
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, SEARCH_SM];
    
    [manager GET:urlString
      parameters:param
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 searchResult = (NSMutableArray*)responseObject;
                 [searchResultTblView setHidden:NO];
                 [searchResultTblView reloadData];
             }else{
                 // failure response
                 [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
             
             [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
         }
     ];
}

- (void)searchPartEquipment{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    NSDictionary *param = @{@"SearchField" : searchFieldValue,
                            @"SearchCriteria" : searchCriteriaValue,
                            @"SearchValue" : serachValueTxtField.text,
                            @"ProductType" : self.productType};
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, SEARCH_PART];
    [manager GET:urlString
      parameters:param
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 searchResult = (NSMutableArray*)responseObject;
                 [searchResultTblView setHidden:NO];
                 [searchResultTblView reloadData];
             }else{
                 // failure response
                 [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
             
             [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
         }
     ];
}

- (void)SDGetServiceMaster:(NSString*)IDString{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    NSDictionary *param = @{@"ServiceMasterNum" : IDString};
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, SERVICE_MASTER];
    [manager GET:urlString
      parameters:param
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 smInfoDict = (NSDictionary*)responseObject;
             }else{
                 // failure response
                 [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
             
             [[AppDelegate sharedInstance] showAlertMessage:@"Error" message:@"failed" buttonTitle:@"Ok"];
         }
     ];
}

@end
