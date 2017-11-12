//
//  FirstViewController.m
//  TechCall
//
//  Created by Maverics on 7/18/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "TechCallsVC.h"
#import "AppDelegate.h"
#import "CallTimesVC.h"
#import "CallDetailVC.h"
#import "InvoiceDetailVC.h"
#import "ListVC.h"
#import "ServiceMasterDetail.h"
#import "MapViewController.h"

#import "SearchSMVC.h"

#define INFO_CARD_HEIGHT topScrollView.frame.size.height
#define LABEL_HEIGHT 20
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define HORIZ_MARGIN 5
#define VERT_MARGIN 5

@implementation NSAttributedString(stringWithFormat)

+ (NSAttributedString*)stringWithFormat:(NSAttributedString*)format, ...{
    va_list args;
    va_start(args, format);
    
    NSMutableAttributedString *mutableAttributedString = (NSMutableAttributedString*)[format mutableCopy];
    NSString *mutableString = [mutableAttributedString string];
    
    while (true) {
        NSAttributedString *arg = va_arg(args, NSAttributedString*);
        if (!arg) {
            break;
        }
        NSRange rangeOfStringToBeReplaced = [mutableString rangeOfString:@"%@"];
        [mutableAttributedString replaceCharactersInRange:rangeOfStringToBeReplaced withAttributedString:arg];
    }
    
    va_end(args);
    
    return mutableAttributedString;
}

@end

@interface TechCallsVC () <UIScrollViewDelegate>{
    NSMutableArray *dataList, *tempList;
    NSDate *currentDate;
    UIFont *defaultFont, *contentFont;
    
    IBOutlet UIScrollView *topScrollView, *mainScrollView;

    IBOutlet UILabel *topDateLabel;
    IBOutlet UIView *dateView;
    IBOutlet UIDatePicker *datePickerView;
    IBOutlet UIButton *invoiceBtn;
    
    //menu view
    IBOutlet UIView *menuView;
    IBOutlet UIButton *historyBtn, *equipmentBtn, *serviceBtn, *contactsBtn;
    
    //sub views
    IBOutlet UILabel *billToLabel, *serviceLocLabel, *problemLabel, *callTimeLabel;
    IBOutlet UIView *CallTime_view1;
}

@end

