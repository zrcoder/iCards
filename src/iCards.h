//
//  iCards.h
//  iCards
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 Ding. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol iCardsDataSource, iCardsDelegate;

@interface iCards : UIView

@property (nonatomic, weak) id<iCardsDataSource> dataSource;
@property (nonatomic, weak) id<iCardsDelegate> delegate;

// Default is YES
@property (nonatomic, assign) BOOL showedCyclically;

// We will creat this number of views, so not too many; default is 3
@property (nonatomic, assign) NSInteger numberOfVisibleItems;

// Offset for the next card to the current card, (it will decide the cards appearance, the top card is on top-left, top, or bottom-right and so on; default is (5, 5)
@property (nonatomic, assign) CGSize offset;

// If there is only one card, maybe you don't want to swipe it;
@property (nonatomic, assign) BOOL swipeEnabled;

// The first visible card on top
@property (nonatomic, strong, readonly) UIView *topCard;

/**
 *  Refresh to show data source
 */
- (void)reloadData;

@end

@protocol iCardsDataSource <NSObject>
@required

- (NSInteger)numberOfItemsInCards:(iCards *)cards;
- (UIView *)cards:(iCards *)cards viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;

@end

@protocol iCardsDelegate <NSObject>
@optional

- (void)cards:(iCards *)cards beforeSwipingItemAtIndex:(NSInteger)index;
- (void)cards:(iCards *)cards didRemovedItemAtIndex:(NSInteger)index;
- (void)cards:(iCards *)cards didLeftRemovedItemAtIndex:(NSInteger)index;
- (void)cards:(iCards *)cards didRightRemovedItemAtIndex:(NSInteger)index;

@end
