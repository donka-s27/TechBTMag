//
//  ChargeCreditCardViewController.m
//  Tech
//
//  Created by apple on 1/6/16.
//  Copyright © 2016 Luke Stanley. All rights reserved.
//

#import "ChargeCreditCardViewController.h"
#import "ChargeTableViewCell.h"
#import "AppDelegate.h"
#import "CreditCardValidator.h"

@interface ChargeCreditCardViewController () <UIAlertViewDelegate> {
    NSArray *artCategories;
    NSDictionary *techCalls;
    
    NSString *loginTech;
    NSString *ipAddr;
    NSString *techType;
    NSString *passwd;
    
    NSString *magStr;
    
    int opendev;
}

@end

@implementation ChargeCreditCardViewController
- (void)viewDidDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    ipAddr = [AppDelegate sharedInstance].ipAddress;
    loginTech = @"";
    passwd = @"";
    techType = @"T";
    magStr = @"";
    opendev = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uniAccessoryConnected:) name:@"iMagDidConnectNotification" object:nil];		//Step 7
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uniAccessoryDisconnected:) name:@"iMagDidDisconnectNotification" object:nil];	//Step 8
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryData:) name:@"iMagDidReceiveDataNotification" object:nil];			//Step 9
    
    [iMag enableLogging: TRUE]; //enable info level logging
    iReader = [[iMag alloc] init]; //Step 6
    
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    [manager setResponseSerializer:responseSerializer];
    
    NSString *savedCredit = [NSString stringWithFormat:@"https://%@/api/CreditCard/GetSavedCreditCards/%@?pBillTo=%@", ipAddr, loginTech, self.pBillTo];
    //NSString *savedCredit = [NSString stringWithFormat:@"http://216.15.147.97:90/api/CreditCard/GetSavedCreditCards/%@?pBillTo=%@", loginTech, self.pBillTo];
    //NSString *savedCredit = [NSString stringWithFormat:@"http://%@:90/api/CreditCard/GetSavedCreditCards/%@?pBillTo=%@", ipAddr, loginTech, self.pBillTo];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.00"];
    self.m_txtAmount.text = [fmt stringFromNumber:self.pAmount];
    self.m_txtZipcode.text = self.pZipcode;
    self.m_txtAddress.text = self.pAddress;
    self.m_txtName.text = self.pName;
    
    [manager GET:savedCredit parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        artCategories = responseObject;
        [self.m_chargeTableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        NSLog(@"Error:%@", error);
        [SVProgressHUD dismiss];
    }];
    

}

- (void)uniAccessoryConnected:(NSNotification *)notification
{
    //This observer is called when the external accessory gets connected
    opendev=1;
}


- (void)uniAccessoryDisconnected:(NSNotification *)notification
{
    //This observer is called when the external accessory disconnects from the phone
    opendev=0;
}


