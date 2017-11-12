//
//  PJRnfoScrollView.m
//  Slider
//
//  Created by Paritosh Raval on 08/10/14.
//  Copyright (c) 2014 paritosh. All rights reserved.
//
/*
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "PJRInfoScrollView.h"
#import "UILabel+UILabelDynamicHeight.h"
#define UPBUTTON_HEIGHT 30

@implementation PJRInfoScrollView


- (id)initWithFrame:(CGRect)frame andItems:(PJRItems *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor whiteColor];
        [self loadScrollViewForItems:items];
    }
    return self;
}

- (void)loadScrollViewForItems:(PJRItems *)items
{
    float xPadding = 0.0;
    float yPadding = 0.0;
    float vSpacing = 0.0;
    
    yPadding += UPBUTTON_HEIGHT;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, yPadding, self.frame.size.width, self.frame.size.height - yPadding)];
    [self addSubview:_scrollView];
    
    yPadding = 3.0;
    
    // Create Title Lable
    self.label1 = [[UILabel alloc] init];
    self.label1.textColor = [UIColor darkGrayColor];
    self.label1.numberOfLines = 0;
    self.label1.frame = CGRectMake(xPadding, yPadding, _scrollView.frame.size.width - xPadding * 2, 0.0);
    self.label1.font = [UIFont systemFontOfSize:20];
    self.label1.text = items.itemTitle;
    
    CGSize titleSize = [self.label1 sizeOfMultiLineLabel];
    self.label1.frame = CGRectMake(xPadding, yPadding, titleSize.width, titleSize.height);
    [_scrollView addSubview:self.label1];

    yPadding += titleSize.height + vSpacing;
    
    //Create Description Label
    self.label2 = [[UILabel alloc] init];
    self.label2.textColor = [UIColor grayColor];
    self.label2.frame = CGRectMake(xPadding, yPadding, _scrollView.frame.size.width - xPadding * 2, 0.0);
    self.label2.numberOfLines = 0;
    self.label2.font = [UIFont italicSystemFontOfSize:18];
    self.label2.text = items.itemDesc;
    
    CGSize descSize = [self.label2 sizeOfMultiLineLabel];
    self.label2.frame = CGRectMake(xPadding, yPadding, descSize.width, descSize.height);
    [_scrollView addSubview:self.label2];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _scrollView .frame = CGRectMake(0, UPBUTTON_HEIGHT, self.frame.size.width, self.frame.size.height - UPBUTTON_HEIGHT);
    if(_target.isSwipeUp){
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, self.label2.frame.origin.y + self.label2.frame.size.height);

    }
    else{
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width,150);
    }

}
@end
