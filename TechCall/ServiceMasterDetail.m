//
//  ServiceMasterDetail.m
//  TechCall
//
//  Created by Maverics on 9/6/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "ServiceMasterDetail.h"
#import "BarcodeViewController.h"
#import "AppDelegate.h"
#import "ListVC.h"

@implementation ServiceMasterDetail{
    IBOutlet UIScrollView *mainScrView;
    IBOutlet UILabel *addressLabel, *billToAddressLabel;
    IBOutlet UITextField *homePhoneLabel, *cellPhoneLabel, *workPhoneLabel, *emailLabel, *miscLabel1, *miscLabel2, *miscLabel3, *miscLabel4;
    IBOutlet UILabel *taxCodeLabel, *notesLabel;
    IBOutlet UIButton *doucmentsBtn, *contractJobsBtn, *contactBtn, *equipmentBtn, *serviceContractBtn, *quoteBtn, *recommendationBtn, *historyBtn;
    
    NSMutableArray *historyList, *recommList, *quoteList;
    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

-(void)viewDidLayoutSubviews{
    // Implement scroll view here when you apply the auto layout
    [self setupScrollView];
}

- (void)setupUI{
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];

    NSDictionary *address = _smInfo[@"Address"];
    if (address) {
        NSString *name = [NSString stringWithFormat:@"%@ %@",
                          _smInfo[@"FirstName"] ? _smInfo[@"FirstName"] : @"",
                          _smInfo[@"LastName"] ? _smInfo[@"LastName"] : @""];
        addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", name,
                             address[@"Line1"],
                             address[@"City"],
                             address[@"State"],
                             address[@"Zip"]];
        addressLabel.font = contentFont;
    }
    
    NSDictionary *billToaddress = _smInfo[@"BillTo"][@"Address"];
    if (billToaddress) {
        NSString *name = [NSString stringWithFormat:@"%@ %@",
                          _smInfo[@"BillTo"][@"FirstName"] ? _smInfo[@"BillTo"][@"FirstName"] : @"",
                          _smInfo[@"BillTo"][@"LastName"] ? _smInfo[@"BillTo"][@"LastName"] : @""];
        billToAddressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                                   name,
                                   address[@"Line1"],
                                   address[@"City"],
                                   address[@"State"],
                                   address[@"Zip"]];
        billToAddressLabel.font = contentFont;
    }
    
    homePhoneLabel.text = _smInfo[@"HomePhone"];
    cellPhoneLabel.text = _smInfo[@"CellPhone"];
    workPhoneLabel.text = _smInfo[@"WorkPhone"];
    emailLabel.text = _smInfo[@"Email"];
    taxCodeLabel.text = _smInfo[@"TaxCode"][@"Id"];
    
    homePhoneLabel.font = contentFont;
    cellPhoneLabel.font = contentFont;
    workPhoneLabel.font = contentFont;
    emailLabel.font = contentFont;
    taxCodeLabel.font = contentFont;
    
    //Menu button title
    NSArray *contractList = _smInfo[@"Contracts"];
    NSArray *contactList = _smInfo[@"ContactList"];
    NSArray *equipmentList = _smInfo[@"EquipmentList"];
    
    quoteList = _smInfo[@"Quotes"];
    recommList = _smInfo[@"Recommendations"];
    historyList = _smInfo[@"Calls"];

    [equipmentBtn setTitle:[NSString stringWithFormat:@"Equipment (%lu)", (unsigned long)equipmentList.count] forState:UIControlStateNormal];
    [contactBtn setTitle:[NSString stringWithFormat:@"Contacts (%lu)", (unsigned long)contactList.count] forState:UIControlStateNormal];
    [serviceContractBtn setTitle:[NSString stringWithFormat:@"Service Contract (%lu)", (unsigned long)contractList.count] forState:UIControlStateNormal];
    [historyBtn setTitle:[NSString stringWithFormat:@"History (%lu)", (unsigned long)historyList.count] forState:UIControlStateNormal];
    [recommendationBtn setTitle:[NSString stringWithFormat:@"Recommendation (%lu)", (unsigned long)recommList.count] forState:UIControlStateNormal];
    [quoteBtn setTitle:[NSString stringWithFormat:@"Quotes (%lu)", (unsigned long)quoteList.count] forState:UIControlStateNormal];

//    //History
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self SDGetLocationCallHistory];
//    });
//
//    //Recommendation
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self SDGetRecommendation];
//    });
//    
//    //Quotes
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self SDGetQuotes];
//    });
}

- (void)setupScrollView{
    // main scroll view
    [mainScrView setDelegate:self];
    [mainScrView setScrollEnabled:YES];
    [mainScrView setPagingEnabled:NO];
    [mainScrView setContentSize:CGSizeMake(1.0, 805)];
}

#pragma mark - IBAction

- (IBAction)Documents:(id)sender{
//    BarcodeViewController *dest = [[BarcodeViewController alloc] initWithNibName:@"BarcodeViewController" bundle:nil];
//    [self.navigationController pushViewController:dest animated:YES];

    ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
    dest.smInfoDict = [_smInfo mutableCopy];
    dest.title = @"Documents";
    dest.keyWord = @"Documents";
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Contact:(id)sender{
    NSArray *contactList = _smInfo[@"ContactList"];

    ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
    dest.smInfoDict = [_smInfo mutableCopy];
    dest.title = @"Contacts";
    dest.keyWord = @"Contacts";
    dest.dataList = (NSMutableArray*)contactList;
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Equipment:(id)sender{
    NSArray *equipmentList = _smInfo[@"EquipmentList"];
    
    ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
    dest.smInfoDict = [_smInfo mutableCopy];
    dest.title = @"Equipments";
    dest.keyWord = @"Equipments";
    dest.dataList = (NSMutableArray*)equipmentList;
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)ServiceContract:(id)sender{
    NSArray *contractList = _smInfo[@"Contracts"];
    
    ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
    dest.smInfoDict = [_smInfo mutableCopy];
    dest.title = @"Service Contracts";
    dest.keyWord = @"Contracts";
    dest.dataList = (NSMutableArray*)contractList;
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Quotes:(id)sender{
    ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
    dest.smInfoDict = [_smInfo mutableCopy];
    dest.title = @"Quotes";
    dest.keyWord = @"Quotes";
    dest.dataList = (NSMutableArray*)quoteList;
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Recommendation:(id)sender{
    ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
    dest.smInfoDict = [_smInfo mutableCopy];
    dest.title = @"Recommendation";
    dest.keyWord = @"Recommendation";
    dest.dataList = (NSMutableArray*)recommList;
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)History:(id)sender{
    ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
    dest.smInfoDict = [_smInfo mutableCopy];
    dest.title = @"History";
    dest.keyWord = @"History";
    dest.dataList = (NSMutableArray*)historyList;
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

@end