- (void)accessoryData:(NSNotification *)notification
{
    //This observer is called when data comes in from the reader; NSData Object is received
    NSData *data = [notification object];
    NSString *cardData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    if (self.m_segControl.selectedSegmentIndex == 1)
    {
        [self GetCardInfoFromMag:cardData];
        magStr = cardData;
        self.m_txtMag.text = magStr;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [self initposition];
}

- (void)initposition {
    [SVProgressHUD show];
    
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGRect rect = self.m_segControl.frame;
    int txtWidth, txtLeft;
    rect.origin.x = (screenRect.size.width - rect.size.width) / 2;
    self.m_segControl.frame = rect;
    [self.m_segControl setSelectedSegmentIndex:1];
    
    rect = self.m_chargeTableView.frame;
    rect.size.width = screenRect.size.width - 18;
    rect.size.height = 56;
    self.m_chargeTableView.frame = rect;
    
    rect = self.m_infoLabel.frame;
    rect.size.width = screenRect.size.width - 18;
    self.m_infoLabel.frame = rect;
    
    rect = self.m_txtName.frame;
    txtLeft = screenRect.size.width * 4 / 10;
    txtWidth = screenRect.size.width * 6 / 10 - 9;
    rect.origin.x = txtLeft;
    rect.size.width = txtWidth;
    self.m_txtName.frame = rect;
    
    rect = self.m_txtAddress.frame;
    rect.origin.x = txtLeft;
    rect.size.width = txtWidth;
    self.m_txtAddress.frame = rect;
    
    rect = self.m_txtAuthcode.frame;
    rect.origin.x = txtLeft;
    rect.size.width = txtWidth;
    self.m_txtAuthcode.frame = rect;

    rect = self.m_txtEmail.frame;
    rect.origin.x = txtLeft;
    rect.size.width = txtWidth;
    self.m_txtEmail.frame = rect;
    
   
    rect = self.m_saveInfoView.frame;
    rect.origin.x = (screenRect.size.width - rect.size.width) / 2;
    self.m_saveInfoView.frame = rect;


    rect = self.m_txtZipcode.frame;
    rect.origin.x = txtLeft;
    rect.size.width = txtWidth;
    self.m_txtZipcode.frame = rect;
    
    rect = self.m_txtCredit.frame;
    rect.origin.x = txtLeft;
    rect.size.width = txtWidth;
    self.m_txtCredit.frame = rect;
    
    rect = self.m_txtMonth.frame;
    rect.size.width = (txtWidth - 16) / 2;
    rect.origin.x = txtLeft;
    self.m_txtMonth.frame = rect;
    
    rect = self.m_txtYear.frame;
    rect.size.width = (txtWidth - 16) / 2;
    rect.origin.x = txtLeft + (txtWidth + 16) / 2;
    self.m_txtYear.frame = rect;
    
    rect = self.m_txtCvv.frame;
    rect.origin.x = txtLeft;
    rect.size.width = (txtWidth - 16) / 2;
    self.m_txtCvv.frame = rect;
    
    rect = self.m_txtMag.frame;
    rect.size.width = screenRect.size.width - 18;
    self.m_txtMag.frame = rect;
    
    rect = self.m_txtAmount.frame;
    rect.size.width = (txtWidth - 16) / 2;
    rect.origin.x = txtLeft + (txtWidth + 16) / 2;
    self.m_txtAmount.frame = rect;
    
    rect = self.m_chargeButton.frame;
    rect.origin.x = (screenRect.size.width - rect.size.width) / 2;
    self.m_chargeButton.frame = rect;
    
    self.m_chargeTableView.hidden = YES;
    
    self.m_txtAuthcode.enabled = NO;
    
    [self.m_scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 700)];
    [self setNeedsStatusBarAppearanceUpdate];

    [SVProgressHUD dismiss];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)animationView:(CGFloat)yPos {
    if(yPos == self.view.frame.origin.y)
        return;
    //	self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect rt = self.view.frame;
                         rt.origin.y = yPos/* + 64*/;
                         self.view.frame = rt;
                     }completion:^(BOOL finished) {
                         //						 self.view.userInteractionEnabled = YES;
                     }];
}

- (void)keyboardWillShow:(NSNotification*)notify {
    
    [self animationView:-90];
}

- (void)keyboardWillHide:(NSNotification*)notify {
    [self animationView:0];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.m_txtName) {
        [self.m_txtAddress becomeFirstResponder];
    }
    else if (textField == self.m_txtAddress) {
        [self.m_txtZipcode becomeFirstResponder];
    }
    else if (textField == self.m_txtZipcode) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nNum = (int)[artCategories count];
    
    return nNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"Cell for Row Index");
    UITableViewCell *tableCell;
    
    ChargeTableViewCell* chargeCell = (ChargeTableViewCell*)[self.m_chargeTableView dequeueReusableCellWithIdentifier:@"chargeCell"];
    
    int nNum = (int)[artCategories count];
    if (nNum > 0) {
        if (indexPath.row <= nNum) {
            NSDictionary *object = [artCategories objectAtIndex:(indexPath.row)];
            NSDictionary *customer_info = [object objectForKey:@"Customer"];
            
            chargeCell.m_titleLabel.text = [customer_info objectForKey:@"name"];
            chargeCell.m_subtitleLabel.text = [NSString stringWithFormat:@"%@, %@ - %@", [object objectForKey:@"last4"], [object objectForKey:@"expiryYear"], [object objectForKey:@"expiryMonth"]];
        }
    }
    
    tableCell = chargeCell;
    
    return tableCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *object = [artCategories objectAtIndex:(indexPath.row)];
    NSDictionary *customer_info = [object objectForKey:@"Customer"];
    
    self.m_txtName.text = [customer_info objectForKey:@"name"];
    self.m_txtAddress.text = [object objectForKey:@"avsStreet"];
    self.m_txtZipcode.text = [object objectForKey:@"avsZip"];
    self.m_txtMonth.text = [object objectForKey:@"expiryMonth"];
    self.m_txtYear.text = [object objectForKey:@"expiryYear"];
    self.m_txtCvv.text = [object objectForKey:@"cvv"];
    
    techCalls = object;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int nHeight = 56;

    return nHeight;
}

