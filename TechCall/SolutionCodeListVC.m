//
//  SolutionCodeListVC.m
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "SolutionCodeListVC.h"
#import "AppDelegate.h"
#import "ScanPartVC.h"


@implementation SolutionCodeListVC{
    IBOutlet UITableView *codeListTblView;
    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    self.title = @"Solution Code List";
    
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];
}

#pragma mark - IBAction
- (void)Menu:(UIButton*)sender{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Menu"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *button1 = [UIAlertAction actionWithTitle:@"DELETE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self SDDeleteInvoiceSolutionCode:sender.tag];
    }];
    
    UIAlertAction *button2 = [UIAlertAction actionWithTitle:@"Add Parts" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([self.invoiceInfo[@"Posted"] boolValue] ||
            [self.invoiceInfo[@"Approved"] boolValue]) {
            [[AppDelegate sharedInstance] showAlertMessage:@"Warning" message:@"You don't allow to make any change for this invoice" buttonTitle:@"Ok"];
        }else{
            ScanPartVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ScanPartVC"];
            dest.invoiceInfo = self.invoiceInfo;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }];
    
    UIAlertAction *button3 = [UIAlertAction actionWithTitle:@"Attach PO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self AttachPO:sender.tag];
    }];
    
    UIAlertAction *button4 = [UIAlertAction actionWithTitle:@"Attach Quote Pricing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self AttachQuotePricing:sender.tag];
    }];
    
    UIAlertAction *button5 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:button1];
    [alert addAction:button2];
    [alert addAction:button3];
    [alert addAction:button4];
    [alert addAction:button5];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.solCodeList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"solCodeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    NSDictionary *solCodeObject = self.solCodeList[indexPath.row];

    UILabel *mainLabel = [(UILabel*)cell.contentView viewWithTag:10];
    mainLabel.text = [NSString stringWithFormat:@"%@ - %@", solCodeObject[@"Id"], solCodeObject[@"Description"]];
    mainLabel.font = defaultFont;
    
    UILabel *subLabel = [(UILabel*)cell.contentView viewWithTag:11];
    subLabel.text = [NSString stringWithFormat:@"Service Type: %@ Qty: %@ $:%@",
                     solCodeObject[@"ServiceType"][@"Id"],
                     solCodeObject[@"Quantity"],
                     solCodeObject[@"Amount"]];
    subLabel.font = contentFont;
    
    UIButton *menuBtn = [(UIButton*)cell.contentView viewWithTag:12];
    [menuBtn addTarget:self action:@selector(Menu:) forControlEvents:UIControlEventTouchUpInside];
    menuBtn.tag = indexPath.row;
    
    //alternate background color
    if( [indexPath row] % 2)
        [cell setBackgroundColor:[UIColor whiteColor]];
    else
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self SDDeleteInvoiceSolutionCode:indexPath.row];
    }
}

#pragma mark - Webservice
- (void)SDDeleteInvoiceSolutionCode:(NSInteger)index{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *invoiceSolObject = self.solCodeList[index];
    NSInteger invoiceId = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"][@"Id"]  integerValue];
    NSInteger seqNo = [invoiceSolObject[@"Sequence"] integerValue];

    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, INVOICE_SOLUTION];
    
    [manager DELETE:urlString
         parameters:@{@"InvoiceId": [NSNumber numberWithInteger:invoiceId],
                      @"SolutionCodeId": invoiceSolObject[@"Id"],
                      @"SolutionCodeSequence": [NSNumber numberWithInteger:seqNo]}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                [SVProgressHUD dismiss];
                
                if (responseObject) {
                    // success in web service call return
                    NSMutableArray *tempList = [self.solCodeList mutableCopy];
                    [tempList removeObjectAtIndex:index];
                    self.solCodeList = tempList;
                    
                    [codeListTblView reloadData];
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

- (void)AttachPO:(NSInteger)index{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *invoiceSolObject = self.solCodeList[index];
    NSInteger invoiceId = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"][@"Id"]  integerValue];
    NSInteger seqNo = [invoiceSolObject[@"Sequence"] integerValue];

    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, INVOICE_ATTACH_PO];
    NSDictionary *param = @{@"InvoiceId" : [NSNumber numberWithInteger:invoiceId],
                            @"SolutionCodeSequence" : [NSNumber numberWithInteger:seqNo],
                            @"SolutionCodeId" : invoiceSolObject[@"Id"]};
    NSLog(@"update param = %@", param);
    
    [manager POST:urlString
       parameters:param
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

- (void)AttachQuotePricing:(NSInteger)index{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSDictionary *invoiceSolObject = self.solCodeList[index];
    NSInteger invoiceId = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"][@"Id"]  integerValue];

    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, INVOICE_ATTACH_QUOTE_PRICING];
    NSDictionary *param = @{@"CallMasterId" : [AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"],
                            @"InvoiceId" : [NSNumber numberWithInteger:invoiceId],
                            @"ServiceTypeId" : invoiceSolObject[@"ServiceType"][@"Id"],
                            @"SolutionCodeId" : invoiceSolObject[@"Id"]};
    NSLog(@"update param = %@", param);
    
    [manager POST:urlString
       parameters:param
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

@end
