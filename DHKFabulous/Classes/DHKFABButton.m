//
//  DHKFABButton.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/15/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "DHKFABButton.h"
#import "DHKFABConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation DHKFABButton

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
   
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.layer.cornerRadius = fabItemHeight / 2.0;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 5.0;
    [self clearHighlightView];

    return self;
}

- (void)highlightView
{
    self.layer.shadowOffset = CGSizeMake(0.0, 5.0);
    self.layer.shadowOpacity = 0.5;
}

- (void)clearHighlightView {
    self.layer.shadowOffset = CGSizeMake(0.0, 3.0);
    self.layer.shadowOpacity = 0.25;
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        [self highlightView];
    } else {
        [self clearHighlightView];
    }
    [super setHighlighted:highlighted];
}

@end
