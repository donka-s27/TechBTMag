//
//  CallPartsVC.m
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "CallPartsVC.h"
#import "AppDelegate.h"

@implementation CallPartsVC{
    IBOutlet UITableView *callPartsTblView;

    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];

    [self SDGetCallParts];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

#pragma mark - UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.callPartList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"callPartCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSDictionary *callPartObject = self.callPartList[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                           callPartObject[@"Part"][@"PartNum"],
                           callPartObject[@"Part"][@"PartDescription"]];
    cell.textLabel.font = contentFont;
    
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

#pragma mark - Webservice
- (void)SDGetCallParts{
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSInteger callNo = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"] integerValue];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, CALLPART];
    [manager GET:urlString
      parameters:@{@"CallNumber": [NSNumber numberWithInteger:callNo]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];
             
             if (responseObject) {
                 // success in web service call return
                 self.callPartList = (NSMutableArray*)responseObject;
                 [callPartsTblView reloadData];
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

@end
