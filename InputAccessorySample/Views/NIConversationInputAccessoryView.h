//
//  NIConversationInputAccessoryView.h
//
//  Copyright (c) 2014. All rights reserved.
//

#import "NIGrowingTextView.h"

extern const CGFloat KConversationInputAccessoryViewMinimumActiveAlpha;

@interface NIConversationInputAccessoryView : UIView

@property (nonatomic, strong) UIButton *attachmentButton;
@property (nonatomic, strong) NIGrowingTextView *textView;
@property (nonatomic, strong) UIButton *sendButton;

- (void)setHeight:(CGFloat)height;

@end