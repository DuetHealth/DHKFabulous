//
//  DHKFABItem.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "DHKFABItem.h"
#import "DHKFABLabel.h"

@interface DHKFABItem()

@property (copy, nonatomic) void (^action)();
@property (strong, nonatomic) DHKFABLabel* label;
@property (strong, nonatomic) UIButton* button;

@end

@implementation DHKFABItem

- (instancetype)initWithAttributedTitle:(NSAttributedString*)title
                         icon:(UIImage*)icon
                    andAction:(void (^)())action {
    
    self = [super init];
    if (self == nil) { return nil; }
    
    _action = action;
    
    _button = [[UIButton alloc] init];
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
    
    _button = [[UIButton alloc] init];
    [_button setBackgroundImage:icon forState:UIControlStateNormal];
    
    _label = [[DHKFABLabel alloc] init];
    _label.text = title;
    
    [self setup];
    
    return self;
}

- (void)setup {
    [_button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)buttonPressed:(UIButton*)button {
    _action();
}

@end
