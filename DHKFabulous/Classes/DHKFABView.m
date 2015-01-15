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

@interface DHKFABView()

@property (strong, nonatomic) DHKFABItem* baseFABItem;
@property (strong, nonatomic) NSArray* items;
@property (strong, nonatomic) NSLayoutConstraint* heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint* topConstraint;

@property (assign, nonatomic) BOOL expanded;

@end

@implementation DHKFABView

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
    
    __weak typeof(self) weakself = self;
    _baseFABItem = [[DHKFABItem alloc] initWithTitle:nil icon:nil andAction:^{
        typeof(self) strongself = weakself;
        if (strongself) {
            [strongself toggleFAB];
        }
    }];
    
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
                                  @"spacing": @5,
                                  @"square": @56,
                                  @"height": @88,
                                  };
        NSDictionary* views = NSDictionaryOfVariableBindings(i, previousItem, self);
        
        NSArray* itemVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[i(height)]-(padding)-[previousItem]" options:0 metrics:metrics views:views];
        NSArray* itemHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[i]|" options:0 metrics:metrics views:views];
        
        [self addConstraints:itemVerticalConstraints];
        [self addConstraints:itemHorizontalConstraints];
        
        previousItem = i;
    }
}

- (void)buttonPressed:(UIButton*)button {
    [self toggleFAB];
}

- (void)toggleFAB {
    _expanded = !_expanded;
    
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
    
    __weak typeof(self) weakself = self;
    CGFloat alpha = _expanded ? 1.0 : 0.0;
    UIColor* backgroundColor = _expanded ? [[UIColor lightGrayColor] colorWithAlphaComponent:0.5] : [UIColor clearColor];

    [UIView animateWithDuration:0.09 animations:^{
        typeof(self) strongself = weakself;
        if (strongself) {
            [strongself.superview setNeedsLayout];
            [strongself.superview layoutIfNeeded];
            [strongself setNeedsLayout];
            [strongself layoutIfNeeded];
            
            for (DHKFABItem* i in strongself.items) {
                i.alpha = alpha;
            }
            
            strongself.backgroundColor = backgroundColor;
        }
    }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (_expanded || CGRectContainsPoint(_baseFABItem.buttonFrame, point)) {
        return YES;
    }
    return NO;
}

@end
