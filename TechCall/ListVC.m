//
//  EquipmentVC.m
//  TechCall
//
//  Created by Maverics on 8/17/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "ListVC.h"
#import "AppDelegate.h"
#import "EquipmentDetailVC.h"
#import "HistoryDetailVC.h"
#import "RecommendationDetailVC.h"
#import "QuoteDetailVC.h"
#import "DocumentDetailVC.h"

@interface ListVC () <UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UITableView *dataTblView;
    
    UIFont *defaultFont, *contentFont;
}

@end

@implementation ListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:14];

    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(Add:)];

    if ([self.keyWord isEqualToString:@"Equipments"]) {
        self.title = @"Equipment";
        self.navigationItem.rightBarButtonItem = rightBtnItem;
    }else if ([self.keyWord isEqualToString:@"Contracts"]) {
        self.title = @"Contract";
    }else if ([self.keyWord isEqualToString:@"Contacts"]) {
        self.title = @"Contacts";
        self.navigationItem.rightBarButtonItem = rightBtnItem;
    }else if ([self.keyWord isEqualToString:@"History"]){
        self.title = @"History";
    }else if ([self.keyWord isEqualToString:@"Recommendation"]){
        self.title = @"Recommendation";
        self.navigationItem.rightBarButtonItem = rightBtnItem;
    }else if ([self.keyWord isEqualToString:@"Quotes"]){
        self.title = @"Quotes";
        self.navigationItem.rightBarButtonItem = rightBtnItem;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([self.keyWord isEqualToString:@"Equipments"]) {
        [self SDGetEquipment];
    }else if ([self.keyWord isEqualToString:@"Contracts"]) {
    }else if ([self.keyWord isEqualToString:@"Contacts"]) {
        [self SDGetContact];
    }else if ([self.keyWord isEqualToString:@"History"]){
        [self SDGetLocationCallHistory];
    }else if ([self.keyWord isEqualToString:@"Recommendation"]){
        [self SDGetRecommendations];
    }else if ([self.keyWord isEqualToString:@"Quotes"]){
        [self SDGetQuotes];
    }else if ([self.keyWord isEqualToString:@"Documents"]){
        [self SDGetDocuments];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction

- (IBAction)Add:(id)sender{
    
    if ([self.keyWord isEqualToString:@"Equipments"]) {
        EquipmentDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentDetailVC"];
        dest.keyWord = @"Equip";
        dest.actionKeyWord = @"Add";
        [self.navigationController pushViewController:dest animated:YES];
    }else if ([self.keyWord isEqualToString:@"Contracts"]) {
        
    }else if ([self.keyWord isEqualToString:@"Contacts"]) {
        EquipmentDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentDetailVC"];
        dest.keyWord = @"Contact";
        dest.actionKeyWord = @"Add";
        [self.navigationController pushViewController:dest animated:YES];
    }else if ([self.keyWord isEqualToString:@"History"]){

    }else if ([self.keyWord isEqualToString:@"Recommendation"]){
        RecommendationDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"RecommendationDetailVC"];
        dest.actionKey = @"Add";
        [self.navigationController pushViewController:dest animated:YES];
    }else if ([self.keyWord isEqualToString:@"Quotes"]){
        QuoteDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"QuoteDetailVC"];
        dest.actionKey = @"Add";
        [self.navigationController pushViewController:dest animated:YES];
    }
}

