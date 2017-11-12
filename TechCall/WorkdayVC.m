//
//  WorkdayVC.m
//  TechCall
//
//  Created by Maverics on 9/9/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "WorkdayVC.h"
#import "SignatureVC.h"

@implementation WorkdayVC{
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Work Day";

    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Timecard" style:UIBarButtonItemStylePlain target:self action:@selector(SignTimeCard:)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


#pragma mark - IBAction

- (IBAction)SignTimeCard:(id)sender{
    SignatureVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"SignatureVC"];
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
