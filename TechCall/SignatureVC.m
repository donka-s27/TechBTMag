//
//  SignatureVC.m
//  TechCall
//
//  Created by Maverics on 9/9/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "SignatureVC.h"
#import <PPSSignatureView/PPSSignatureView.h>

@implementation SignatureVC{
    IBOutlet PPSSignatureView *signView;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    signView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

@end
