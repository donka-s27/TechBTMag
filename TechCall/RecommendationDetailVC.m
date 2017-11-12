//
//  RecommendationDetailVC.m
//  TechCall
//
//  Created by Maverics on 9/7/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "RecommendationDetailVC.h"
#import "AppDelegate.h"

@implementation RecommendationDetailVC{
    IBOutlet UIView *updateView, *descriptionView;
    IBOutlet UILabel *madebyLabel, *madeOnLabel;
    IBOutlet UISwitch *acceptSwitch;
    IBOutlet UITableView *descListTblView;
    
    IBOutlet UITextView *descTextView;
    
    NSMutableDictionary *updateParam;
    NSString *description;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupUI];
}

- (void)setupUI{
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(SaveRecommendation:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    if ([self.actionKey isEqualToString:@"Add"]) {
        [updateView setHidden:YES];
        [descriptionView setHidden:NO];
        
        [self setupUIContents];
    }else if ([self.actionKey isEqualToString:@"Modify"]){
        [updateView setHidden:NO];
        [descriptionView setHidden:YES];
        
        [self setupUIContents];
    }else if ([self.sourceKey isEqualToString:@"Invoice"]){
        [updateView setHidden:YES];
        [descriptionView setHidden:NO];

        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setupUIContents{
    NSArray *stringComponent = [self.dataObject[@"Date"] componentsSeparatedByString:@"T"];
    NSString *recommendDate;
    
    if (stringComponent && stringComponent.count > 0)
        recommendDate = [stringComponent objectAtIndex:0];
    
    madebyLabel.text = self.dataObject[@"MadeBy"];
    madeOnLabel.text = recommendDate;
    
    if ([self.dataObject[@"Accepted"] boolValue] == 1){
        [acceptSwitch setOn:YES];
    }else{
        [acceptSwitch setOn:NO];
    }
}

- (void)setupParam{
    if ([self.actionKey isEqualToString:@"Add"]) {
        updateParam = [[NSMutableDictionary alloc] init];
        
        [updateParam setObject:@"0" forKey:@"Id"];
        [updateParam setObject:@{@"Id": [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Id"]} forKey:@"ServiceMaster"];

        if (!description)
            description = descTextView.text;
        [updateParam setObject:description forKey:@"Description"];

        NSInteger madeOnCallValue = [[AppDelegate sharedInstance].currentInfo[@"Call"][@"Id"] integerValue];
        [updateParam setObject:[NSNumber numberWithInteger:madeOnCallValue] forKey:@"MadeOnCall"];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        [updateParam setObject:[df stringFromDate:[NSDate date]] forKey:@"Date"];
        
    }else if ([self.actionKey isEqualToString:@"Modify"]){
        updateParam = [self.dataObject mutableCopy];
        
        [updateParam setObject:@{@"Id": [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"Id"]} forKey:@"ServiceMaster"];
        if (acceptSwitch.on) {
            [updateParam setObject:@"true" forKey:@"Accepted"];
        }else{
            [updateParam setObject:@"false" forKey:@"Accepted"];
        }
    }
}

#pragma mark - IBAction
- (IBAction)Accept:(UISwitch*)sender{
}


- (IBAction)SaveRecommendation:(id)sender{
    [self updateRecommendation];
}

#pragma mark - Webservice
- (void)updateRecommendation{
    [SVProgressHUD show];
    [self setupParam];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[AppDelegate sharedInstance].token forHTTPHeaderField:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASIC_URL, RECOMMENDATION];
    NSLog(@"update param = %@", updateParam);
    
    [manager POST:urlString
       parameters:updateParam
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

#pragma mark - UITableView Delegate & Datasource
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Select Recommendation";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *descList = [AppDelegate sharedInstance].setupInfo[@"StandardDescriptions"];
    return descList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"descriptionCell";
    
    NSArray *descList = [AppDelegate sharedInstance].setupInfo[@"StandardDescriptions"];
    NSDictionary *descObject = descList[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    UITextView *descTxtView = [cell.contentView viewWithTag:1];
    NSString *fullContent = [NSString stringWithFormat:@"Code: %@,\t Type: %@\nDescription: %@",
                             descObject[@"EntityCode"],
                             descObject[@"EntityType"],
                             descObject[@"Description"]];
    descTxtView.text = fullContent;
    descTxtView.font = [UIFont systemFontOfSize:15];

    //alternate background color
    if( [indexPath row] % 2)
        [cell setBackgroundColor:[UIColor whiteColor]];
    else
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *descList = [AppDelegate sharedInstance].setupInfo[@"StandardDescriptions"];
    NSDictionary *descObject = descList[indexPath.row];
    description = descObject[@"Description"];

    if ([_sourceKey isEqualToString:@"Invoice"]){
        [self.delegate setDescription:descObject text:description];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    description = [NSString stringWithFormat:@"%@%@", textView.text, text];
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        if ([_sourceKey isEqualToString:@"Invoice"]){
            [self.delegate setDescription:nil text:description];
        }
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([_sourceKey isEqualToString:@"Invoice"]){
        [self.delegate setDescription:nil text:description];
    }
}

@end