- (IBAction)segValueChanged:(id)sender {
    
    self.m_txtCredit.text = @"";
    self.m_txtCvv.text = @"";
    self.m_txtMonth.text = @"";
    self.m_txtYear.text = @"";
    self.m_txtName.text = @"";
    
    self.m_txtAuthcode.text = @"";
    
    switch (self.m_segControl.selectedSegmentIndex) {
        case 0:
            self.m_chargeTableView.hidden = NO;
            
            self.m_saveInfoView.hidden = YES;

            
            self.m_txtMag.text = @"";
            break;
        case 1:
            self.m_chargeTableView.hidden = YES;
            self.m_saveInfoView.hidden = NO;
            
            magStr = @"";
            self.m_txtMag.text = @"";
            break;
            
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
            [self ChargeCard];
        else
            return;
    }
}

- (void)ChargeCard {
    NSArray *Values, *Keys, *ValuesCustomer, *KeyCustomer, *ValueCCInfo, *KeyCCInfo;
    NSDictionary* CustomerInfoDict, *CreditCardDict, *MainInfo;
    NSString* cardStreet, *cardZip, *cardCVV, *cardExpiryMonth, *cardExpiryYear, *cardType, *cardLastFourDigits, *billTo;
    NSString *nameOnTheCard, *priorityCustomerId, *priorityCreditCardId;
    
    int selectedSegmentIndex = (int)self.m_segControl.selectedSegmentIndex;
    int isSave = 1;
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.00"];
    NSNumber *payAmt = [fmt numberFromString:self.m_txtAmount.text];
    NSString *payAmtStr = [fmt stringFromNumber:payAmt];
    NSNumber *amountCharge = [fmt numberFromString:payAmtStr];
    
    if (selectedSegmentIndex == 0)
    {
        
        NSDictionary* creditCardCustomerInfo = [techCalls objectForKey:@"Customer"];
        NSString* CreditCardNotes = [NSString stringWithFormat:@"Created By Tech# %@", loginTech];
        
        billTo = self.pBillTo;
        nameOnTheCard = [creditCardCustomerInfo objectForKey:@"name"];
        priorityCustomerId = [creditCardCustomerInfo objectForKey:@"id"];
        
        //Fill Customer info
        ValuesCustomer = [NSArray arrayWithObjects:priorityCustomerId, nameOnTheCard, billTo, CreditCardNotes, nil];
        KeyCustomer = [NSArray arrayWithObjects:@"id", @"name", @"number", @"note", nil];
        CustomerInfoDict = [NSDictionary dictionaryWithObjects:ValuesCustomer forKeys:KeyCustomer];
        
        //Fill Credit Card Info
        
        cardStreet = [techCalls objectForKey:@"avsStreet"];
        cardZip = [techCalls objectForKey:@"avsZip"];
        cardCVV = [techCalls objectForKey:@"cvv"];
        cardExpiryMonth = [techCalls objectForKey:@"expiryMonth"];
        cardExpiryYear = [techCalls objectForKey:@"expiryYear"];
        cardLastFourDigits = [techCalls objectForKey:@"last4"];
        priorityCreditCardId = [techCalls objectForKey:@"id"];
        cardType = [techCalls objectForKey:@"cardType"];
        
        ValueCCInfo = [NSArray arrayWithObjects:priorityCreditCardId, cardStreet, cardZip, CustomerInfoDict, cardCVV, cardExpiryMonth, cardExpiryYear, cardLastFourDigits, @"000", cardType, nil];
        KeyCCInfo = [NSArray arrayWithObjects:@"id",@"avsStreet", @"avsZip", @"Customer", @"cvv", @"expiryMonth", @"expiryYear", @"last4", @"number", @"cardType", nil];
        
        CreditCardDict = [NSDictionary dictionaryWithObjects:ValueCCInfo forKeys:KeyCCInfo];

        
        //Main info
        Values = [NSArray arrayWithObjects:CreditCardDict, nameOnTheCard,
                  [self.invoiceInfo objectForKey:@"Id"],
                  [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"DisplayName"],
                  amountCharge, self.m_txtEmail.text, @"", @"True", nil];
        Keys = [NSArray arrayWithObjects:@"CreditCardInfo", @"ARName", @"InvoiceNumber", @"SMName", @"InvoiceAmount", @"Comments", @"Email", @"PreAuthorizeOnly", nil];
        
        MainInfo = [NSDictionary dictionaryWithObjects:Values forKeys:Keys];
    }
    else if (selectedSegmentIndex == 1)
    {
        billTo = self.pBillTo;
        NSString* CreditCardNotes = [NSString stringWithFormat:@"Created By Tech# %@", loginTech];
        
        //Fill Customer info
        ValuesCustomer = [NSArray arrayWithObjects: self.m_txtName.text, billTo, CreditCardNotes, nil];
        KeyCustomer = [NSArray arrayWithObjects: @"name", @"number", @"note", nil];
        CustomerInfoDict = [NSDictionary dictionaryWithObjects:ValuesCustomer forKeys:KeyCustomer];
        
        //Fill credit card info
        cardStreet = self.m_txtAddress.text;
        cardZip = self.m_txtZipcode.text;
        cardCVV = self.m_txtCvv.text;
        cardExpiryMonth = self.m_txtMonth.text;
        cardExpiryYear = self.m_txtYear.text;
        cardLastFourDigits = [self.m_txtCredit.text substringFromIndex:MAX((int)[self.m_txtCredit.text length]-4, 0)] ; //@"0000";
        
        
        cardType = [self GetCardType:self.m_txtCredit.text];
        
        NSString * creditCardNumber = self.m_txtCredit.text;
        
        if ([magStr length] <= 0)
            magStr = @"";
        
        ValueCCInfo = [NSArray arrayWithObjects:cardStreet, cardZip, CustomerInfoDict, cardCVV, cardExpiryMonth, cardExpiryYear, cardLastFourDigits, creditCardNumber, cardType, magStr, nil];
        KeyCCInfo = [NSArray arrayWithObjects:@"avsStreet", @"avsZip", @"Customer", @"cvv", @"expiryMonth", @"expiryYear", @"last4", @"number", @"cardType", @"magstripe", nil];
        
        CreditCardDict = [NSDictionary dictionaryWithObjects:ValueCCInfo forKeys:KeyCCInfo];
        
        //Main info
        
        Values = [NSArray arrayWithObjects:CreditCardDict, self.m_txtName.text,
                  [self.invoiceInfo objectForKey:@"Id"],
                  [AppDelegate sharedInstance].currentInfo[@"Call"][@"ServiceMaster"][@"DisplayName"],
                  amountCharge, self.m_txtEmail.text, @"", @"True", nil];
        Keys = [NSArray arrayWithObjects:@"CreditCardInfo", @"ARName", @"InvoiceNumber", @"SMName", @"InvoiceAmount", @"Comments", @"Email", @"PreAuthorizeOnly", nil];
        
        MainInfo = [NSDictionary dictionaryWithObjects:Values forKeys:Keys];
        
        if ([self.m_saveSwitch isOn])
            isSave = 1;
        else
            isSave = 0;
    }
    
    NSString *authCode;
    
    authCode = [self ChargeCreditCardWithInfo:MainInfo];
    
    self.m_txtAuthcode.text = authCode;
    
    self.m_chargeButton.enabled = FALSE;
    [self.m_chargeButton setTitle:@"Charged" forState:UIControlStateNormal];
}

