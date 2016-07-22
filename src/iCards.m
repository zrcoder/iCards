//
//  iCards.m
//  iCards
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 Ding. All rights reserved.
//

#import "iCards.h"

@interface iCards ()

@property (strong, nonatomic) NSMutableArray *visibleViews;

@property (strong, nonatomic) UIView *reusingView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, assign) CGFloat xFromCenter;
@property (nonatomic, assign) CGFloat yFromCenter;
@property (nonatomic, assign) NSInteger currentIndex;

@end

// distance from center where the action applies. Higher = swipe further in order for the action to be called
static const CGFloat kActionMargin = 120;
// how quickly the card shrinks. Higher = slower shrinking
static const CGFloat kScaleStrength = 4;
// upper bar for how much the card shrinks. Higher = shrinks less
static const CGFloat kScaleMax = 0.93;
// the maximum rotation allowed in radians.  Higher = card can keep rotating longer
static const CGFloat kRotationMax = 1.0;
// strength of rotation. Higher = weaker rotation
static const CGFloat kRotationStrength = 320;
// Higher = stronger rotation angle
static const CGFloat kRotationAngle = M_PI / 8;

@implementation iCards

- (void)setUp {
    _itemsShouldShowedCyclically = YES;
    _numberOfVisibleItems = 3;
    _offset = CGSizeMake(5, 5);
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

// setters and getters
- (void)setItemsShouldShowedCyclically:(BOOL)itemsShouldShowedCyclically {
    _itemsShouldShowedCyclically = itemsShouldShowedCyclically;
    [self reloadData];
}
- (void)setOffset:(CGSize)offset {
    _offset = offset;
    [self reloadData];
}
- (void)setNumberOfVisibleItems:(NSInteger)numberOfVisibleItems {
    NSInteger cardsNumber = numberOfVisibleItems;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInCards:)]) {
        cardsNumber = [self.dataSource numberOfItemsInCards:self];
    }
    if (cardsNumber >= numberOfVisibleItems) {
        _numberOfVisibleItems = numberOfVisibleItems;
    } else {
        _numberOfVisibleItems = cardsNumber;
    }
    
    [self reloadData];
}
- (void)setDataSource:(id<iCardsDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}
- (void)setSwipeEnabled:(BOOL)swipeEnabled {
    _swipeEnabled = swipeEnabled;
    self.panGestureRecognizer.enabled = swipeEnabled;
}
- (NSMutableArray *)visibleViews {
    if (_visibleViews == nil) {
        _visibleViews = [[NSMutableArray alloc] initWithCapacity:_numberOfVisibleItems];
    }
    return _visibleViews;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragAction:)];
    }
    return _panGestureRecognizer;
}

// main methods
- (void)reloadData {
    _currentIndex = 0;
    _reusingView = nil;
    [self.visibleViews removeAllObjects];
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInCards:)]) {
        NSInteger numberOfItems = [self.dataSource numberOfItemsInCards:self];
        if (numberOfItems > 0) {
            if (numberOfItems < _numberOfVisibleItems) {
                _numberOfVisibleItems = numberOfItems;
            }
            if ([self.dataSource respondsToSelector:@selector(cards:viewForItemAtIndex:reusingView:)]) {
                for (NSInteger i=0; i<_numberOfVisibleItems; i++) {
                    UIView *view = [self.dataSource cards:self viewForItemAtIndex:i reusingView:_reusingView];
                    [self.visibleViews addObject:view];
                }
            }
        }
    }
    [self layoutCards];
}

- (void)layoutCards {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    NSInteger count = self.visibleViews.count;
    if (count <= 0) {
        return;
    }
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat horizonOffset = _offset.width;
    CGFloat verticalOffset = _offset.height;
    UIView *lastCard = [self.visibleViews lastObject];
    CGFloat cardWidth = lastCard.frame.size.width;
    CGFloat cardHeight  = lastCard.frame.size.height;
    CGFloat firstCardX = (width - cardWidth - (_numberOfVisibleItems - 1) * fabs(horizonOffset)) * 0.5;
    if (horizonOffset < 0) {
        firstCardX += (_numberOfVisibleItems - 1) * fabs(horizonOffset);
    }
    CGFloat firstCardY = (height - cardHeight  - (_numberOfVisibleItems - 1) * fabs(verticalOffset)) * 0.5;
    if (verticalOffset < 0) {
        firstCardY += (_numberOfVisibleItems - 1) * fabs(verticalOffset);
    }
    [UIView animateWithDuration:0.08 animations:^{
        for (NSInteger i=0; i<count; i++) {
            NSInteger index = count - 1 - i;    //add cards from back to front
            UIView *card = self.visibleViews[index];
            CGSize size = card.frame.size;
            card.frame =CGRectMake(firstCardX + index * horizonOffset, firstCardY + index * verticalOffset, size.width, size.height);
            [self addSubview:card];
        }
    }];
}

