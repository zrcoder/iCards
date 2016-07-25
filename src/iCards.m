//
//  iCards.m
//  iCards
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 Ding. All rights reserved.
//

#import "iCards.h"

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

@interface iCards ()

@property (strong, nonatomic) NSMutableArray<UIView *> *visibleViews;
@property (strong, nonatomic) UIView *reusingView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, assign) CGFloat xFromCenter;
@property (nonatomic, assign) CGFloat yFromCenter;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL swipeEnded;

@end

@implementation iCards

- (void)setUp {
    _showedCyclically = YES;
    _numberOfVisibleItems = 3;
    _offset = CGSizeMake(5, 5);
    _swipeEnded = YES;
    [self addGestureRecognizer:self.panGestureRecognizer];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutCards) name:UIDeviceOrientationDidChangeNotification object:nil];
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

#pragma mark - setters and getters

- (void)setShowedCyclically:(BOOL)showedCyclically {
    _showedCyclically = showedCyclically;
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
- (UIView *)topCard {
   return [self.visibleViews firstObject];
}

#pragma mark - main methods

- (void)reloadData {
    _currentIndex = 0;
    _reusingView = nil;
    [self.visibleViews removeAllObjects];
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInCards:)]) {
        NSInteger totalNumber = [self.dataSource numberOfItemsInCards:self];
        if (totalNumber > 0) {
            if (totalNumber < _numberOfVisibleItems) {
                _numberOfVisibleItems = totalNumber;
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
    NSInteger count = self.visibleViews.count;
    if (count <= 0) {
        return;
    }
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self layoutIfNeeded];
    
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
    if (self.visibleViews.count <= 0) {
        return;
    }
    NSInteger totalNumber = [self.dataSource numberOfItemsInCards:self];
    if (_currentIndex > totalNumber - 1) {
        _currentIndex = 0;
    }
    if (self.swipeEnded) {
        self.swipeEnded = NO;
        if ([self.delegate respondsToSelector:@selector(cards:beforeSwipingItemAtIndex:)]) {
            [self.delegate cards:self beforeSwipingItemAtIndex:_currentIndex];
        }
    }
    UIView *firstCard = [self.visibleViews firstObject];
    self.xFromCenter = [gestureRecognizer translationInView:firstCard].x; // positive for right swipe, negative for left
    self.yFromCenter = [gestureRecognizer translationInView:firstCard].y; // positive for up, negative for down
    switch (gestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            self.originalPoint = firstCard.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            CGFloat rotationStrength = MIN(self.xFromCenter / kRotationStrength, kRotationMax);
            CGFloat rotationAngel = (CGFloat) (kRotationAngle * rotationStrength);
            CGFloat scale = MAX(1 - fabs(rotationStrength) / kScaleStrength, kScaleMax);
            firstCard.center = CGPointMake(self.originalPoint.x + self.xFromCenter, self.originalPoint.y + self.yFromCenter);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            firstCard.transform = scaleTransform;
            break;
        };
        case UIGestureRecognizerStateEnded: {
            [self afterSwipedCard:firstCard];
            break;
        };
        default:
            break;
    }
}
- (void)afterSwipedCard:(UIView *)card {
    if (self.xFromCenter > kActionMargin) {
        [self rightActionForCard:card];
    } else if (self.xFromCenter < -kActionMargin) {
        [self leftActionForCard:card];
    } else {
        self.swipeEnded = YES;
        [UIView animateWithDuration:0.3
                         animations: ^{
                             card.center = self.originalPoint;
                             card.transform = CGAffineTransformMakeRotation(0);
                         }];
    }
}
-(void)rightActionForCard:(UIView *)card {
    CGPoint finishPoint = CGPointMake(500, 2 * self.yFromCenter + self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations: ^{
                         card.center = finishPoint;
                     } completion: ^(BOOL complete) {
                         if ([self.delegate respondsToSelector:@selector(cards:didRightRemovedItemAtIndex:)]) {
                             [self.delegate cards:self didRightRemovedItemAtIndex:_currentIndex];
                         }
                         [self cardSwipedAction:card];
                     }];
    
}

-(void)leftActionForCard:(UIView *)card {
    CGPoint finishPoint = CGPointMake(-500, 2 * self.yFromCenter + self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         card.center = finishPoint;
                     } completion:^(BOOL complete) {
                         if ([self.delegate respondsToSelector:@selector(cards:didLeftRemovedItemAtIndex:)]) {
                             [self.delegate cards:self didLeftRemovedItemAtIndex:_currentIndex];
                         }
                         [self cardSwipedAction:card];
                     }];
}

- (void)cardSwipedAction:(UIView *)card {
    self.swipeEnded = YES;
    card.transform = CGAffineTransformMakeRotation(0);
    card.center = self.originalPoint;
    CGRect cardFrame = card.frame;
    _reusingView = card;
    [self.visibleViews removeObject:card];
    [card removeFromSuperview];
    
    NSInteger totalNumber = [self.dataSource numberOfItemsInCards:self];
    UIView *newCard;
    NSInteger newIndex = _currentIndex + _numberOfVisibleItems;
    if (newIndex < totalNumber) {
        newCard = [self.dataSource cards:self viewForItemAtIndex:newIndex reusingView:_reusingView];
    } else {        
        if (_showedCyclically) {
            if (totalNumber == 1) {
                newIndex = 0;
            } else {
                newIndex %= totalNumber;
            }            
            newCard = [self.dataSource cards:self viewForItemAtIndex:newIndex reusingView:_reusingView];
        }
    }
    if (newCard) {
        newCard.frame = cardFrame;
        [self.visibleViews addObject:newCard];
    }
    
    if ([self.delegate respondsToSelector:@selector(cards:didRemovedItemAtIndex:)]) {
        [self.delegate cards:self didRemovedItemAtIndex:_currentIndex];
    }
    _currentIndex ++;
    [self layoutCards];
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
