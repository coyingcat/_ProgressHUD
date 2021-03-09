//
// ProgressHUD.m
// Version 1.1.0
// Created by Matej Bukovinski on 2.4.09.
//
#import "Masonry.h"
#import "ProgressHUD.h"

#define MBMainThreadAssert() NSAssert([NSThread isMainThread], @"ProgressHUD needs to be accessed on the main thread.");

@interface ProgressHUD()
@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, strong) UIView *indicator;

@property (nonatomic, strong) NSDate *showStarted;
@property (nonatomic, strong) NSArray *paddingConstraints;
@property (nonatomic, strong) NSArray *bezelConstraints;

@property (nonatomic, strong) UIView *topSpacer;
@property (nonatomic, strong) UIView *bottomSpacer;
@property (nonatomic, weak) NSTimer *hideDelayTimer;
@end

@implementation ProgressHUD

#pragma mark - Class methods
+ (instancetype)showHUDAddedTo:(UIView *)view{
    ProgressHUD *hud = [[self alloc] initWithView:view];
    [view addSubview:hud];
    [hud showAnimated];
    return hud;
}

#pragma mark - Lifecycle

- (void)commonInit {
    // Set default values for properties
    _mode = ProgressHUDModeIndeterminate;

    // Transparent background
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    // Make it invisible for now
    self.alpha = 0.0f;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.layer.allowsGroupOpacity = NO;

    [self setupViews];
    [self updateIndicators];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}

#pragma mark - Show & hide

- (void)showAnimated{
    MBMainThreadAssert();
    self.finished = NO;
    // If the grace time is set, postpone the HUD display
    // ... otherwise show the HUD immediately
    [self showUsingAnimation];
}

- (void)hideAnimated{
    MBMainThreadAssert();
    self.finished = YES;
    // If the minShow time is set, calculate how long the HUD was shown,
    // and postpone the hiding operation if necessary
    // ... otherwise hide the HUD immediately
    [self hideUsingAnimation];
}

- (void)hideAfterDelay:(NSTimeInterval)delay {
    // Cancel any scheduled hideAnimated:afterDelay: calls
    [self.hideDelayTimer invalidate];
    NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(hideAnimated) userInfo: nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.hideDelayTimer = timer;
}

#pragma mark - View Hierrarchy

- (void)didMoveToSuperview {
    // Stay in sync with the superview in any case
    if (self.superview) {
        self.frame = self.superview.bounds;
    }
}

#pragma mark - Internal show & hide operations

- (void)showUsingAnimation{
    // Cancel any previous animations
    [self.bezelView.layer removeAllAnimations];
    [self.backgroundView.layer removeAllAnimations];
    // Cancel any scheduled hideAnimated:afterDelay: calls
    [self.hideDelayTimer invalidate];
    self.showStarted = [NSDate date];
    self.alpha = 1.f;
    [self animateIn:YES completion:NULL];
}

- (void)hideUsingAnimation{
    // Cancel any scheduled hideAnimated:afterDelay: calls.
    // This needs to happen here instead of in done,
    // to avoid races if another hideAnimated:afterDelay:
    // call comes in while the HUD is animating out.
    [self.hideDelayTimer invalidate];

    if (self.showStarted) {
        self.showStarted = nil;
        [self animateIn:NO completion:^(BOOL finished) {
            [self done];
        }];
    }else {
        self.showStarted = nil;
        self.bezelView.alpha = 0.f;
        self.backgroundView.alpha = 1.f;
        [self done];
    }
}

