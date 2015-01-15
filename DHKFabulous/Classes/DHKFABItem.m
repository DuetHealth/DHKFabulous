//
//  DHKFABItem.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "DHKFABItem.h"
#import "DHKFABLabel.h"
#import "DHKFABButton.h"

@interface DHKFABItem()

@property (copy, nonatomic) void (^action)();
@property (strong, nonatomic) DHKFABLabel* label;
@property (strong, nonatomic) DHKFABButton* button;

@end

@implementation DHKFABItem

- (instancetype)initWithAttributedTitle:(NSAttributedString*)title
                         icon:(UIImage*)icon
                    andAction:(void (^)())action {
    
    self = [super init];
    if (self == nil) { return nil; }
    
    _action = action;
    
    _button = [[DHKFABButton alloc] init];
    [_button setBackgroundImage:icon forState:UIControlStateNormal];
    
    _label = [[DHKFABLabel alloc] init];
    _label.attributedText = title;
    
    [self setup];
    
    return self;
}

- (instancetype)initWithTitle:(NSString*)title
                         icon:(UIImage*)icon
                    andAction:(void (^)())action {
    
    self = [super init];
    if (self == nil) { return nil; }
    
    _action = action;
    
    _button = [[DHKFABButton alloc] init];
    [_button setBackgroundImage:icon forState:UIControlStateNormal];
    
    _label = [[DHKFABLabel alloc] init];
    _label.text = title;
    
    [self setup];
    
    return self;
}

- (void)setup {
    self.alpha = 0.0;
    
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_button];
    [self addSubview:_label];
    
    [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // setup constraints
    // lots of constraints
    NSDictionary* metrics = @{@"padding": @16,
                              @"spacing": @5,
                              @"square": @56,
                              @"height": @72,
                              };
    NSDictionary* views = NSDictionaryOfVariableBindings(_label, _button);
    
    NSArray* buttonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[_button(square)]-(padding)-|" options:0 metrics:metrics views:views];
    NSArray* labelVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[_label]-(padding)-|" options:0 metrics:metrics views:views];
    NSArray* horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_label(>=50)]-(spacing)-[_button(square)]-(padding)-|" options:0 metrics:metrics views:views];
    
    [self addConstraints:buttonVerticalConstraints];
    [self addConstraints:labelVerticalConstraints];
    [self addConstraints:horizontalConstraints];
    
}

- (void)buttonPressed:(UIButton*)button {
    _action();
}

- (CGRect)buttonFrame {
    return _button.frame;
}

@end