@implementation TechCallsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    currentDate = [NSDate date];
    
    [SVProgressHUD show];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupScrollContents:)
                                                 name:@"LoadRootData"
                                               object:nil];

    if([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0){
        // Avoid the top UITextView space, iOS7 (~bug?)
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

-(void)viewDidLayoutSubviews{
    // Implement scroll view here when you apply the auto layout
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewAnimationsAtIndex:(NSInteger)index{
    NSLog(@"%ld", (long)index);
}

#pragma mark - UI methods

- (void)setupNavigationBar{
    [self.navigationController setNavigationBarHidden:NO];
    
    self.title = @"Tech Calls";
    
    UIImage *image = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(SideMenu:)];
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Change Date" style:UIBarButtonItemStylePlain target:self action:@selector(ChangeDate:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

-(void)setupUI{
    [self setupNavigationBar];
    
    // top scroll view
    [topScrollView setDelegate:self];
    [topScrollView setScrollEnabled:YES];
    [topScrollView setPagingEnabled:YES];
    [topScrollView setShowsHorizontalScrollIndicator:NO];
    [topScrollView setShowsVerticalScrollIndicator:NO];
    
    // main scroll view
    [mainScrollView setDelegate:self];
    [mainScrollView setScrollEnabled:YES];
    [mainScrollView setPagingEnabled:NO];
    [mainScrollView setContentSize:CGSizeMake(1.0, 600)];

    //extra process
    CallTime_view1.layer.borderColor = [UIColor darkGrayColor].CGColor;
    CallTime_view1.layer.borderWidth = 0.7f;
}

- (void)setupScrollContents:(NSNotification *) notification{
    [SVProgressHUD show];
    

    if ([[notification name] isEqualToString:@"LoadRootData"]){
        dataList = [AppDelegate sharedInstance].rootInfo;
        defaultFont = [UIFont systemFontOfSize:17];
        contentFont = [UIFont systemFontOfSize:15];

        // date information
        NSDateFormatter* day = [[NSDateFormatter alloc] init];
        [day setDateFormat:@"EEEE, MMM d YY"];
        topDateLabel.text = [day stringFromDate:currentDate];
        topDateLabel.font = defaultFont;

        // clearing the existing views
        for (UIView *subView in topScrollView.subviews) {
            [subView removeFromSuperview];
        }

        if (dataList && dataList.count > 0) {
            [topScrollView setContentSize:CGSizeMake(SCREEN_WIDTH * dataList.count, 1.0)];
            [topScrollView setContentInset:UIEdgeInsetsMake(0, 0, topScrollView.contentInset.bottom, topScrollView.contentInset.right)];
            [topScrollView setContentOffset:CGPointMake(0, 0)];
            
            for (int i=0; i<dataList.count; i++) {
                NSDictionary *callInfo = [dataList objectAtIndex:i];
                UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, 200)];
                [topScrollView addSubview:infoView];
                
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(HORIZ_MARGIN, VERT_MARGIN, SCREEN_WIDTH / 2, LABEL_HEIGHT)];
                nameLabel.textAlignment = NSTextAlignmentLeft;
                nameLabel.font = defaultFont;
                [infoView addSubview:nameLabel];
                
                UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - HORIZ_MARGIN - SCREEN_WIDTH / 2, VERT_MARGIN, SCREEN_WIDTH / 2 - HORIZ_MARGIN, LABEL_HEIGHT)];
                phoneLabel.textAlignment = NSTextAlignmentRight;
                nameLabel.font = defaultFont;
                [infoView addSubview:phoneLabel];
                
                UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(HORIZ_MARGIN, LABEL_HEIGHT + VERT_MARGIN * 2, SCREEN_WIDTH - HORIZ_MARGIN * 2, INFO_CARD_HEIGHT - LABEL_HEIGHT)];
                contentLabel.font = contentFont;
                contentLabel.numberOfLines = 0;
                
                //        [contentLabel sizeToFit];
                [infoView addSubview:contentLabel];
                
                //value setting
                nameLabel.text = [NSString stringWithFormat:@"%@ %@",
                                  callInfo[@"Call"][@"ServiceMaster"][@"FirstName"] ? callInfo[@"Call"][@"ServiceMaster"][@"FirstName"] : @"",
                                  callInfo[@"Call"][@"ServiceMaster"][@"LastName"]] ? callInfo[@"Call"][@"ServiceMaster"][@"LastName"] : @"";
                phoneLabel.text = callInfo[@"Call"][@"ContactNumber"];
                
                NSString *addresss = [NSString stringWithFormat:@"%@, %@ %@ %@"
                                      ,callInfo[@"Call"][@"ServiceMaster"][@"Address"][@"Line1"] ? callInfo[@"Call"][@"ServiceMaster"][@"Address"][@"Line1"] : @""
                                      ,callInfo[@"Call"][@"ServiceMaster"][@"Address"][@"City"] ? callInfo[@"Call"][@"ServiceMaster"][@"Address"][@"City"] : @""
                                      ,callInfo[@"Call"][@"ServiceMaster"][@"Address"][@"State"] ? callInfo[@"Call"][@"ServiceMaster"][@"Address"][@"State"]: @""
                                      ,callInfo[@"Call"][@"ServiceMaster"][@"Address"][@"Zip"] ? callInfo[@"Call"][@"ServiceMaster"][@"Address"][@"Zip"] : @""];
                
                NSString *call = [NSString stringWithFormat:@"Call# %@\tST:%@\tT:%@"
                                  ,callInfo[@"Call"][@"Id"] ? callInfo[@"Call"][@"Id"] : @""
                                  ,callInfo[@"Call"][@"ServiceType"] ? callInfo[@"Call"][@"ServiceType"] : @""
                                  ,callInfo[@"Call"][@"TimePromised"] ? callInfo[@"Call"][@"TimePromised"] : @""];
                
                NSString *invNumString = callInfo[@"Call"][@"Invoice"][@"Id"] ? callInfo[@"Call"][@"Invoice"][@"Id"] : @"";
                NSString *invAmountString = callInfo[@"Call"][@"Invoice"][@"Total"] ? callInfo[@"Call"][@"Invoice"][@"Total"] : @"";
                NSString *invoiceDetail = [NSString stringWithFormat:@"Inv#\t\t\t\tD:%@ A:%@ C:%@"
                                           ,callInfo[@"DispatchTime"] ? callInfo[@"DispatchTime"] : @""
                                           ,callInfo[@"ArrivalTime"] ? callInfo[@"ArrivalTime"] : @""
                                           ,callInfo[@"CompletionTime"] ? callInfo[@"CompletionTime"] : @""];
                
                NSString *invBtnTitle = [NSString stringWithFormat:@"%@ $%@", invNumString, invAmountString];
                if ([invAmountString isKindOfClass:[NSString class]])
                    [invoiceBtn setTitle:@"" forState:UIControlStateNormal];
                else
                    [invoiceBtn setTitle:invBtnTitle forState:UIControlStateNormal];
                
                NSString *contentString = [NSString stringWithFormat:@"%@\n%@\n%@\nPD:%@\nSL:%@",
                                           addresss, call, invoiceDetail
                                           ,callInfo[@"Call"][@"ProblemDescription"] ? callInfo[@"Call"][@"ProblemDescription"] : @""
                                           ,callInfo[@"Call"][@"OutcomeCode"] ? callInfo[@"Call"][@"OutcomeCode"] : @""];
                
                contentLabel.text = contentString;
            }
            
            [self setupExtraContents:0];
        }else{
            //Menu button title
            [historyBtn setTitle:@"History" forState:UIControlStateNormal];
            [equipmentBtn setTitle:@"Equipment" forState:UIControlStateNormal];
            [contactsBtn setTitle:@"Contacts" forState:UIControlStateNormal];
            [serviceBtn setTitle:@"Service Contract" forState:UIControlStateNormal];

            billToLabel.text = @"";
            serviceLocLabel.text = @"";
            problemLabel.text = @"";
            callTimeLabel.text = @"";
        }
    }
}

