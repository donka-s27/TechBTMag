//
//  QuoteDetail-Detail.m
//  TechCall
//
//  Created by Maverics on 9/22/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "QuoteDetail_DetailItemsVC.h"
#import "QuoteDetail_DetailItemAdd.h"

@implementation QuoteDetail_DetailItemsVC{
    IBOutlet UITableView *detailListTblView;
    IBOutlet UISegmentedControl *updateModeSegment;
    
    NSArray *segmentValueList;
    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Quote Detail";
    
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];

    segmentValueList = [[NSArray alloc] initWithObjects:@"Equipment", @"Material", @"Labor" ,@"Miscellaneous", nil];
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(AddQuoteDetail:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - IBAction
- (IBAction)AddQuoteDetail:(id)sender{
    QuoteDetail_DetailItemAdd *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"QuoteDetail_DetailItemAdd"];
    dest.actionKey = @"Add";
    dest.updateMode = segmentValueList[updateModeSegment.selectedSegmentIndex];
   
    NSLog(@"update mode = %@", dest.updateMode);
    dest.param = [[NSMutableDictionary alloc] init];
    [dest.param setObject:@{@"Description": dest.updateMode} forKey:@"BillingCategory"];
    [dest.param setObject:@{@"Id": self.quoteMaster[@"Id"]} forKey:@"QuoteMaster"];

    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - UITableview Delegate & Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.quoteDetailList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"quoteDetailCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    }
    
    NSDictionary *quoteDetailObject = self.quoteDetailList[indexPath.row];
    NSDictionary *billCategory = quoteDetailObject[@"BillingCategory"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", billCategory[@"Id"], billCategory[@"Description"]];
    cell.textLabel.font = defaultFont;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Qty:%@ $%@", quoteDetailObject[@"Quantity"], quoteDetailObject[@"SalesPrice"]];
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
    NSDictionary *quoteDetailObject = self.quoteDetailList[indexPath.row];
    NSDictionary *billCategory = quoteDetailObject[@"BillingCategory"];

    QuoteDetail_DetailItemAdd *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"QuoteDetail_DetailItemAdd"];
    dest.actionKey = @"Modify";
    
    //    A = Equipment
    //    B = Material/Part
    //    C = Labor
    //    F = Miscellaneous
    
    if ([billCategory[@"Id"] isEqualToString:@"A"]) {
        dest.updateMode = segmentValueList[0];
    }else if ([billCategory[@"Id"] isEqualToString:@"B"]) {
        dest.updateMode = segmentValueList[1];
    }else if ([billCategory[@"Id"] isEqualToString:@"C"]) {
        dest.updateMode = segmentValueList[2];
    }else if ([billCategory[@"Id"] isEqualToString:@"F"]) {
        dest.updateMode = segmentValueList[3];
    }
    
    dest.quoteDetailObject = self.quoteDetailList[indexPath.row];

    dest.param = [[NSMutableDictionary alloc] init];
    [dest.param setObject:@{@"Description": dest.updateMode} forKey:@"BillingCategory"];
    [dest.param setObject:@{@"Id": self.quoteMaster[@"Id"]} forKey:@"QuoteMaster"];

    [self.navigationController pushViewController:dest animated:YES];
    
}
@end
