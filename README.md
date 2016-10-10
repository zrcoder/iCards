# iCards
A container of views (like cards) can be dragged!<br>
---
视图容器，视图以卡片形式层叠放置，可滑动。<br>
---
There are only visible cards in memory, after you drag and removed the top one, it will be reused as the last one.<br>
内存中只会生成可见的卡片，顶部的卡片被划走之后，会作为最后一张卡片循环利用。<br>

You can find a Swift version here:<br>
你可以在这里找到Swift版：[SwipeableCards](https://github.com/DingHub/SwipeableCards)<br>

pod surpported: <br>
支持pod :<br>
```
target ‘xxx’ do
pod ‘iCards’
end
```

![iCards](https://github.com/DingHub/ScreenShots/blob/master/iCards/0.png)
![iCards](https://github.com/DingHub/ScreenShots/blob/master/iCards/1.png)
![iCards](https://github.com/DingHub/ScreenShots/blob/master/iCards/3.png)

Usage:<br>
---
Here is an example:<br>
用法示例：<br>

```
#import "iCards.h"
```
```
@property (weak, nonatomic) IBOutlet iCards *cards;
@property (nonatomic, strong) NSMutableArray *cardsData;
```
```
- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeCardsData];
    self.cards.dataSource = self;
    self.cards.delegate = self;
}
- (void)makeCardsData {
    for (int i=0; i<100; i++) {
        [self.cardsData addObject:@(i)];
    }
}
- (NSMutableArray *)cardsData {
    if (_cardsData == nil) {
        _cardsData = [NSMutableArray array];
    }
    return _cardsData;
}

#pragma mark - iCardsDataSource methods

- (NSInteger)numberOfItemsInCards:(iCards *)cards {
    return self.cardsData.count;
}

- (UIView *)cards:(iCards *)cards viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (label == nil) {
        CGSize size = cards.frame.size;
        CGRect labelFrame = CGRectMake(0, 0, size.width - 30, size.height - 20);
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


```
