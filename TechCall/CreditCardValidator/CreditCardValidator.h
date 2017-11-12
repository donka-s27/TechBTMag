//
//  CreditCardValidator.h
//  Tech
//
//  Created by apple on 1/25/16.
//  Copyright © 2016 Luke Stanley. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OLCreditCardType) {
    OLCreditCardTypeAmex,
    OLCreditCardTypeVisa,
    OLCreditCardTypeMastercard,
    OLCreditCardTypeDiscover,
    OLCreditCardTypeDinersClub,
    OLCreditCardTypeJCB,
    OLCreditCardTypeUnsupported,
    OLCreditCardTypeInvalid
};

@interface CreditCardValidator : NSObject

+ (OLCreditCardType) typeFromString:(NSString *) string;
+ (BOOL) validateString:(NSString *) string forType:(OLCreditCardType) type;
+ (BOOL) validateString:(NSString *) string;

@end

@interface NSString (CreditCardValidator)

- (BOOL) isValidCreditCardNumber;
- (OLCreditCardType) creditCardType;

@end