#pragma mark - UITableViewDelegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"dataCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    }
    
    cell.textLabel.font = defaultFont;
    cell.detailTextLabel.font = contentFont;
    
    if (self.dataList && self.dataList.count > 0) {
        NSDictionary *object = self.dataList[indexPath.row];
        
        if ([self.keyWord isEqualToString:@"Equipments"]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ S# %@",
                                   object[@"Manufacturer"],
                                   object[@"ModelNum"],
                                   object[@"SerialNum"]];
            cell.detailTextLabel.text = object[@"Description"];
        }else if ([self.keyWord isEqualToString:@"Contracts"]){
            NSArray *stringComponents1 = [object[@"StartDate"] componentsSeparatedByString:@"T"];
            NSArray *stringComponents2 = [object[@"ExpiryDate"] componentsSeparatedByString:@"T"];
            
            NSString *startDate, *expDate;
            
            if (stringComponents1 && stringComponents1.count > 0)
                startDate = [stringComponents1 objectAtIndex:0];
            if (stringComponents2 && stringComponents2.count > 0)
                expDate = [stringComponents2 objectAtIndex:0];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ CT: %lu",
                                   object[@"Id"],
                                   [object[@"ContractAmount"] longValue]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"SD: %@ ED: %@", startDate, expDate];
        }else if ([self.keyWord isEqualToString:@"Contacts"]){
            cell.textLabel.text = [NSString stringWithFormat:@"%@\t%@",
                                   object[@"ContactName"], object[@"Email"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t%@", object[@"MobilNumber"], object[@"PhoneNumber"]];
        }else if ([self.keyWord isEqualToString:@"History"]){
            NSArray *stringComponents1 = [object[@"StartDate"] componentsSeparatedByString:@"T"];
            NSArray *stringComponents2 = [object[@"EndDate"] componentsSeparatedByString:@"T"];

            NSString *startDate, *endDate;
            
            if (stringComponents1 && stringComponents1.count > 0)
                startDate = [stringComponents1 objectAtIndex:0];
            if (stringComponents2 && stringComponents2.count > 0)
                endDate = [stringComponents2 objectAtIndex:0];

            cell.textLabel.text = [NSString stringWithFormat:@"%@\tS:%@\tE:%@",
                                   object[@"Id"], startDate, endDate];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", object[@"ProblemDescription"]];
        }else if ([self.keyWord isEqualToString:@"Recommendation"]){
            NSArray *stringComponent = [object[@"Date"] componentsSeparatedByString:@"T"];
            NSString *recommendDate;
            
            if (stringComponent && stringComponent.count > 0)
                recommendDate = [stringComponent objectAtIndex:0];
            
            cell.textLabel.text = object[@"Description"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Recmd Made By: %@\tOn:%@",
                                         object[@"MadeBy"], recommendDate];
        }else if ([self.keyWord isEqualToString:@"Quotes"]){
            NSDictionary *salesManInfo = object[@"Salesman"];
            NSArray *stringComponent = [object[@"CreationDate"] componentsSeparatedByString:@"T"];
            NSString *quoteCreationDate;

            if (stringComponent && stringComponent.count > 0)
                quoteCreationDate = [stringComponent objectAtIndex:0];

            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", object[@"Id"], object[@"Name"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Given By:%@ On:%@ $%@", salesManInfo[@"Name"],
                                         quoteCreationDate, object[@"Total"]];
        }else if ([self.keyWord isEqualToString:@"Documents"]){
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = [NSString stringWithFormat:@"%@", object[@"Name"]];
        }
    }

    //alternate background color
    if( [indexPath row] % 2)
        [cell setBackgroundColor:[UIColor whiteColor]];
    else
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.keyWord isEqualToString:@"Equipments"]) {
        EquipmentDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentDetailVC"];
        dest.keyWord = @"Equip";
        dest.actionKeyWord = @"Modify";        
        dest.dataObject = (NSMutableDictionary*)self.dataList[indexPath.row];
        [self.navigationController pushViewController:dest animated:YES];
    }else if ([self.keyWord isEqualToString:@"History"]){
        HistoryDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryDetailVC"];
        dest.dataObject = (NSMutableDictionary*)self.dataList[indexPath.row];
        [self.navigationController pushViewController:dest animated:YES];
    }else if ([self.keyWord isEqualToString:@"Contacts"]){
        EquipmentDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentDetailVC"];
        dest.keyWord = @"Contact";
        dest.actionKeyWord = @"Modify";
        dest.dataObject = (NSMutableDictionary*)self.dataList[indexPath.row];
        [self.navigationController pushViewController:dest animated:YES];
    }else if ([self.keyWord isEqualToString:@"Recommendation"]){
        RecommendationDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"RecommendationDetailVC"];
        dest.actionKey = @"Modify";
        dest.dataObject = (NSMutableDictionary*)self.dataList[indexPath.row];
        [self.navigationController pushViewController:dest animated:YES];
    }else if ([self.keyWord isEqualToString:@"Quotes"]){
        QuoteDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"QuoteDetailVC"];
        dest.actionKey = @"Modify";
        dest.dataObject = (NSMutableDictionary*)self.dataList[indexPath.row];
        [self.navigationController pushViewController:dest animated:YES];
    }else if ([self.keyWord isEqualToString:@"Documents"]){
        DocumentDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"DocumentDetailVC"];
        dest.dataObject = (NSMutableDictionary*)self.dataList[indexPath.row];
        [self.navigationController pushViewController:dest animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        if ([self.keyWord isEqualToString:@"Equipments"]) {
            [self SDDeleteEquipment:indexPath.row];
        }
        else if ([self.keyWord isEqualToString:@"Contacts"]){
            [self SDDeleteContact:indexPath.row];
        }
        else if ([self.keyWord isEqualToString:@"Recommendation"]){
            [self SDDeleteRecommend:indexPath.row];
        }
    }
}