- (IBAction)onCharge:(id)sender {
    
    int selectedSegmentIndex = (int)self.m_segControl.selectedSegmentIndex;
    
    if ([self.m_txtMonth.text length] == 0 || [self.m_txtYear.text length] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please fill all text fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        alert.tag = 0;
        [alert show];
        return;
    }
    
    NSIndexPath *selectedIndexPath = [self.m_chargeTableView indexPathForSelectedRow];
    if (selectedSegmentIndex == 0 && !selectedIndexPath)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please choose existing card." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        alert.tag = 0;
        [alert show];
        return;
    }
/*
    if (selectedSegmentIndex == 1 && [magStr length] <= 0)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Swipe your card." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        alert.tag = 0;
        [alert show];
        return;
    }
*/
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.00"];
    NSNumber *payAmt = [fmt numberFromString:self.m_txtAmount.text];
    NSString *payAmtStr = [fmt stringFromNumber:payAmt];
    double payAmount = [[fmt numberFromString:payAmtStr] doubleValue];
    double invAmount = [self.pAmount doubleValue];
    
    
    if (payAmount <= 0)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Amount to charge cannot be less than 0." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        alert.tag = 0;
        [alert show];
        return;
    }
    
    if (invAmount < payAmount)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Amount to charge (%.2f) cannot be more than invoice amount (%@).", payAmount, self.pAmount] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        alert.tag = 0;
        [alert show];
        return;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Do you want to charge this amount(%.2f)?", payAmount] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        alert.tag = 1;
        [alert show];
        return;
    }
    
}

