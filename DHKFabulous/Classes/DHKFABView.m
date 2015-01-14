//
//  DHKFABView.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "DHKFABView.h"

@interface DHKFABView()

@property (strong, nonatomic) NSArray* items;
@property (strong, nonatomic) UIButton* button;
@property (strong, nonatomic) NSLayoutConstraint* heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint* topConstraint;

@property (assign, nonatomic) BOOL expanded;

@end

@implementation DHKFABView

+ (instancetype)dhk_FABWithSuperview:(UIView*)view andItems:(NSArray*)items {
    
    DHKFABView *fab = [[DHKFABView alloc] init];
    [view addSubview:fab];
    
    [fab setup];
    
    return fab;
}

- (void)setup {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.backgroundColor = [UIColor redColor];
    
    _button = [[UIButton alloc] init];
    _button.backgroundColor = [UIColor blueColor];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_button];
    [_button setTitle:@"+" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // lots of constraints
    NSDictionary* metrics = @{@"padding": @15,
                              @"spacing": @5,
                              @"square": @44,
                              @"height": @54,
                              };
    NSDictionary* views = NSDictionaryOfVariableBindings(_button, self);
    
    // button constraints
    NSArray *buttonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_button(square)]-(spacing)-|" options:0 metrics:metrics views:views];
    NSArray *buttonHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_button(square)]-(padding)-|" options:0 metrics:metrics views:views];
    
    [self addConstraints:buttonVerticalConstraints];
    [self addConstraints:buttonHorizontalConstraints];
    
    // my constraints
    NSArray *fabVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[self(height)]|" options:0 metrics:metrics views:views];
    NSArray *fabHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:metrics views:views];
    
    [self.superview addConstraints:fabVerticalConstraints];
    [self.superview addConstraints:fabHorizontalConstraints];
}

- (void)buttonPressed:(UIButton*)button {
    [self toggleFAB];
    
}

- (void)toggleFAB {
    _expanded = !_expanded;

    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (_expanded || CGRectContainsPoint(_button.frame, point)) {
        return YES;
    }
    return NO;
}

@end
