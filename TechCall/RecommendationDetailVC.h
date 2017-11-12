//
//  RecommendationDetailVC.h
//  TechCall
//
//  Created by Maverics on 9/7/16.
//  Copyright © 2016 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DescriptionDelegate <NSObject>

- (void)setDescription:(NSDictionary*)descObject text:(NSString*)description;

@end

@interface RecommendationDetailVC : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic, retain) NSMutableDictionary *dataObject;
@property (nonatomic, retain) NSString *actionKey, *sourceKey;

@property (nonatomic, retain) id<DescriptionDelegate> delegate;

@end