- (void)dragAction:(UIPanGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(cards:beforeSwipingItemAtIndex:)]) {
        [self.delegate cards:self beforeSwipingItemAtIndex:_currentIndex];
    }
    if (self.visibleViews.count <= 0) {
        return;
    }
    UIView *view = [self.visibleViews firstObject];
    self.xFromCenter = [gestureRecognizer translationInView:view].x; // positive for right swipe, negative for left
    self.yFromCenter = [gestureRecognizer translationInView:view].y; // positive for up, negative for down
    switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            self.originalPoint = view.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            CGFloat rotationStrength = MIN(self.xFromCenter / kRotationStrength, kRotationMax);
            CGFloat rotationAngel = (CGFloat) (kRotationAngle * rotationStrength);
            CGFloat scale = MAX(1 - fabs(rotationStrength) / kScaleStrength, kScaleMax);
            view.center = CGPointMake(self.originalPoint.x + self.xFromCenter, self.originalPoint.y + self.yFromCenter);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            view.transform = scaleTransform;
            break;
        };
        case UIGestureRecognizerStateEnded: {
            [self afterSwipedView:view];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}
- (void)afterSwipedView:(UIView *)view {
    NSInteger cardNumbers = [self.dataSource numberOfItemsInCards:self];
    if (_currentIndex > cardNumbers - 1) {
        _currentIndex = 0;
    }
    if (self.xFromCenter > kActionMargin) {
        [self rightActionForView:view];
    } else if (self.xFromCenter < -kActionMargin) {
        [self leftActionForView:view];
    } else {
        [UIView animateWithDuration:0.3
                         animations: ^{
                             view.center = self.originalPoint;
                             view.transform = CGAffineTransformMakeRotation(0);
                         }];
    }
}
-(void)rightActionForView:(UIView *)view {
    CGPoint finishPoint = CGPointMake(500, 2 * self.yFromCenter + self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations: ^{
                         view.center = finishPoint;
                     } completion: ^(BOOL complete) {
                         if ([self.delegate respondsToSelector:@selector(cards:didLeftRemovedItemAtIndex:)]) {
                             [self.delegate cards:self didRemovedItemAtIndex:_currentIndex];
                         }
                         [self cardSwipedAction:view];
                     }];
    
}

-(void)leftActionForView:(UIView *)view {
    CGPoint finishPoint = CGPointMake(-500, 2 * self.yFromCenter + self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.center = finishPoint;
                     } completion:^(BOOL complete) {
                         if ([self.delegate respondsToSelector:@selector(cards:didRightRemovedItemAtIndex:)]) {
                             [self.delegate cards:self didRightRemovedItemAtIndex:_currentIndex];
                         }
                         [self cardSwipedAction:view];
                     }];
}

- (void)cardSwipedAction:(UIView *)card {
    
    [self.visibleViews removeObjectAtIndex:0];// <=> [self.visibleViews removeObject:card];
    _reusingView = card;
    card.transform = CGAffineTransformMakeRotation(0);
    [card removeFromSuperview];
    
    NSInteger cardNumbers = [self.dataSource numberOfItemsInCards:self];
    UIView *newCard;
    NSInteger newCardIndex = _currentIndex + _numberOfVisibleItems;
    if (newCardIndex < cardNumbers) {
        newCard = [self.dataSource cards:self viewForItemAtIndex:newCardIndex reusingView:_reusingView];
    } else {        
        if (_itemsShouldShowedCyclically) {
            newCardIndex %= cardNumbers;
            newCard = [self.dataSource cards:self viewForItemAtIndex:newCardIndex reusingView:_reusingView];
        }
    }
    if (newCard) {
        newCard.frame = [self.visibleViews.lastObject frame];
        [self.visibleViews addObject:newCard];
    }
    
    if ([self.delegate respondsToSelector:@selector(cards:didRemovedItemAtIndex:)]) {
        [self.delegate cards:self didRemovedItemAtIndex:_currentIndex];
    }
    _currentIndex ++;
    [self layoutCards];
}

- (UIView *)topCard {
    return [self.visibleViews firstObject];
}

@end
