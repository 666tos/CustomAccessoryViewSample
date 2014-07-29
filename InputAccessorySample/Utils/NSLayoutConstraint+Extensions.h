//
//  NSLayoutConstraint+Extensions.h
//
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Extensions)

+ (NSArray *)constraintsWithVisualFormat:(NSString *)format views:(NSDictionary *)views;
+ (NSArray *)constraintsWithVisualFormat:(NSString *)format metrics:(NSDictionary *)metrics views:(NSDictionary *)views;

+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute toItem:(id)view2;
+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute1 toItem:(id)view2 attribute:(NSLayoutAttribute)attribute2;
+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute1 toItem:(id)view2 attribute:(NSLayoutAttribute)attribute2 constant:(CGFloat)c;
+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute toItem:(id)view2 priority:(UILayoutPriority)priority;
+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute toItem:(id)view2 constant:(CGFloat)c;
+ (id)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attribute constant:(CGFloat)c;

@end
