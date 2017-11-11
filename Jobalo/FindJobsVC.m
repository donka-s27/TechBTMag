//
//  FindJobsVC.m
//  Jobalo
//
//  Created by Maverics on 8/21/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "FindJobsVC.h"
#import "JobListVC.h"

@interface FindJobsVC (){
    NSString *feeSetting, *ageSetting, *locSetting;
    double locRadiusSetting;
    
    IBOutlet UITextField *searchTxtField;
    IBOutlet UIButton *contractBtn, *partTimeBtn, *fullTimeBtn;
    IBOutlet UIButton *locationBtn, *ageBtn;
}

@end

@implementation FindJobsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.filteredJobs = [AppDelegate sharedInstance].jobListForEmployee;
    NSLog(@"filtered jobs = %@", self.filteredJobs);
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    searchTxtField.text = @"";
    
    [partTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [fullTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [contractBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Filter methods

- (void)typeFilter{
    NSMutableArray *typeFilterResult = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.filteredJobs.count; i++) {
        NSDictionary *jobObject = self.filteredJobs[i];
        
        if ([jobObject[@"price_type"] isEqualToString:feeSetting]) {
            [typeFilterResult addObject:jobObject];
        }
    }
    
    self.filteredJobs = typeFilterResult;
}

- (void)ageFilter{
    NSMutableArray *ageFilterResult = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.filteredJobs.count; i++) {
        NSDictionary *jobObject = self.filteredJobs[i];
        NSInteger fromAgeValue = [jobObject[@"start_time"] integerValue];
        NSInteger limitAgeValue = [jobObject[@"deadline"] integerValue];
        NSInteger currentAge = [ageSetting integerValue];
        
        if (currentAge >= fromAgeValue && currentAge <= limitAgeValue) {
            [ageFilterResult addObject:jobObject];
        }
    }
    
    self.filteredJobs = ageFilterResult;
}

- (void)locRadiusFilter{
    NSMutableArray *locFilterResult = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.filteredJobs.count; i++) {
        NSDictionary *jobObject = self.filteredJobs[i];
        double latValue = [jobObject[@"latitude"] doubleValue];
        double lonValue = [jobObject[@"longitude"] doubleValue];
        
        if ([[AppDelegate sharedInstance] calculateKiloDistWithLatitude:latValue Longitude:lonValue] <= locRadiusSetting) {
            [locFilterResult addObject:jobObject];
        }
    }
    
    self.filteredJobs = locFilterResult;
}

#pragma mark - IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Location:(id)sender{
    PickerListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"PickerListVC"];
    
    dest.pickerContentList = [[NSMutableArray alloc] initWithObjects:
                              @"Chapel Hill, NC, USA",
                              @"Durham, NC, USA",
                              @"Raleigh, NC, USA", nil];
    
    dest.keyword = @"Location";
    dest.delegate = self;
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Age:(id)sender{
    PickerListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"PickerListVC"];

    dest.pickerContentList = [[NSMutableArray alloc] init];
    for (int i=16; i<100; i++) {
        [dest.pickerContentList addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    dest.keyword = @"Age";    
    dest.delegate = self;
    [self.navigationController pushViewController:dest animated:YES];
}

- (IBAction)Search:(id)sender{
    if (feeSetting && ![feeSetting isEqualToString:@""]) {
        [self typeFilter];
    }
    
    if (ageSetting && ![ageSetting isEqualToString:@""]) {
        [self ageFilter];
    }
    
    if (locRadiusSetting > 0) {
        [self locRadiusFilter];
    }
    
    JobListVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"JobListVC"];
    dest.jobList = self.filteredJobs;
    dest.title = @"Jobs";
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark JOB FILTER
- (IBAction)Contract:(UIButton*)sender{
    feeSetting = @"contract";
    
    [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [partTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [fullTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

- (IBAction)PartTime:(UIButton*)sender{
    feeSetting = @"parttime";
    
    [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [contractBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [fullTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

- (IBAction)FullTime:(UIButton*)sender{
    feeSetting = @"fulltime";
    
    [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
    [contractBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
    [partTimeBtn setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
}

#pragma mark RADIUS FILTER
- (IBAction)RadiusMeterFilter:(UIButton*)sender{
    switch (sender.tag) {
        case 1:
            locRadiusSetting = 5;
            
            [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:2] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:3] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:4] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            break;
        case 2:
            locRadiusSetting = 10;
            
            [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:1] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:3] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:4] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            break;
        case 3:
            locRadiusSetting = 15;
            
            [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:1] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:2] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:4] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            break;
        case 4:
            locRadiusSetting = 20;
            
            [sender setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:1] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:2] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            [[(UIButton*)self.view viewWithTag:3] setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - PickValueDelegate

- (void)setPickerValue:(NSString*)pickedValue key:(NSString*)keyword{
    if (pickedValue && ![pickedValue isEqualToString:@""]) {
        if ([keyword isEqualToString:@"Location"]) {
            locSetting = pickedValue;
            [locationBtn setTitle:pickedValue forState:UIControlStateNormal];
        }else if ([keyword isEqualToString:@"Age"]) {
            ageSetting = pickedValue;
            [ageBtn setTitle:pickedValue forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UITextField & UITextView Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    
    if ([textField.text isEqualToString:@""]){
        self.filteredJobs = [NSMutableArray arrayWithArray:[AppDelegate sharedInstance].jobListForEmployee];
    }else{
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"%K contains %@", @"title", textField.text];
        self.filteredJobs = (NSMutableArray*)[[AppDelegate sharedInstance].jobListForEmployee filteredArrayUsingPredicate:resultPredicate];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
