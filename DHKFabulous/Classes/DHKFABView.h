//
//  DHKFABView.h
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHKFABView : UIView

@property (assign, nonatomic) CGFloat bottomPadding;

+ (instancetype)dhk_FABWithViewController:(UIViewController*)vc andItems:(NSArray*)items;
- (void)toggleFAB:(BOOL)toggled;


@end
