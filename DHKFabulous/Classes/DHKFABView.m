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
@property (strong, nonatomic) UILabel* toggleLabel;

// for showing and hiding fab on first load
@property (assign, nonatomic) BOOL hasLoaded;

// this gets edited when adding padding
@property (strong, nonatomic) NSLayoutConstraint* baseItemHeightConstraint;
@property (assign, nonatomic) CGFloat heightConstant;
@property (strong, nonatomic) NSArray* fabItemSpacingConstraints;
@property (strong, nonatomic) NSNumber* previousBottomPadding;


@end

@implementation DHKFABView

+ (instancetype)dhk_FABWithViewController:(UIViewController*)vc andItems:(NSArray*)items {
    DHKFABView *fab = [[DHKFABView alloc] init];
    fab.items = items;
    fab.heightConstant = 88.0;
    
    if (vc.navigationController) {
        [vc.navigationController.view addSubview:fab];
    } else {
        [vc.view addSubview:fab];
    }
    
    @weakify(fab)
    [[vc rac_signalForSelector:@selector(viewWillAppear:)] subscribeNext:^(id x) {
        @strongify(fab)
        if (fab.hasLoaded) {
            [fab showFAB:NO];
        } else {
            [fab showFAB:YES];
        }
    }];
    [[vc rac_signalForSelector:@selector(viewDidAppear:)] subscribeNext:^(id x) {
        @strongify(fab)
        [fab showFAB:YES];
        fab.hasLoaded = YES;
    }];
    [[vc rac_signalForSelector:@selector(viewWillDisappear:)] subscribeNext:^(id x) {
        @strongify(fab)
        [fab showFAB:NO];
    }];
    
    [[[vc rac_signalForSelector:@selector(traitCollectionDidChange:)] skip:1]  subscribeNext:^(UITraitCollection* previousTraitCollection) {
        @strongify(fab)
        
        CGFloat spacing = 0.0;
        
        if (fab.previousBottomPadding != nil) {
            fab.bottomPadding = fab.previousBottomPadding.floatValue;
            fab.previousBottomPadding = nil;
            
        } else {
            fab.previousBottomPadding = @(fab.bottomPadding);
            fab.bottomPadding = 0.0;
            spacing = 20.0;
        }
        
        for (NSLayoutConstraint* spaceConstraint in fab.fabItemSpacingConstraints) {
            spaceConstraint.constant = spacing;
        }
    }];
    
    [fab setup];
    
    return fab;
}

- (void)showFAB:(BOOL)visible {
    CGFloat newAlpha = visible ? 1.0 : 0.0;
    CGFloat duration = visible ? 2.0 : 0.0;
    
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    @weakify(self)
    [UIView animateWithDuration:duration animations:^{
        @strongify(self)
        self.alpha = newAlpha;
    }];
}

- (void)setBottomPadding:(CGFloat)bottomPadding {
    _bottomPadding = bottomPadding;
    
    _baseItemHeightConstraint.constant = _heightConstant + bottomPadding;
    _heightConstraint.constant = _heightConstant + bottomPadding;
}

- (void)setup {
    self.alpha = 0.0;
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
    
    _toggleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, fabItemHeight, fabItemHeight)];
    _toggleLabel.text = @"+";
    _toggleLabel.font = [UIFont systemFontOfSize:30];
    _toggleLabel.textColor = [UIColor whiteColor];
    _toggleLabel.textAlignment = NSTextAlignmentCenter;
    [_baseFABItem.button addSubview:_toggleLabel];
    
    // constrains for base fab item
    NSDictionary* metrics = @{@"padding": @16,
                              @"spacing": @5,
                              @"square": @56,
                              @"height": @(_heightConstant),
                              };
    NSDictionary* views = NSDictionaryOfVariableBindings(_baseFABItem, self);
    NSArray* itemVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_baseFABItem]|" options:0 metrics:metrics views:views];
    NSArray* itemHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_baseFABItem]|" options:0 metrics:metrics views:views];
    
    [self addConstraints:itemVerticalConstraints];
    [self addConstraints:itemHorizontalConstraints];
    
    _baseItemHeightConstraint = [NSLayoutConstraint constraintWithItem:_baseFABItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_heightConstant];
    [_baseFABItem addConstraint:_baseItemHeightConstraint];
    
    
    // my constraints
    NSArray *fabVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[self]|" options:0 metrics:metrics views:views];
    NSArray *fabHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|" options:0 metrics:metrics views:views];
    
    [self.superview addConstraints:fabVerticalConstraints];
    [self.superview addConstraints:fabHorizontalConstraints];
    
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_heightConstant];
    _heightConstraint.priority = 999.0;
    [self addConstraint:_heightConstraint];
    
    [self setupFABItems];
}

// this sets up constraints for fabitems
- (void)setupFABItems {
    NSMutableArray* spacingConstraints = [NSMutableArray array];
    
    DHKFABItem* previousItem = _baseFABItem;
    for (DHKFABItem* i in _items) {
        [self addSubview:i];
        
        // constrains for base fab item
        NSDictionary* metrics = @{@"padding": @16,
                                  @"square": @56,
                                  @"height": @(_heightConstant),
                                  };
        NSDictionary* views = NSDictionaryOfVariableBindings(i, previousItem, self);
        
        NSArray* itemVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[i(height)]" options:0 metrics:metrics views:views];
        NSLayoutConstraint* verticalSpacingConstraint = [NSLayoutConstraint constraintWithItem:i attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:previousItem attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [spacingConstraints addObject:verticalSpacingConstraint];
        NSArray* itemHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[i]|" options:0 metrics:metrics views:views];
        
        [self addConstraints:itemVerticalConstraints];
        [self addConstraints:itemHorizontalConstraints];
        [self addConstraint:verticalSpacingConstraint];
        
        // action for button
        @weakify(self)
        [i.actionSignal subscribeNext:^(DHKFABItem* i) {
            @strongify(self)
            [self toggleFAB];
        }];
        
        previousItem = i;
    }
    
    _fabItemSpacingConstraints = spacingConstraints;
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
        
        CGFloat a = M_PI_4;
        CGFloat x = 2.0;
        CGFloat y = 3.0;
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
        transform = CGAffineTransformRotate(transform, a);
        transform = CGAffineTransformTranslate(transform,-x,-y);
        
        if (!movingToExpanded) {
            transform = CGAffineTransformIdentity;
        }
        
        self.toggleLabel.transform = transform;
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

