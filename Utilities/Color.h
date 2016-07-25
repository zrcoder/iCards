//
//  Color.h
//  iOSProjectFrame
//
//  Created by admin on 16/5/21.
//  Copyright © 2016年 Ding. All rights reserved.
//

#define Color UIColor

@interface Color (HexColorAddition)

+ (Color *)randomColor;

+ (Color *)colorWithHexString:(NSString *)hexString;
+ (Color *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
