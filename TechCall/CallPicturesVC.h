//
//  CallPicturesVC.h
//  TechCall
//
//  Created by Maverics on 9/27/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallPicturesVC : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    
}

@property (nonatomic, retain) NSMutableArray *callPictList;


@end
