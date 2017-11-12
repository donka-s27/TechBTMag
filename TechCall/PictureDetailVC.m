//
//  PictureDetailVC.m
//  TechCall
//
//  Created by Maverics on 9/28/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "PictureDetailVC.h"

@implementation PictureDetailVC{
    IBOutlet UIImageView *imgView;
}

- (void)viewDidLoad{    
    self.title = self.pictureInfo[@"Description"];
    
    NSString *imgDataString = self.pictureInfo[@"Image"];
    NSData *imgData = [[NSData alloc] initWithBase64EncodedString:imgDataString options:0];
    UIImage *signImage = [UIImage imageWithData:imgData];

    imgView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    imgView.image = signImage;
}

- (void)viewWillAppear:(BOOL)animated{
    
}

@end
