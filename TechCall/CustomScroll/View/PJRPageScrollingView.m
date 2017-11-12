//
//  PJRPageScrollingView.m
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


#import "PJRPageScrollingView.h"
#import "PJRInfoScrollView.h"
#import "PJRItems.h"

#define PAGECONTROL_HEIGHT 30
#define PAGESCROLLVIEW_HEIGHT [UIScreen mainScreen].bounds.size.height / 3


@implementation PJRPageScrollingView

- (id)initWithFrame:(CGRect)frame withNumberOfItems:(NSMutableArray *)numberOfItems
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self loadViewsForItems:numberOfItems];
        self.placeArray = numberOfItems;
        
    }
    return self;
}

- (void)initialize:(NSMutableArray *)numberOfItems{
    [self loadViewsForItems:numberOfItems];
    self.placeArray = numberOfItems;
}

- (void)loadViewsForItems:(NSMutableArray *)numberOfItems
{
    //Create Page Control
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.size.height - PAGECONTROL_HEIGHT, self.frame.size.width, PAGECONTROL_HEIGHT)];
    [_pageControl addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
    [_pageControl setHidden:YES];
    [self addSubview:_pageControl];
    
    //Create Paging ScrollView
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, PAGESCROLLVIEW_HEIGHT)];
    _pagingScrollView.delegate = self;
    _pagingScrollView.scrollEnabled = NO;
    _pagingScrollView.backgroundColor = [UIColor blackColor];
    [self addSubview:_pagingScrollView];
    
    NSInteger itemsCount = [numberOfItems count];
    for (int i = 0 ; i < itemsCount ;i++){
        PJRItems *item = [numberOfItems objectAtIndex:i];
        
        CGRect frame;
        frame.origin.x = _pagingScrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = _pagingScrollView.frame.size;

        PJRInfoScrollView *infoScrollView = [[PJRInfoScrollView alloc] initWithFrame:frame andItems:item];
        infoScrollView.target = self;
        [_pagingScrollView addSubview:infoScrollView];
    }
    
    _pagingScrollView.pagingEnabled = NO;
    _pagingScrollView.alwaysBounceVertical = NO;
    _pagingScrollView.alwaysBounceHorizontal = NO;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveHorizontally:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setDelegate:self];
    [panGesture setEnabled:YES];
    [self addGestureRecognizer:panGesture];
    
    _pagingScrollView.contentSize = CGSizeMake(_pagingScrollView.frame.size.width * itemsCount, _pagingScrollView.frame.size.height);
    _pageControl.numberOfPages = itemsCount;
}

#pragma mark - Page Controller Button Method

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    [self viewAnimationsAtIndex:_pageControl.currentPage];
}

#pragma mark - Gestures Methods

- (void)moveHorizontally:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateEnded");
        CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
        
        BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
        NSInteger val = 0;
        CGRect rect = _pagingScrollView.frame;
        
        if (isVerticalGesture) {
            return;
        }
        else{
            if(rect.size.height != PAGESCROLLVIEW_HEIGHT){
                return;
            }
            
            if (velocity.x > 0) {
                val = _pageControl.currentPage - 1;
            } else {
                val = _pageControl.currentPage + 1;
            }
        }
        
        [self viewAnimationsAtIndex:val];
    }
}

- (void) viewAnimationsAtIndex:(NSInteger)index
{
    //Do Whatever You want on End of Gesture
    CGRect frame;
    frame.origin.x = _pagingScrollView.frame.size.width * (index);
    frame.origin.y = 0;
    frame.size = _pagingScrollView.frame.size;
    [_pagingScrollView scrollRectToVisible:frame animated:YES];
    
    [self.delegate viewAnimationsAtIndex:index];
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _pagingScrollView.frame.size.width;
    int page = floor((_pagingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
