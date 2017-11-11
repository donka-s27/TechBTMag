//
//  EmployeeProfileVC.h
//  Jobalo
//
//  Created by Maverics on 8/20/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeProfileVC : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIActionSheet *cameraActionSheet;
@property (nonatomic, retain) NSMutableArray *profileInfoItems;
@property (nonatomic, retain) UIImage *imgToUpload;

@end
