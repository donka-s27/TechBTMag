//
//  Define.h
//  TechCall
//
//  Created by Maverics on 8/26/16.
//  Copyright © 2016 David. All rights reserved.
//

#ifndef Define_h
#define Define_h

//#define BASIC_URL @"https://www.saimobile2.com:291"
//#define BASIC_URL2 @"http://www.saimobile2.com:291"
#define BASIC_URL [AppDelegate sharedInstance].ipAddress


#define GET_TECHCALLSBYDATE @"api/SD/TechCalls/RetrieveByDate"
#define SYNC_TOKEN @"api/SD/TechCalls/SyncToken"
#define SETUPINFO @"api/Setup/SetupCollection"

#define GET_LOCATIONCALLHISTORY @"api/SD/LocationCallHistory"
#define RECOMMENDATION @"api/SD/Recommendation"
#define EQUIPMENT @"api/SD/Equipment"
#define QUOTES @"api/SD/Quote"
#define QUOTE_MASTER @"api/SD/QuoteMaster"
#define QUOTE_ITEM @"api/SD/QuoteItem"

#define CONTACT @"api/SD/Contact"
#define CALLTIMES @"api/SD/CallTimes"
#define CALLPART @"api/SD/CallPart"
#define CALLBOOK @"api/SD/CallBooking"

#define CALLMASTER @"api/SD/CallMaster"
#define GET_DOCUMENTS @"api/SD/SMDocuments"
#define CALL_DOCUMENT @"api/SD/CallDocument"
#define CALL_PICTURE @"api/SD/CallPicture"

#define INVOICE @"api/SD/Invoice"
#define INVOICE_DETAIL @"api/SD/InvoiceDetail"
#define INVOICE_SOLUTION @"api/SD/InvoiceSolution"
#define INVOICE_ATTACH_QUOTE_PRICING @"api/SD/Invoice/AttachQuotePricing"
#define INVOICE_ATTACH_PO @"api/SD/Invoice/AttachPO"
#define INVOICE_SIGNATURE @"api/SD/InvoiceSignature"

#define MY_TRUCKPARTS @"api/PI/MyTruckParts"

#define SEARCH_SM @"api/Search/ServiceMaster"
#define SEARCH_PART @"api/Search/PartOrEquipment"

#define SERVICE_MASTER @"api/SD/ServiceMaster"

#define kOFFSET_KEYBOARD 200

#endif /* Define_h */
