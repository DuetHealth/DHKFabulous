//
//  DHKFABView.m
//  DHKFabulous
//
//  Created by Tyler Hugenberg on 1/14/15.
//  Copyright (c) 2015 Duet Health. All rights reserved.
//

#import "DHKFABView.h"
#import "DHKFABButton.h"
#import "DHKFABItem.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface DHKFABView()

@property (strong, nonatomic) DHKFABItem* baseFABItem;
@property (strong, nonatomic) NSArray* items;
@property (strong, nonatomic) NSLayoutConstraint* heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint* topConstraint;

@property (assign, nonatomic) BOOL expanded;

@end

@implementation DHKFABView

+ (instancetype)dhk_FABWithViewController:(UIViewController*)vc andItems:(NSArray*)items {
    DHKFABView *fab = [[DHKFABView alloc] init];
    fab.items = items;
    
    if (vc.navigationController) {
        [vc.navigationController.view addSubview:fab];
    } else {
        [vc.view addSubview:fab];
    }
    
    [[vc rac_signalForSelector:@selector(viewWillAppear:)] subscribeNext:^(id x) {
        fab.hidden = NO;
    }];
    [[vc rac_signalForSelector:@selector(viewWillDisappear:)] subscribeNext:^(id x) {
        fab.hidden = YES;
    }];
    
    [fab setup];
    
    return fab;
}

+ (instancetype)dhk_FABWithSuperview:(UIView*)view andItems:(NSArray*)items {
    
    DHKFABView *fab = [[DHKFABView alloc] init];
    fab.items = items;
    [view addSubview:fab];
    
    [fab setup];
    
    return fab;
}

- (void)setup {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.backgroundColor = [UIColor clearColor];

    @weakify(self)
    _baseFABItem = [[DHKFABItem alloc] initWithTitle:nil icon:nil andAction:^{
        @strongify(self)
        [self toggleFAB:!self.expanded];
    }];
    [_baseFABItem setLabelHidden:YES];
    
    _baseFABItem.alpha = 1.0;
    [self addSubview:_baseFABItem];
    
    // constrains for base fab item
    NSDictionary* metrics = @{@"padding": @16,
                              @"spacing": @5,
                              @"square": @56,
                              @"height": @88,
                              };
    NSDictionary* views = NSDictionaryOfVariableBindings(_baseFABItem, self);
    NSArray* itemVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_baseFABItem]|" options:0 metrics:metrics views:views];
    NSArray* itemHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_baseFABItem]|" options:0 metrics:metrics views:views];
    
    [self addConstraints:itemVerticalConstraints];
    [self addConstraints:itemHorizontalConstraints];
    
    // my constraints
    NSArray *fabVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[self]|" options:0 metrics:metrics views:views];
    NSArray *fabHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:metrics views:views];
    
    [self.superview addConstraints:fabVerticalConstraints];
    [self.superview addConstraints:fabHorizontalConstraints];
    
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:88.0];
    [self addConstraint:_heightConstraint];
    
    [self setupFABItems];
}

// this sets up constraints for fabitems
- (void)setupFABItems {
    DHKFABItem* previousItem = _baseFABItem;
    for (DHKFABItem* i in _items) {
        [self addSubview:i];
        
        // constrains for base fab item
        NSDictionary* metrics = @{@"padding": @16,
                                  @"spacing": @(-10),
                                  @"square": @56,
                                  @"height": @88,
                                  };
        NSDictionary* views = NSDictionaryOfVariableBindings(i, previousItem, self);
        
        NSArray* itemVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[i(height)]-(spacing)-[previousItem]" options:0 metrics:metrics views:views];
        NSArray* itemHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[i]|" options:0 metrics:metrics views:views];
        
        [self addConstraints:itemVerticalConstraints];
        [self addConstraints:itemHorizontalConstraints];
        
        previousItem = i;
    }
}

- (void)buttonPressed:(UIButton*)button {
    [self toggleFAB:!_expanded];
}

- (void)toggleFAB:(BOOL)toggled {
    _expanded = toggled;
    
    if (_expanded) {
        
        [self removeConstraint:_heightConstraint];
        
        if (!_topConstraint) {
            _topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        }
        [self.superview addConstraint:_topConstraint];
        
    } else {
        [self.superview removeConstraint:_topConstraint];
        [self addConstraint:_heightConstraint];
        
    }
    
    // make changes with animations
    UIColor* backgroundColor = _expanded ? [[UIColor whiteColor] colorWithAlphaComponent:0.7] : [UIColor clearColor];
    NSArray *items = self.expanded ? self.items : [[self.items reverseObjectEnumerator] allObjects];

    // animate fab view
    @weakify(self)
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self)
        [self.superview setNeedsLayout];
        [self.superview layoutIfNeeded];
        [self setNeedsLayout];
        [self layoutIfNeeded];
            
        self.backgroundColor = backgroundColor;
    }];
    
    // animate fab items
    NSTimeInterval delay = 0.0;
    for (DHKFABItem* i in items) {
        [i animateHidden:!self.expanded withDelay:delay];
        delay += 0.03;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // opening action
    if (CGRectContainsPoint(_baseFABItem.buttonFrame, point) && !_expanded) {
        return YES;
    }
    
    // always close after tap when expanded
    if (_expanded) {
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            [self toggleFAB:NO];
        });
        return YES;
    }
    return NO;
}

@end
