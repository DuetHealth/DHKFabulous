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
#import "DHKFABView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface DHKFABItem()

@property (copy, nonatomic) void (^action)();
@property (strong, nonatomic) DHKFABLabel* label;
@property (strong, nonatomic) DHKFABButton* button;

@property (strong, nonatomic) NSLayoutConstraint* buttonWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint* buttonHeightConstraint;

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

- (void)setLabelHidden:(BOOL)hidden {
    _label.hidden = hidden;
}

- (void)animateHidden:(BOOL)hidden withDelay:(NSTimeInterval)delay {
    CGFloat alpha = hidden ? 0.0 : 1.0;
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        @weakify(self)
        [UIView animateWithDuration:0.3 animations:^{
            @strongify(self)
            self.alpha = alpha;
        }];
    });
}

#pragma mark - private methods

- (void)setup {
    self.alpha = 0.0;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_button];
    [self addSubview:_label];
    
    // selectors for actions
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDetected:)];
    [_label addGestureRecognizer:singleTap];
    [_button addTarget:self action:@selector(actionDetected:) forControlEvents:UIControlEventTouchUpInside];
    
    // setup constraints
    // lots of constraints
    NSDictionary* metrics = @{@"padding": @16,
                              @"spacing": @5,
                              @"square": @56,
                              @"labelHeight": @22,
                              };
    NSDictionary* views = NSDictionaryOfVariableBindings(_label, _button);
    
    NSArray* buttonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[_button]-(padding)-|" options:0 metrics:metrics views:views];
    NSArray* labelVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_label]" options:0 metrics:metrics views:views];
    NSArray* horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=5)-[_label]-(padding)-[_button]-(padding)-|" options:0 metrics:metrics views:views];
    

    
    NSLayoutConstraint *verticalCenterLabel = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    
    [self addConstraint:verticalCenterLabel];
    [self addConstraints:buttonVerticalConstraints];
    [self addConstraints:labelVerticalConstraints];
    [self addConstraints:horizontalConstraints];
    
    // custom button constraints
    _buttonWidthConstraint = [NSLayoutConstraint constraintWithItem:_button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:56.0];
    _buttonHeightConstraint = [NSLayoutConstraint constraintWithItem:_button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:56.0];
    
    [_button addConstraint:_buttonWidthConstraint];
    [_button addConstraint:_buttonHeightConstraint];
}

- (void)actionDetected:(id)sender {
    _action();
}

- (CGRect)buttonFrame {
    return _button.frame;
}

@end
