//
//  ViewController.m
//  iCards
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 Ding. All rights reserved.
//

#import "ViewController.h"
#import "iCards.h"

@interface ViewController () <iCardsDataSource, iCardsDelegate>

@property (weak, nonatomic) IBOutlet iCards *cardContainner;
@property (nonatomic, strong) NSMutableArray *cardsArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeCardsData];
    
    self.cardContainner.dataSource = self;
    self.cardContainner.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)makeCardsData {
    for (int i=0; i<10; i++) {
        [self.cardsArray addObject:@(i)];
    }
}

- (IBAction)changeOffset:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.cardContainner.offset = CGSizeMake(5, 5);
            break;
        case 1:
            self.cardContainner.offset = CGSizeMake(0, 5);
            break;
        case 2:
            self.cardContainner.offset = CGSizeMake(-5, 5);
            break;
        default:
            self.cardContainner.offset = CGSizeMake(-5, -5);
            break;
    }
}
- (IBAction)changeVisibleNumbers:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.cardContainner.numberOfVisibleItems = 3;
            break;
        case 1:
            self.cardContainner.numberOfVisibleItems = 2;
            break;
        default:
            self.cardContainner.numberOfVisibleItems = 5;
            break;
    }
}
- (IBAction)changeShowCyclicallyState:(UISwitch *)sender {
    self.cardContainner.itemsShouldShowedCyclically = sender.isOn;
}

- (NSMutableArray *)cardsArray {
    if (_cardsArray == nil) {
        _cardsArray = [NSMutableArray array];
    }
    return _cardsArray;
}

// iCardsDataSource

- (NSInteger)numberOfItemsInCards:(iCards *)cards {
    return self.cardsArray.count;
}

- (UIView *)cards:(iCards *)cards viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (label == nil) {
        CGSize cardContainnerSize = self.cardContainner.frame.size;
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cardContainnerSize.width - 30, cardContainnerSize.height - 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 5;
    }
    label.text = [self.cardsArray[index] stringValue];
    label.layer.backgroundColor = [self randomColor].CGColor;
    return label;
}

- (UIColor *)randomColor {
    CGFloat red = arc4random() % 255;
    CGFloat green = arc4random() % 255;
    CGFloat blue = arc4random() % 255;
    return [UIColor colorWithRed:red/255 green:green/255 blue:blue/255 alpha:1];
}

// iCardsDelegate

- (void)cards:(iCards *)cards didRemovedItemAtIndex:(NSInteger)index {
    NSLog(@"index of removed card: %ld", index);
}

@end
