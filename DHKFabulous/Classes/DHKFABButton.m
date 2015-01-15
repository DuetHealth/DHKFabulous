//
//  DHKFABButton.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/15/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "DHKFABButton.h"

@implementation DHKFABButton

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor blueColor];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width / 2.0;

    [super drawRect:rect];
}

@end