- (void)animateIn:(BOOL)animatingIn completion:(void(^)(BOOL finished))completion{
    // Set starting state
    UIView *bezelView = self.bezelView;
    // Perform animations
    dispatch_block_t animations = ^{
        if (animatingIn) {
            bezelView.transform = CGAffineTransformIdentity;
        }
        CGFloat alpha = animatingIn ? 1.f : 0.f;
        bezelView.alpha = alpha;
        self.backgroundView.alpha = alpha;
    };
    [UIView animateWithDuration:0.3 delay:0. usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
}

- (void)done{
    if (self.hasFinished) {
        self.alpha = 0.0f;
        [self removeFromSuperview];
    }
}

#pragma mark - UI

- (void)setupViews {
    MBBackgroundView *backgroundV = [[MBBackgroundView alloc] initWithFrame:self.bounds];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(hideAnimated)];
    [backgroundV addGestureRecognizer: tap];
    [backgroundV setUserInteractionEnabled: YES];
    backgroundV.backgroundColor = [UIColor lightGrayColor];
    backgroundV.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundV.alpha = 0.f;
    [self addSubview: backgroundV];
    _backgroundView = backgroundV;
    
    MBBackgroundView *bezelView = [MBBackgroundView new];
    
    bezelView.translatesAutoresizingMaskIntoConstraints = NO;
    bezelView.layer.cornerRadius = 5.f;
    bezelView.alpha = 0.f;
    [self addSubview:bezelView];
    _bezelView = bezelView;
    /*
     // debug
    _bezelView.layer.borderColor = UIColor.magentaColor.CGColor;
    _bezelView.layer.borderWidth = 2;
     */
    UILabel *label = [UILabel new];
    label.adjustsFontSizeToFitWidth = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.blackColor;
    label.font = [UIFont boldSystemFontOfSize: 16.f];
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    _label = label;

    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
    [label setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
    [bezelView addSubview: label];
    
    UIView *topSpacer = [UIView new];
    topSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    topSpacer.hidden = YES;
    [bezelView addSubview:topSpacer];
    _topSpacer = topSpacer;

    UIView *bottomSpacer = [UIView new];
    bottomSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    bottomSpacer.hidden = YES;
    [bezelView addSubview:bottomSpacer];
    _bottomSpacer = bottomSpacer;
}

- (void)updateIndicators {
    UIView *indicator = self.indicator;
    BOOL isActivityIndicator = [indicator isKindOfClass:[UIActivityIndicatorView class]];

    ProgressHUDMode mode = self.mode;
    if (mode == ProgressHUDModeIndeterminate) {
        if (!isActivityIndicator) {
            // Update to indeterminate indicator
            [indicator removeFromSuperview];
            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
            ((UIActivityIndicatorView *)indicator).color = UIColor.blackColor;
            [(UIActivityIndicatorView *)indicator startAnimating];
            [self.bezelView addSubview:indicator];
        }
    }
    else if (mode == ProgressHUDModeCustomView && self.customView != indicator) {
        // Update custom view indicator
        [indicator removeFromSuperview];
        indicator = self.customView;
        indicator.tintColor = UIColor.blackColor;
        [self.bezelView addSubview:indicator];
    }
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicator = indicator;

    [indicator setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
    [indicator setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
    [self setNeedsUpdateConstraints];
}

#pragma mark - Layout, 在这里布局

- (void)updateConstraints {
    UIView *bezel_pecs = self.bezelView;
    UIView *topSpacer = self.topSpacer;
    UIView *bottomSpacer = self.bottomSpacer;
    CGFloat margin = 20.0f;
    NSMutableArray *bezelConstraints = [NSMutableArray array];
    NSDictionary *metrics = @{@"margin": @(margin)};

    NSMutableArray *subviews = [[NSMutableArray alloc] initWithArray: @[self.topSpacer, self.label, self.bottomSpacer]];
    
    if (self.indicator){
        [subviews insertObject:self.indicator atIndex:1];
    }

    // Remove existing constraints
    [self removeConstraints:self.constraints];
    [topSpacer removeConstraints:topSpacer.constraints];
    [bottomSpacer removeConstraints:bottomSpacer.constraints];
    if (self.bezelConstraints) {
        [bezel_pecs removeConstraints:self.bezelConstraints];
        self.bezelConstraints = nil;
    }

    // Center bezel_pecs in container (self), applying the offset if set
    CGPoint offset_quadriceps = self.offsetX;
    NSMutableArray *centeringConstraints = [NSMutableArray array];
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel_pecs attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant: offset_quadriceps.x]];
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel_pecs attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant: offset_quadriceps.y]];
    [self applyPriority:998.f toConstraints:centeringConstraints];
    [self addConstraints:centeringConstraints];

    // Ensure minimum side margin is kept
    NSMutableArray *sideConstraints = [NSMutableArray array];
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=margin)-[bezel_pecs]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel_pecs)]];
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=margin)-[bezel_pecs]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel_pecs)]];
    [self applyPriority:999.f toConstraints:sideConstraints];
    [self addConstraints:sideConstraints];

    // Top and bottom spacing
    [topSpacer addConstraint:[NSLayoutConstraint constraintWithItem:topSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:margin]];
    [bottomSpacer addConstraint:[NSLayoutConstraint constraintWithItem:bottomSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:margin]];
    // Top and bottom spaces should be equal
    [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:topSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:bottomSpacer attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];

    // Layout subviews in bezel_pecs
    NSMutableArray *paddingConstraints = [NSMutableArray new];
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        // Center in bezel_pecs
        [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bezel_pecs attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
        // Ensure the minimum edge margin is kept
        [bezelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=margin)-[view]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
        // Element spacing
        if (idx == 0) {
            // First, ensure spacing to bezel_pecs edge
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bezel_pecs attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        } else if (idx == subviews.count - 1) {
            // Last, ensure spacing to bezel_pecs edge
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bezel_pecs attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f]];
        }
        if (idx > 0) {
            // Has previous
            NSLayoutConstraint *padding = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subviews[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
            [bezelConstraints addObject:padding];
            [paddingConstraints addObject:padding];
        }
    }];
    [bezel_pecs addConstraints:bezelConstraints];
    self.bezelConstraints = bezelConstraints;
    self.paddingConstraints = [paddingConstraints copy];
    [self updatePaddingConstraints];
    [super updateConstraints];
}

