//
//  InvoiceDetailVC.m
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "InvoiceDetailVC.h"
#import "InvoicePaymentInfoVC.h"
#import "SolutionCodeListVC.h"
#import "PartEquipmentList.h"
#import "AppDelegate.h"

@implementation InvoiceDetailVC{
    IBOutlet UILabel *invDetailLabel, *amountLabel, *creditLabel;
    IBOutlet UITextView *descTxtView;
    IBOutlet UIButton *solutionCodeBtn, *partListBtn;
    
    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self SDGetInvoiceDetail];
}


- (void)setupUIContent{
    [SVProgressHUD show];
    
    if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0){
        // Avoid the top UITextView space, iOS7 (~bug?)
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];

    NSString *serviceMasterID = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Id"];
    NSString *serviceMasterName = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"DisplayName"];
    NSString *callID = [AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"];
    
    NSArray *solutionCodeList = self.invoiceData[@"InvoiceSolutionCode"];
    NSInteger numSolutionCodes = solutionCodeList.count;
    NSString *solutionBtnTitle = [NSString stringWithFormat:@"Solution Code [%lu]", (long)numSolutionCodes];
    [solutionCodeBtn setTitle:solutionBtnTitle forState:UIControlStateNormal];
    

    NSString *invInfo = [NSString stringWithFormat:@"%@ %@\nCall# %@ Invoice# %@\tMaterialPS: %@\tLaborPS: %@",
                         serviceMasterID ? serviceMasterID : @"",
                         serviceMasterName ? serviceMasterName : @"",
                         callID ? callID : @"",
                         self.invoiceData[@"Id"] ? self.invoiceData[@"Id"] : @"",
                         self.invoiceData[@"MaterialPS"] ? self.invoiceData[@"MaterialPS"] : @"",
                         self.invoiceData[@"LaborPS"] ? self.invoiceData[@"LaborPS"] : @""];
    invDetailLabel.text = invInfo;
    invDetailLabel.font = defaultFont;
    
    NSString *valueInfo = [NSString stringWithFormat:@"ST: %@ D:%@ Tax:%@ Total:%@",
                         self.invoiceData[@"SubTotal"],
                         self.invoiceData[@"Discount"],
                         self.invoiceData[@"Tax"],
                         self.invoiceData[@"Total"]];
    amountLabel.text = valueInfo;
    amountLabel.font = defaultFont;
    [amountLabel sizeToFit];
    
    descTxtView.font = contentFont;
    [SVProgressHUD dismiss];
}

#pragma mark - IBAction

- (IBAction)SolutionCode:(id)sender{
    SolutionCodeListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"SolutionCodeListVC"];
    NSArray *solutionCodeList = self.invoiceData[@"InvoiceSolutionCode"];
    dest.invoiceInfo = self.invoiceData;
    dest.solCodeList = [solutionCodeList mutableCopy];
    dest.title = @"Solution Code";
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)PartList:(id)sender{
    PartEquipmentList *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"PartEquipmentList"];
    dest.dataList = self.invoiceData[@"InvoiceItems"];
    dest.invoiceInfo = self.invoiceData;
    dest.title = @"Part Equipment";
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)GoToDetail:(id)sender{
    InvoicePaymentInfoVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"InvoicePaymentInfoVC"];
    dest.dataObject = self.invoiceData;
    dest.title = @"Payment Info";
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)SelectDesc:(id)sender{
    RecommendationDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"RecommendationDetailVC"];
    dest.delegate = self;
    dest.sourceKey = @"Invoice";
    dest.actionKey = @"";
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - Description Delegate

- (void)setDescription:(NSDictionary *)descObject text:(NSString *)description{
    if (descObject)
        descTxtView.text = descObject[@"Description"];
    else
        descTxtView.text = description;
}

#pragma mark - Webservice

- (void)SDGetInvoiceDetail{
    [SVProgressHUD show];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];

    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, INVOICE];
    [manager GET:urlString
      parameters:@{@"InvoiceId" : self.invoiceData[@"Id"]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             [SVProgressHUD dismiss];

             if (responseObject) {
                 // success in web service call return
                 self.invoiceData = [responseObject mutableCopy];
                 [self setupUIContent];
             }else{
                 // failure response
                 [SVProgressHUD dismiss];
                 self.invoiceData = [AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"];
                 [self setupUIContent];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [SVProgressHUD dismiss];
             self.invoiceData = [AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"];
             [self setupUIContent];
         }
     ];
}

#pragma mark - UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    return YES;
}

@end