- (void)setupExtraContents:(NSInteger)index{
    NSDictionary *callInfo = [dataList objectAtIndex:index];
    [AppDelegate sharedInstance].currentIndex = index;
    [AppDelegate sharedInstance].currentInfo = [[NSMutableDictionary alloc] initWithDictionary:callInfo];
    
    NSDictionary *callDetailInfo = callInfo[@"Call"];
    NSDictionary *invInfo = callDetailInfo[@"Invoice"];
    NSDictionary *billTo = callDetailInfo[@"ServiceMaster"][@"BillTo"];
    
    NSArray *contractList = callDetailInfo[@"ServiceMaster"][@"Contracts"];
    NSArray *contactList = callDetailInfo[@"ServiceMaster"][@"ContactList"];
    NSArray *equipmentList = callDetailInfo[@"ServiceMaster"][@"EquipmentList"];
    NSArray *historyList = callDetailInfo[@"ServiceMaster"][@"Calls"];
    
    //Menu button title
    [historyBtn setTitle:[NSString stringWithFormat:@"History (%lu)", (unsigned long)historyList.count] forState:UIControlStateNormal];
    [equipmentBtn setTitle:[NSString stringWithFormat:@"Equipment (%lu)", (unsigned long)equipmentList.count] forState:UIControlStateNormal];
    [contactsBtn setTitle:[NSString stringWithFormat:@"Contacts (%lu)", (unsigned long)contactList.count] forState:UIControlStateNormal];
    [serviceBtn setTitle:[NSString stringWithFormat:@"Service Contract (%lu)", (unsigned long)contractList.count] forState:UIControlStateNormal];
    
    //Bill To
    NSString *name = [NSString stringWithFormat:@"%@ %@",
                      billTo[@"FirstName"] ? billTo[@"FirstName"] : @"",
                      billTo[@"LastName"] ? billTo[@"LastName"] : @""];
    NSString *address;
    if ([billTo[@"Address"] isKindOfClass:[NSDictionary class]]) {
        address = [NSString stringWithFormat:@"%@ %@ %@ %@",
                   billTo[@"Address"][@"Line1"] ? billTo[@"Address"][@"Line1"] : @"",
                   billTo[@"Address"][@"City"] ? billTo[@"Address"][@"City"] : @"",
                   billTo[@"Address"][@"State"] ? billTo[@"Address"][@"State"]: @"",
                   billTo[@"Address"][@"Zip"] ? billTo[@"Address"][@"Zip"] : @""];
    }

    NSString *payment = [NSString stringWithFormat:@"Payment Type: %@",
                         billTo[@"PaymentMethod"] ? billTo[@"PaymentMethod"] : @""];
    billToLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@",
                        name,
                        address,
                        payment];
    billToLabel.font = contentFont;
    
    //Service Location
    NSString *service_address = [NSString stringWithFormat:@"%@\n%@, %@ %@"
                          ,callDetailInfo[@"ServiceMaster"][@"Address"][@"Line1"]
                          ,callDetailInfo[@"ServiceMaster"][@"Address"][@"City"]
                          ,callDetailInfo[@"ServiceMaster"][@"Address"][@"State"]
                          ,callDetailInfo[@"ServiceMaster"][@"Address"][@"Zip"]];
    
    NSString *contacts = [NSString stringWithFormat:@"H: %@ C: %@ W: %@",
                          billTo[@"HomePhoneNum"] ? billTo[@"HomePhoneNum"] : @"",
                          callDetailInfo[@"ContactNumber"] ? callDetailInfo[@"ContactNumber"] : @"",
                          billTo[@"WorkPHoneNum"] ? billTo[@"WorkPHoneNum"] : @""];
    
    serviceLocLabel.text = [NSString stringWithFormat:@"%@\n%@", service_address, contacts];
    serviceLocLabel.font = contentFont;

    //Description
    NSString *description = callDetailInfo[@"ProblemDescription"];
    problemLabel.text = description;
    problemLabel.font = contentFont;
    [problemLabel sizeToFit];
    
    //Call Time
    NSString *callTime = [NSString stringWithFormat:@"D:%@ A:%@ C:%@"
                               ,callInfo[@"DispatchTime"] ? callInfo[@"DispatchTime"] : @""
                               ,callInfo[@"ArrivalTime"] ? callInfo[@"ArrivalTime"] : @""
                               ,callInfo[@"CompletionTime"] ? callInfo[@"CompletionTime"] : @""];

    callTimeLabel.text = callTime;
    callTimeLabel.font = contentFont;
    
    [SVProgressHUD dismiss];
}

