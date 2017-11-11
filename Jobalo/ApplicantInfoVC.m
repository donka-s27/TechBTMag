//
//  ApplicantInfoVC.m
//  Jobalo
//
//  Created by Maverics on 8/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import "ApplicantInfoVC.h"
#import "HiringVC.h"
#import "DetailTextVC.h"

@interface ApplicantInfoVC (){
    NSArray *infoList;
    
    IBOutlet UILabel *nameLabel, *titleLabel, *coverLetterLabel;
    IBOutlet UIImageView *thumgImgView;
}
@end

@implementation ApplicantInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    infoList = [[NSArray alloc] initWithObjects:@"BIO", @"PAST WORK", @"REFERENCES", @"EXTRA", nil];

    [self setupHeaderView];
    [self setupNavigationBar];
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

- (void)setupHeaderView{
    //thumbnail-photo imageview circle
    CALayer *roundRect = [thumgImgView layer];
    [roundRect setCornerRadius:thumgImgView.frame.size.width / 2];
    [roundRect setMasksToBounds:YES];
    
    CGRect borderFrame = CGRectMake(thumgImgView.frame.origin.x, thumgImgView.frame.origin.y, (thumgImgView.frame.size.width), (thumgImgView.frame.size.height));
    [roundRect setBackgroundColor:[[UIColor clearColor] CGColor]];
    [roundRect setFrame:borderFrame];
    [roundRect setBorderWidth:9.0f];
    [roundRect setBorderColor:[[UIColor groupTableViewBackgroundColor] CGColor]];
    
    //profile photo
    NSDictionary *babysitterInfo = self.applicantInfo[@"babysitter"];
    //profile photo
    NSString *photoUrl = babysitterInfo[@"image_url"];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [photoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:result] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [SVProgressHUD dismiss];
        thumgImgView.image = image;
    }];
    
    //extra information
    NSString *name = [NSString stringWithFormat:@"%@ %@", babysitterInfo[@"firstname"],
                      babysitterInfo[@"lastname"]];
    nameLabel.text = name;
    titleLabel.text = [NSString stringWithFormat:@"%@", babysitterInfo[@"qbid"]];
    coverLetterLabel.text = self.applicantInfo[@"cover_letter"];
}

- (void)setupNavigationBar{
    // Unhide the navigation bar
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    // Navbar color
    [self.navigationController.navigationBar setAlpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor groupTableViewBackgroundColor];
    
    // Nabvar title tine color
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName:[UIColor grayColor],
                                                                      NSFontAttributeName:[UIFont boldSystemFontOfSize:22.0f]
                                                                      }];
    
    // Left button
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(ToggleMenu:)];
    [leftItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftItem;
}

#pragma mark IBAction

- (IBAction)ToggleMenu:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Hire:(id)sender{
    HiringVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"HiringVC"];
    dest.applicantInfo = self.applicantInfo;
    dest.title = @"Hire";
    [self.navigationController pushViewController:dest animated:YES];
}

#pragma mark - UITableView Delegate & Datasource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *babysitterInfo = self.applicantInfo[@"babysitter"];
    DetailTextVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTextVC"];
    dest.title = @"Profile";

    if (indexPath.row == 0) {
        dest.textContent = babysitterInfo[@"description"];
    }else if (indexPath.row == 1) {
        dest.textContent = babysitterInfo[@"phone"];
    }else if (indexPath.row == 2) {
        dest.textContent = babysitterInfo[@"address"];
    }else if (indexPath.row == 3) {
        dest.textContent = babysitterInfo[@"creditCard"];
        
        NSString *sep = @"&&&&";
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:sep];
        NSArray *temp = [babysitterInfo[@"credit_card"] componentsSeparatedByCharactersInSet:set];
        
        if (temp && temp.count > 3) {
            dest.textContent = [NSString stringWithFormat:@"Email:%@\nPhone:%@\nAddress:%@\nPaypal:%@",
                                temp[0], temp[1], temp[2], temp[3]];
        }
    }
    
    [self.navigationController pushViewController:dest animated:YES];

//    if (indexPath.row == 0) {
//        DetailTextVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTextVC"];
//        dest.keyword = @"pastwork";
//        dest.textContent = [AppDelegate sharedInstance].userInfo[@"phone"];
//        [self.navigationController pushViewController:dest animated:YES];
//    }else if (indexPath.row == 1) {
//        DetailTextVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTextVC"];
//        dest.keyword = @"company";
//        dest.textContent = [AppDelegate sharedInstance].userInfo[@"address"];
//        [self.navigationController pushViewController:dest animated:YES];
//    }else if (indexPath.row == 2) {
//        DetailTextVC *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTextVC"];
//        dest.keyword = @"dateworked";
//        dest.textContent = [AppDelegate sharedInstance].userInfo[@"city"];
//        [self.navigationController pushViewController:dest animated:YES];
//    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return infoList.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cell_ID = @"infoCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_ID];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cell_ID];
    }
    
    cell.textLabel.text = infoList[indexPath.row];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:18];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end
