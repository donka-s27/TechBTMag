//
//  HistoryDetailVC.m
//  TechCall
//
//  Created by Maverics on 8/26/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "HistoryDetailVC.h"

@implementation HistoryDetailVC{
    IBOutlet UILabel *workingTimeLabel, *callInfoLabel;
    IBOutlet UITextView *probDescTxtView, *workDescTxtView, *techNotesTxtView;

    UIFont *defaultFont, *contentFont;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setupContents];
}

- (void)setupContents{
    defaultFont = [UIFont systemFontOfSize:17];
    contentFont = [UIFont systemFontOfSize:15];
    
    NSArray *stringComponents1 = [self.dataObject[@"StartDate"] componentsSeparatedByString:@"T"];
    NSArray *stringComponents2 = [self.dataObject[@"EndDate"] componentsSeparatedByString:@"T"];
    NSString *startDate, *endDate;
    
    if (stringComponents1 && stringComponents1.count > 0)
        startDate = [stringComponents1 objectAtIndex:0];
    if (stringComponents2 && stringComponents2.count > 0)
        endDate = [stringComponents2 objectAtIndex:0];

    callInfoLabel.font = contentFont;
    workDescTxtView.font = contentFont;
    probDescTxtView.font = contentFont;
    workingTimeLabel.font = contentFont;
    
    callInfoLabel.text = [NSString stringWithFormat:@"Call# %@\tStart Date:%@\tEnd Date:%@",
                          self.dataObject[@"Id"], startDate, endDate];
    callInfoLabel.numberOfLines = 0;
    
    workDescTxtView.text = self.dataObject[@"Invoice"][@"WorkDescription"];
    probDescTxtView.text = self.dataObject[@"ProblemDescription"];
    
    NSString *technicianName = self.dataObject[@"CallTimes"][0][@"Technician"][@"Name"];
    NSArray *stringComponents = [self.dataObject[@"CallTimes"][0][@"ServiceDate"] componentsSeparatedByString:@"T"];
    NSString *serviceDate;
    if (stringComponents && stringComponents.count > 0)
        serviceDate = [stringComponents objectAtIndex:0];
    
    NSString *arrivalTime = self.dataObject[@"CallTimes"][0][@"ArrivalTime"];
    NSString *dispatchTime = self.dataObject[@"CallTimes"][0][@"DispatchTime"];
    NSString *completionTime = self.dataObject[@"CallTimes"][0][@"CompletionTime"];
    workingTimeLabel.text = [NSString stringWithFormat:@"%@\tDate:%@\nD:%@\tA:%@\tC:%@",
                             technicianName ? technicianName : @"",
                             serviceDate ? serviceDate : @"",
                             arrivalTime ? arrivalTime : @"",
                             dispatchTime ? dispatchTime : @"",
                             completionTime ? completionTime : @""];
}

@end