#pragma mark - Web service
#pragma mark -

#pragma mark GET
- (void)SDGetContact{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSInteger serviceMasterNo = [self.smInfoDict[@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CONTACT];
    [manager GET:urlString
      parameters:@{@"ServiceMasterNum": [NSNumber numberWithInteger:serviceMasterNo]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.dataList = (NSMutableArray*)responseObject;
                 [dataTblView reloadData];
             }else{
                 // failure response
                 [SVProgressHUD dismiss];
                 self.dataList = self.smInfoDict[@"ContactList"];
                 [dataTblView reloadData];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
             self.dataList = self.smInfoDict[@"ContactList"];
             [dataTblView reloadData];
         }
     ];
}

- (void)SDGetEquipment{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSInteger serviceMasterNo = [self.smInfoDict[@"Id"] integerValue];
    NSInteger callNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EQUIPMENT];
    
    [manager GET:urlString
      parameters:@{@"pServiceMaster": [NSNumber numberWithInteger:serviceMasterNo],
                   @"pCallNum": [NSNumber numberWithInteger:callNo]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.dataList = (NSMutableArray*)responseObject;
                 [dataTblView reloadData];
             }else{
                 // failure response
                 [SVProgressHUD dismiss];
                 self.dataList = self.smInfoDict[@"EquipmentList"];
                 [dataTblView reloadData];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
             self.dataList = self.smInfoDict[@"EquipmentList"];
             [dataTblView reloadData];
         }
     ];
}

