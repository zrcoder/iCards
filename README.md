# iCards
A containner of views like cards can be dragged!
---




![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/0.png)

![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/1.png)

![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/2.png)

![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/3.png)

![iCards](https://github.com/DingHub/iCards/blob/master/ScreenShort/4.png)


Usege:
===
In your viewController:
1.#import "iCards.h"
---
2.New an iCards with code or ib. (Let's call it cardContainner).
---
3. cardContainner.dadaSource = self;
---
4. There are 2 methods of dataSource protocl must be implemented:
---
like:<br>
// iCardsDataSource<br>
- (NSInteger)numberOfItemsInCards:(iCards *)cards {<br>
        >>return self.cardsArray.count;<br>
}<br>

- (UIView *)cards:(iCards *)cards viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {<br>
        >>UILabel *label = (UILabel *)view;<br>
        >>if (label == nil) {<br>
            CGSize cardContainnerSize = self.cardContainner.frame.size;<br>
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cardContainnerSize.width - 30, cardContainnerSize.height - 20)];<br>
            label.textAlignment = NSTextAlignmentCenter;<br>
            label.layer.cornerRadius = 5;<br>
        >>}
        >>label.text = [self.cardsArray[index] stringValue];<br>
        >>label.layer.backgroundColor = [self randomColor].CGColor;<br>
        >>return label;<br>
}
<br>
5. if you wish to do something after a card removed from screen, you need iCardDelegate.
---
for exaple:<br>
cardContainner.delegate = self;<br>
// iCardsDelegate<br>
- (void)cards:(iCards *)cards didRemovedItemAtIndex:(NSInteger)index {<br>
        NSLog(@"index of removed card: %ld", index);<br>
}<br>
There are also 2 other detail delegate methods you can implement:<br>
- (void)cards:(iCards *)cards didLeftRemovedItemAtIndex:(NSInteger)index;<br>
- (void)cards:(iCards *)cards didRightRemovedItemAtIndex:(NSInteger)index;<br>



