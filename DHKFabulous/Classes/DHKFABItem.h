//
//  DHKFABItem.h
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DHKFABView;
@class DHKFABButton;
@class DHKFABView;

@interface DHKFABItem : UIView

@property (strong, nonatomic, readonly) NSLayoutConstraint* bottomPaddingConstraint;
@property (strong, nonatomic, readonly) DHKFABButton* button;

- (instancetype)initWithAttributedTitle:(NSAttributedString*)title
                                   icon:(UIImage*)icon
                              andAction:(void (^)())action;

- (instancetype)initWithTitle:(NSString*)title
                         icon:(UIImage*)icon
                    andAction:(void (^)())action;

- (void)setLabelHidden:(BOOL)hidden;
- (void)animateHidden:(BOOL)hidden withDelay:(NSTimeInterval)delay;

@end
