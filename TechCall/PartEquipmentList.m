//
//  PartEquipmentList.m
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "PartEquipmentList.h"
#import "AppDelegate.h"
#import "ScanPartVC.h"

@implementation PartEquipmentList{
    IBOutlet UITableView *partTblView;

    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(AddPartEquipment)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

#pragma mark - IBAction

- (IBAction)AddPartEquipment{
//    if ([self.invoiceInfo[@"Posted"] boolValue] ||
//        [self.invoiceInfo[@"Approved"] boolValue]) {
//        [[AppDelegate sharedInstance] showAlertMessage:@"Warning" message:@"You don't allow to make any change for this invoice" buttonTitle:@"Ok"];
//    }else{
        ScanPartVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanPartVC"];
        dest.invoiceInfo = self.invoiceInfo;
        [self.navigationController pushViewController:dest animated:YES];
//    }
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"partEquipmentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    NSDictionary *solCodeObject = self.dataList[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",
                           solCodeObject[@"ItemNumber"],
                           solCodeObject[@"ItemDescription"]];
    cell.textLabel.font = contentFont;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Service Type: %@ Qty: %@ $:%@",
                     solCodeObject[@"ServiceType"][@"Id"],
                     solCodeObject[@"ItemQuantity"],
                     solCodeObject[@"SalesAmount"]];
    cell.detailTextLabel.font = contentFont;
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self SDDeleteInvoiceDetail:indexPath.row];
    }
}

#pragma mark - Webservice
- (void)SDDeleteInvoiceDetail:(NSInteger)index{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *invoiceObject = self.dataList[index];
    NSInteger invoiceId = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"][@"Id"]  integerValue];
    NSInteger seqNo = [invoiceObject[@"SeqNum"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, INVOICE_DETAIL];
    
    [manager DELETE:urlString
         parameters:@{@"InvoiceId": [NSNumber numberWithInteger:invoiceId],
                      @"Sequence": [NSNumber numberWithInteger:seqNo]}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                [SVProgressHUD dismiss];
                
                if (responseObject) {
                    // success in web service call return
                    NSMutableArray *tempList = [self.dataList mutableCopy];
                    [tempList removeObjectAtIndex:index];
                    self.dataList = tempList;
                    
                    [partTblView reloadData];
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