- (void)SDGetLocationCallHistory{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSInteger serviceMasterNo = [self.smInfoDict[@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, GET_LOCATIONCALLHISTORY];
    [manager GET:urlString
      parameters:@{@"ServiceMaster": [NSNumber numberWithInteger:serviceMasterNo]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.dataList = (NSMutableArray*)responseObject;
                 [dataTblView reloadData];
                 //                 tempList = (NSMutableArray*)responseObject;
             }else{
                 // failure response
                 [SVProgressHUD dismiss];
                 self.dataList = self.smInfoDict[@"Calls"];
                 [dataTblView reloadData];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
             self.dataList = self.smInfoDict[@"Calls"];
             [dataTblView reloadData];
         }
     ];
}

- (void)SDGetQuotes{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSInteger serviceMasterNo = [self.smInfoDict[@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, QUOTES];
    [manager GET:urlString
      parameters:@{@"ServiceMasterNum": [NSNumber numberWithInteger:serviceMasterNo],
                   @"GetTemplatesOnly": @"false"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.dataList = (NSMutableArray*)responseObject;
                 [dataTblView reloadData];
             }else{
                 // failure response
                 [SVProgressHUD dismiss];
                 self.dataList = self.smInfoDict[@"Quotes"];
                 [dataTblView reloadData];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
             self.dataList = self.smInfoDict[@"Quotes"];
             [dataTblView reloadData];
         }
     ];
}

- (void)SDGetRecommendations{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSInteger serviceMasterNo = [self.smInfoDict[@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, RECOMMENDATION];
    [manager GET:urlString
      parameters:@{@"ServiceMasterNum": [NSNumber numberWithInteger:serviceMasterNo]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.dataList = (NSMutableArray*)responseObject;
                 [dataTblView reloadData];
             }else{
                 // failure response
                 [SVProgressHUD dismiss];
                 self.dataList = self.smInfoDict[@"Recommendations"];
                 [dataTblView reloadData];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
             self.dataList = self.smInfoDict[@"Recommendations"];
             [dataTblView reloadData];
         }
     ];
}

- (void)SDGetDocuments{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSInteger serviceMasterNo = [self.smInfoDict[@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, GET_DOCUMENTS];
    [manager GET:urlString
      parameters:@{@"ServiceMasterId": [NSNumber numberWithInteger:serviceMasterNo]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.dataList = (NSMutableArray*)responseObject;
                 [dataTblView reloadData];
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

#pragma mark DELTE
- (void)SDDeleteContact:(NSInteger)index{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *contactObject = self.dataList[index];
    NSInteger serviceMasterNo = [contactObject[@"ServiceMaster"][@"Id"] integerValue];
    NSInteger seqNo = [contactObject[@"Sequence"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CONTACT];
    
    [manager DELETE:urlString
         parameters:@{@"ServiceMasterNum": [NSNumber numberWithInteger:serviceMasterNo],
                      @"Sequence": [NSNumber numberWithInteger:seqNo]}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                [SVProgressHUD dismiss];
                
                if (responseObject) {
                    // success in web service call return
                    NSMutableArray *tempList = [self.dataList mutableCopy];
                    [tempList removeObjectAtIndex:index];
                    self.dataList = tempList;

                    [dataTblView reloadData];
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

- (void)SDDeleteRecommend:(NSInteger)index{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *recommendObject = self.dataList[index];
    NSInteger serviceMasterNo = [self.smInfoDict[@"Id"] integerValue];
    NSInteger seqNo = [recommendObject[@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, RECOMMENDATION];
    
    [manager DELETE:urlString
         parameters:@{@"ServiceMasterNum": [NSNumber numberWithInteger:serviceMasterNo],
                      @"Sequence": [NSNumber numberWithInteger:seqNo]}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                [SVProgressHUD dismiss];
                
                if (responseObject) {
                    // success in web service call return
                    NSMutableArray *tempList = [self.dataList mutableCopy];
                    [tempList removeObjectAtIndex:index];
                    self.dataList = tempList;

                    [dataTblView reloadData];
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

- (void)SDDeleteEquipment:(NSInteger)index{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *equipObject = self.dataList[index];
    NSInteger serviceMasterNo = [equipObject[@"ServiceMaster"][@"Id"] integerValue];
    NSInteger logNo = [equipObject[@"LogNum"] integerValue];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, EQUIPMENT];
    [manager DELETE:urlString
         parameters:@{@"ServiceMasterNum": [NSNumber numberWithInteger:serviceMasterNo],
                      @"LogNum": [NSNumber numberWithInteger:logNo]}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                [SVProgressHUD dismiss];
                
                if (responseObject) {
                    // success in web service call return
                    NSMutableArray *tempList = [self.dataList mutableCopy];
                    [tempList removeObjectAtIndex:index];
                    self.dataList = tempList;
                    
                    [dataTblView reloadData];
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
