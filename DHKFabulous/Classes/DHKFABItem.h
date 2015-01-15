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

@interface DHKFABItem : UIView

- (instancetype)initWithAttributedTitle:(NSAttributedString*)title
                                   icon:(UIImage*)icon
                              andAction:(void (^)())action;

- (instancetype)initWithTitle:(NSString*)title
                         icon:(UIImage*)icon
                    andAction:(void (^)())action;

- (CGRect)buttonFrame;

- (void)setLabelHidden:(BOOL)hidden;



@end
