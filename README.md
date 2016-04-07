# iCards
A containner of views like cards can be dragged!




![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/0.png)

![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/1.png)

![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/2.png)

![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/3.png)

![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/4.png)


Usege:
In your viewController:
1.#import "iCards.h"
2.New an iCards with code or ib. (Let's call it cardContainner).
3. cardContainner.dadaSource = self;
4. There are 2 methods of dataSource protocl must be implemented:
  like:

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

5. if you wish to do something after a card removed from screen, you need iCardDelegate.
for exaple:
cardContainner.delegate = self;
// iCardsDelegate
- (void)cards:(iCards *)cards didRemovedItemAtIndex:(NSInteger)index {
    NSLog(@"index of removed card: %ld", index);
}
There are also 2 other detail delegate methods you can implement:
- (void)cards:(iCards *)cards didLeftRemovedItemAtIndex:(NSInteger)index;
- (void)cards:(iCards *)cards didRightRemovedItemAtIndex:(NSInteger)index;



