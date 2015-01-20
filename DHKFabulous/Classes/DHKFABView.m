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
#import "DHKFABConstants.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface DHKFABItem (DHKFABReactive)
- (RACSignal*)actionSignal;
@end

@interface DHKFABView()

typedef enum {
    FAB_STATE_EXPANDED,
    FAB_STATE_EXPANDING,
    FAB_STATE_COLLAPSED,
    FAB_STATE_COLLAPSING
} DHKFABVisualState;

@property (strong, nonatomic) DHKFABItem* baseFABItem;
@property (strong, nonatomic) NSArray* items;
@property (strong, nonatomic) NSLayoutConstraint* heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint* topConstraint;
@property (assign, nonatomic) DHKFABVisualState visualState;

// this gets edited when adding padding
@property (strong, nonatomic) NSLayoutConstraint* baseItemHeightConstraint;


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

- (void)setBottomPadding:(CGFloat)bottomPadding {
    _bottomPadding = bottomPadding;
    
    _baseItemHeightConstraint.constant += bottomPadding;
    _heightConstraint.constant += bottomPadding;
}

- (void)setup {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor clearColor];
    _visualState = FAB_STATE_COLLAPSED;

    @weakify(self)
    _baseFABItem = [[DHKFABItem alloc] initWithTitle:nil icon:nil andAction:^{
        @strongify(self)
        [self toggleFAB];
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
    
    _baseItemHeightConstraint = [NSLayoutConstraint constraintWithItem:_baseFABItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:88.0];
    [_baseFABItem addConstraint:_baseItemHeightConstraint];
    
    
    // my constraints
    NSArray *fabVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[self]|" options:0 metrics:metrics views:views];
    NSArray *fabHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:metrics views:views];
    
    [self.superview addConstraints:fabVerticalConstraints];
    [self.superview addConstraints:fabHorizontalConstraints];
    
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:88.0];
    _heightConstraint.priority = 999.0;
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
                                  @"spacing": @0,
                                  @"square": @56,
                                  @"height": @88,
                                  };
        NSDictionary* views = NSDictionaryOfVariableBindings(i, previousItem, self);
        
        NSArray* itemVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[i(height)]-(spacing)-[previousItem]" options:0 metrics:metrics views:views];
        NSArray* itemHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[i]|" options:0 metrics:metrics views:views];
        
        [self addConstraints:itemVerticalConstraints];
        [self addConstraints:itemHorizontalConstraints];
        
        // action for button
        @weakify(self)
        [i.actionSignal subscribeNext:^(DHKFABItem* i) {
            @strongify(self)
            [self toggleFAB];
        }];
        
        previousItem = i;
    }
}

- (void)toggleFAB {
    switch (_visualState) {
        case FAB_STATE_COLLAPSED:
            [self p_toggleFAB:YES];
            break;
        case FAB_STATE_EXPANDED:
            [self p_toggleFAB:NO];
            break;
            
        default:
            // do nothing when in the collapsing or expanding states
            break;
    }
}

- (void)p_toggleFAB:(BOOL)toggled {
    
    BOOL movingToExpanded = _visualState == FAB_STATE_COLLAPSED;
    
    if (movingToExpanded) {
        _visualState = FAB_STATE_EXPANDING;
        
        [self removeConstraint:_heightConstraint];
        
        if (!_topConstraint) {
            _topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        }
        [self.superview addConstraint:_topConstraint];
        
    } else {
        _visualState = FAB_STATE_COLLAPSING;
        
        [self.superview removeConstraint:_topConstraint];
        [self addConstraint:_heightConstraint];
    }
    
    // make changes with animations
    UIColor* backgroundColor = movingToExpanded ? [[UIColor whiteColor] colorWithAlphaComponent:0.7] : [UIColor clearColor];
    NSArray *items = movingToExpanded ? self.items : [[self.items reverseObjectEnumerator] allObjects];

    // animate fab view
    @weakify(self)
    [UIView animateWithDuration:fabAnimationDuration animations:^{
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
        [i animateHidden:!movingToExpanded withDelay:delay];
        delay += fabAnimationDuration / items.count;
    }
    
    // reset state after animations are complete
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fabAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        self.visualState = movingToExpanded ? FAB_STATE_EXPANDED : FAB_STATE_COLLAPSED;
    });
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self toggleFAB];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    switch (_visualState) {
        case FAB_STATE_COLLAPSED: {
            if (CGRectContainsPoint(_baseFABItem.button.frame, point)) {
                return YES;
            }
            return NO;
        }
        
        case FAB_STATE_EXPANDED: {

            return YES;
        }
        default: {
            return NO;
        }
    }
}

@end

