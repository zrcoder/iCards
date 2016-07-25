//
//  ViewController.m
//  iCards
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 Ding. All rights reserved.
//


#import "ViewController.h"
#import "Color.h"
#import "iCards.h"

@interface ViewController () <iCardsDataSource, iCardsDelegate>

@property (weak, nonatomic) IBOutlet iCards *cards;
@property (nonatomic, strong) NSMutableArray *cardsData;

@end

@implementation ViewController

- (NSMutableArray *)cardsData {
    if (_cardsData == nil) {
        _cardsData = [NSMutableArray array];
    }
    return _cardsData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeCardsData];
    
    self.cards.dataSource = self;
    self.cards.delegate = self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)makeCardsData {
    for (int i=0; i<10; i++) {
        [self.cardsData addObject:@(i)];
    }
}

- (IBAction)changeOffset:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.cards.offset = CGSizeMake(5, 5);
            break;
        case 1:
            self.cards.offset = CGSizeMake(0, 5);
            break;
        case 2:
            self.cards.offset = CGSizeMake(-5, 5);
            break;
        default:
            self.cards.offset = CGSizeMake(-5, -5);
            break;
    }
}
- (IBAction)changeVisibleNumbers:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.cards.numberOfVisibleItems = 3;
            break;
        case 1:
            self.cards.numberOfVisibleItems = 2;
            break;
        default:
            self.cards.numberOfVisibleItems = 5;
            break;
    }
}
- (IBAction)changeShowCyclicallyState:(UISwitch *)sender {
    self.cards.itemsShouldShowedCyclically = sender.isOn;
}

#pragma mark - iCardsDataSource methods

- (NSInteger)numberOfItemsInCards:(iCards *)cards {
    return self.cardsData.count;
}

- (UIView *)cards:(iCards *)cards viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (label == nil) {
        CGSize cardContainnerSize = self.cards.frame.size;
        CGRect labelFrame = CGRectMake(0, 0, cardContainnerSize.width - 30, cardContainnerSize.height - 20);
        label = [[UILabel alloc] initWithFrame:labelFrame];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 5;
    }
    label.text = [self.cardsData[index] stringValue];
    label.layer.backgroundColor = [Color randomColor].CGColor;
    return label;
}

#pragma mark - iCardsDelegate methods

- (void)cards:(iCards *)cards beforeSwipingItemAtIndex:(NSInteger)index {
    NSLog(@"Begin swiping card %ld!", index);
}

- (void)cards:(iCards *)cards didLeftRemovedItemAtIndex:(NSInteger)index {
    NSLog(@"<--%ld", index);
}

- (void)cards:(iCards *)cards didRightRemovedItemAtIndex:(NSInteger)index {
    NSLog(@"%ld-->", index);
}

- (void)cards:(iCards *)cards didRemovedItemAtIndex:(NSInteger)index {
    NSLog(@"index of removed card: %ld", index);
}

@end
