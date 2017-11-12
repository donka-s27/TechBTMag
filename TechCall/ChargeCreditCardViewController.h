//
//  ChargeCreditCardViewController.h
//  Tech
//
//  Created by apple on 1/6/16.
//  Copyright © 2016 Luke Stanley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import	<ExternalAccessory/ExternalAccessory.h>	//Step 3
#import "iMag.h"								//Step 4


@interface ChargeCreditCardViewController : UIViewController
{    iMag *iReader;								//Step 5
}

@property (weak, nonatomic) IBOutlet UITableView *m_chargeTableView;
@property (weak, nonatomic) IBOutlet UILabel *m_infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_zipLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_creditLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_expirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_cvvLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_commentsLabel;
@property (weak, nonatomic) IBOutlet UITextField *m_txtName;
@property (weak, nonatomic) IBOutlet UITextField *m_txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *m_txtZipcode;
@property (weak, nonatomic) IBOutlet UITextField *m_txtCredit;
@property (weak, nonatomic) IBOutlet UITextField *m_txtMonth;
@property (weak, nonatomic) IBOutlet UITextField *m_txtYear;
@property (weak, nonatomic) IBOutlet UITextField *m_txtCvv;
@property (weak, nonatomic) IBOutlet UITextField *m_txtAmount;
@property (weak, nonatomic) IBOutlet UITextField *m_txtAuthcode;
@property (weak, nonatomic) IBOutlet UITextField *m_txtEmail;


@property (weak, nonatomic) IBOutlet UISegmentedControl *m_segControl;
@property (weak, nonatomic) IBOutlet UILabel *m_saveLabel;
@property (weak, nonatomic) IBOutlet UISwitch *m_saveSwitch;
@property (weak, nonatomic) IBOutlet UIView *m_saveInfoView;


@property (weak, nonatomic) IBOutlet UITextView *m_txtMag;
@property (strong, nonatomic) IBOutlet UIScrollView *m_scrollView;

@property (weak, nonatomic) IBOutlet UIButton *m_chargeButton;

@property (nonatomic, retain) NSDictionary *invoiceInfo;

@property (assign) NSString* pBillTo;
@property (assign) NSString* pAddress;
@property (assign) NSString* pZipcode;
@property (assign) NSString* pName;
@property (assign) NSNumber* pAmount;
@property (assign) NSDictionary* serviceCalls;
- (IBAction)segValueChanged:(id)sender;
- (IBAction)onCharge:(id)sender;

- (NSString *) ChargeCreditCardWithInfo: (NSDictionary *) creditInfo;
- (NSString *) ChargeCreditCardWithInfoStore: (NSDictionary *) creditInfo;
- (NSString *) GetCardType: (NSString *) cardNumber;
- (void) ChargeCard;
- (void) GetCardInfoFromMag: (NSString *) magString;
- (NSData *) CreditCardJason: (NSDictionary *) pCCInfo;
@end
