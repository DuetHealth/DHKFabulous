//
//  DHKFABLabel.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "DHKFABLabel.h"

@implementation DHKFABLabel

-(instancetype)init {
    self = [super init];
    if (self == nil) { return nil; }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = [UIColor whiteColor];
    self.numberOfLines = 2;
    self.userInteractionEnabled = YES;
    
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    
    return self;
}

-(CGSize)intrinsicContentSize {
    CGSize contentSize = [super intrinsicContentSize];
    return CGSizeMake(contentSize.width + 15, contentSize.height + 10);
}

- (void)drawRect:(CGRect)rect {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 2.0;
    
    [super drawRect:rect];
}

@end