#pragma mark -
#pragma mark IBAction
#pragma mark -

- (IBAction)Complete:(id)sender{
    if ([AppDelegate sharedInstance].currentInfo) {
        CallTimesVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"CallTimesVC"];
        dest.callInfoDict = [AppDelegate sharedInstance].currentInfo;
        [self.navigationController pushViewController:dest animated:YES];
    }
}

- (IBAction)History:(id)sender{
    NSDictionary *smInfo = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"];
    if (smInfo) {
        NSArray *historyList = smInfo[@"Calls"];
        
        if (historyList) {
            ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
            dest.smInfoDict = [smInfo mutableCopy];
            dest.title = @"History";
            dest.keyWord = @"History";
            dest.dataList = (NSMutableArray*)historyList;
            [self.navigationController pushViewController:dest animated:YES];
        }else{
            [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The History information is empty." buttonTitle:@"Ok"];
        }
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The History information is empty." buttonTitle:@"Ok"];
    }
}

- (IBAction)Equipment:(id)sender{
    NSDictionary *smInfo = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"];
    if (smInfo) {
        NSArray *equipmentList = smInfo[@"EquipmentList"];
        
        if (equipmentList) {
            ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
            dest.smInfoDict = [smInfo mutableCopy];
            dest.title = @"Equipments";
            dest.keyWord = @"Equipments";
            dest.dataList = (NSMutableArray*)equipmentList;
            [self.navigationController pushViewController:dest animated:YES];
        }else{
            [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Equipment information is empty." buttonTitle:@"Ok"];
        }
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Equipment information is empty." buttonTitle:@"Ok"];
    }
}

- (IBAction)ServiceContract:(id)sender{
    NSDictionary *smInfo = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"];
    if (smInfo) {
        NSArray *contractList = smInfo[@"Contracts"];
        
        if (contractList) {
            ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
            dest.smInfoDict = [smInfo mutableCopy];
            dest.title = @"Service Contracts";
            dest.keyWord = @"Contracts";
            dest.dataList = (NSMutableArray*)contractList;
            [self.navigationController pushViewController:dest animated:YES];
        }else{
            [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Service Contract information is empty." buttonTitle:@"Ok"];
        }
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Service Contract information is empty." buttonTitle:@"Ok"];
    }
}

- (IBAction)Contacts:(id)sender{
    NSDictionary *smInfo = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"];
    if (smInfo) {
        NSArray *contactList = smInfo[@"ContactList"];
        
        if (contactList) {
            ListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ListVC"];
            dest.title = @"Contacts";
            dest.keyWord = @"Contacts";
            dest.smInfoDict = [smInfo mutableCopy];
            dest.dataList = (NSMutableArray*)contactList;
            [self.navigationController pushViewController:dest animated:YES];
            
        }else{
            [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Call information is empty." buttonTitle:@"Ok"];
        }
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Call information is empty." buttonTitle:@"Ok"];
    }
}

- (IBAction)ServiceMaster:(id)sender{
    NSDictionary *smInfo = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"];

    if (smInfo) {
        ServiceMasterDetail *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"ServiceMasterDetail"];
        dest.title = @"Service Master";
        dest.smInfo = smInfo;
        
        [self.navigationController pushViewController:dest animated:YES];
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Service Master information is empty." buttonTitle:@"Ok"];
    }
}

- (IBAction)CallDetail:(id)sender{
    if ([AppDelegate sharedInstance].currentInfo) {
        CallDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"CallDetailVC"];
        dest.callInfoDict = [AppDelegate sharedInstance].currentInfo;
        dest.title = @"Call Details";
        [self.navigationController pushViewController:dest animated:YES];
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Call information is empty." buttonTitle:@"Ok"];
    }
}

- (IBAction)InvoiceDetail:(id)sender{
    if ([AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"]) {
        InvoiceDetailVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"InvoiceDetailVC"];
        dest.invoiceData = [AppDelegate sharedInstance].currentInfo[@"Call"][@"Invoice"];
        [self.navigationController pushViewController:dest animated:YES];
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Invoice data is empty." buttonTitle:@"Ok"];
    }
}

- (IBAction)Call:(id)sender{
    NSString *phoneNumber = [AppDelegate sharedInstance].currentInfo[@"Call"][@"ContactNumber"];
    
    if (phoneNumber) {
        NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumber]];
        NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumber]];
        
        if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
            [UIApplication.sharedApplication openURL:phoneUrl];
        } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
            [UIApplication.sharedApplication openURL:phoneFallbackUrl];
        } else {
            // Show an error message: Your device can not do phone calls.
        }
    }
}