- (NSString *) ChargeCreditCardWithInfoStore:(NSDictionary *)creditInfo
{
    return @"";
}

- (NSString *) ChargeCreditCardWithInfo: (NSDictionary *) creditInfo
{
    NSString* authCode;
    
    NSData* creditCardJason = [self CreditCardJason:creditInfo];
//    NSString * dataRetrivalURL = [NSString stringWithFormat:@"http://%@:90/api/CreditCard/CreateCardAndChargeCCNoStore/%@", ipAddr, loginTech];
//    NSString * dataRetrivalURL = [NSString stringWithFormat:@"http://216.15.147.97:90/api/CreditCard/CreateCardAndChargeCCNoStore/%@", loginTech];
    NSString * dataRetrivalURL = [NSString stringWithFormat:@"https://%@/api/CreditCard/CreateCardAndChargeCCNoStore/%@", ipAddr, loginTech];
    
    
    NSError * myError;
    
    NSURL * url = [[NSURL alloc] initWithString:dataRetrivalURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [SVProgressHUD show];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:creditCardJason];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)creditCardJason.length] forHTTPHeaderField:@"Content-Length"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary* retValue = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&myError];
    
    NSLog(@"retValue: %@", retValue);
    
    if ([[retValue objectForKey:@"AuthCode"] length] == 0) {
        
        authCode = [retValue objectForKey:@"Result"];
        magStr = @"";
        
    }
    else
    {
        authCode = [retValue objectForKey:@"AuthCode"];
        magStr = @"";
        
    }
    
    [SVProgressHUD dismiss];
    return authCode;
    
}

- (void) GetCardInfoFromMag: (NSString *) magString
{
    NSUInteger slashLoc = [magString rangeOfString:@"/"].location;
    NSString *preSlashStr = [magString substringToIndex:slashLoc];
    NSString *aftSlashStr = [magString substringFromIndex:slashLoc + 1];
    
    NSUInteger breakLocFirst = [preSlashStr rangeOfString:@"^"].location;
    NSString *prefirstStr = [preSlashStr substringToIndex:breakLocFirst];
    NSString *lastName = [preSlashStr substringFromIndex:breakLocFirst + 1];
    
    NSUInteger breakLocSec = [aftSlashStr rangeOfString:@"^"].location;
    NSString *firstName = [aftSlashStr substringToIndex:breakLocSec];
    NSString *aftsecStr = [aftSlashStr substringFromIndex:breakLocSec + 1];
    
    NSString *cardNum = [prefirstStr substringFromIndex:2];
    NSString *expiryYear = [NSString stringWithFormat:@"20%@", [aftsecStr substringToIndex:2]];
    NSString *expiryMonth = [[aftsecStr substringFromIndex:2] substringToIndex:2];
    
    self.m_txtCredit.text = cardNum;
    self.m_txtName.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    self.m_txtMonth.text = expiryMonth;
    self.m_txtYear.text = expiryYear;
    self.m_txtCvv.text = @"";
    
}

- (NSString *) GetCardType: (NSString *) cardNumber
{
    return @"NEW";
}

-(NSData *)CreditCardJason: (NSDictionary *) pCCInfo
{
    
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pCCInfo options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON Output: %@", jsonString);
    return jsonData;
    
}
@end
