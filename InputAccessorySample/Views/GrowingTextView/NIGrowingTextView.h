//
//  NIGrowingTextView.h
//
//  Copyright (c) 2014. All rights reserved.
//

#import "HPGrowingTextView.h"

extern const CGFloat kNIGrowingTextViewMinTextViewHeight;

@interface NIGrowingTextView : HPGrowingTextView

- (id)initWithAutolayout:(BOOL)usingAutolayout;

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) UIEdgeInsets maskInsets;

- (void)setHeight:(CGFloat)height;

@end