- (IBAction)Map:(id)sender{
    NSDictionary *callDetailInfo = [AppDelegate sharedInstance].currentInfo[@"Call"];

    if (callDetailInfo) {
        NSString *service_address = [NSString stringWithFormat:@"%@\n%@, %@ %@"
                                     ,callDetailInfo[@"ServiceMaster"][@"Address"][@"Line1"]
                                     ,callDetailInfo[@"ServiceMaster"][@"Address"][@"City"]
                                     ,callDetailInfo[@"ServiceMaster"][@"Address"][@"State"]
                                     ,callDetailInfo[@"ServiceMaster"][@"Address"][@"Zip"]];
        
        MapViewController *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
        dest.addresString = service_address;
        [self.navigationController pushViewController:dest animated:YES];
    }else{
        [[AppDelegate sharedInstance] showAlertMessage:@"" message:@"The Map data is empty." buttonTitle:@"Ok"];
    }
}

#pragma mark - Side menu methods
- (IBAction)SideMenu:(id)sender{
    NSLog(@"Side Menu");
    menuView.hidden = !menuView.hidden;
}

#pragma mark - Search methods
- (IBAction)SearchSM:(id)sender{
    SearchSMVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchSMVC"];
    dest.title = @"Search Service Master";
    dest.actionKey = @"SEARCH_SM";
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - Date settings methods
- (IBAction)ChangeDate:(id)sender{
    [dateView setHidden:NO];
}

- (IBAction)DoneDatePicker:(id)sender{
    [dateView setHidden:YES];
    currentDate = datePickerView.date;
    
    [AppDelegate sharedInstance].currentDate = currentDate;
    [[AppDelegate sharedInstance] SDTechCalls:currentDate];
}

- (IBAction)CancelDatePicker:(id)sender{
    [dateView setHidden:YES];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == topScrollView) {
        static NSInteger previousPage = 0;
        CGFloat pageWidth = scrollView.frame.size.width;
        float fractionalPage = scrollView.contentOffset.x / pageWidth;
        NSInteger page = lround(fractionalPage);
        if (previousPage != page) {
            // Page has changed, do your thing!
            // ...
            // Finally, update previous page
            previousPage = page;
            NSLog(@"%lu", page);
            
            [self setupExtraContents:page];
        }
    }
}

@end