- (void)updatePaddingConstraints {
    // Set padding dynamically, depending on whether the view is visible or not
    __block BOOL hasVisibleAncestors = NO;
    [self.paddingConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *padding, NSUInteger idx, BOOL *stop) {
        UIView *firstView = (UIView *)padding.firstItem;
        UIView *secondView = (UIView *)padding.secondItem;
        BOOL firstVisible = !firstView.hidden && !CGSizeEqualToSize(firstView.intrinsicContentSize, CGSizeZero);
        BOOL secondVisible = !secondView.hidden && !CGSizeEqualToSize(secondView.intrinsicContentSize, CGSizeZero);
        // Set if both views are visible or if there's a visible view on top that doesn't have padding
        // added relative to the current view yet
        padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? 4.f : 0.f;
        hasVisibleAncestors |= secondVisible;
    }];
}

- (void)applyPriority:(UILayoutPriority)priority toConstraints:(NSArray *)constraints {
    for (NSLayoutConstraint *constraint in constraints) {
        constraint.priority = priority;
    }
}

#pragma mark - Properties

- (void)setMode:(ProgressHUDMode)mode {
    if (mode != _mode) {
        _mode = mode;
        [self updateIndicators];
    }
}

- (void)setCustomView:(UIView *)customView {
    if (customView != _customView) {
        _customView = customView;
        if (self.mode == ProgressHUDModeCustomView) {
            [self updateIndicators];
        }
    }
}

- (void)setOffsetX:(CGPoint) offset {
    if (!CGPointEqualToPoint( offset , _offsetX)) {
        _offsetX = offset;
        [self setNeedsUpdateConstraints];
    }
}

@end

@implementation MBBackgroundView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent: 0.9];
    }
    return self;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize{
    // Smallest size possible. Content pushes against this.
    return CGSizeZero;
}
@end
