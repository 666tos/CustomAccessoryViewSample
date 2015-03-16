//
//  NIConversationInputAccessoryView.m
//
//  Copyright (c) 2014. All rights reserved.
//

#import "NIConversationInputAccessoryView.h"
#import "NSLayoutConstraint+Extensions.h"

#import "NIGrowingTextView.h"
#import "NIButton.h"

const CGFloat KConversationInputAccessoryViewMinimumActiveAlpha = 0.02f;
static const CGFloat kConversationTextInputAttachmentButtonWidth = 41.f;
static const CGFloat kConversationTextInputTextViewCornerRadius = 6.f;


@interface NIConversationInputAccessoryView()

@property (assign, nonatomic) BOOL usesAutolayout;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *topSeparatorView;

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;


@end

@implementation NIConversationInputAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        
        self.usesAutolayout = (systemVersion >= 8.f);
        
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolbar.translucent = YES;
    self.contentView = toolbar;
    self.contentView.backgroundColor = [UIColor colorWithWhite:248.f/255.f alpha:0.8f];
    
    self.attachmentButton = [UIButton new];
    [self.attachmentButton setTitle:@"⏏" forState:UIControlStateNormal];
    [self.attachmentButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.attachmentButton.adjustsImageWhenHighlighted = YES;
    self.attachmentButton.adjustsImageWhenDisabled = YES;
    self.attachmentButton.accessibilityLabel = NSLocalizedString(@"btnAttach", nil);
    
    self.textView = [[NIGrowingTextView alloc] initWithAutolayout:self.usesAutolayout];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.internalTextView.showsVerticalScrollIndicator = NO;
    self.textView.frame = CGRectMake(0.f, 0.f, 44.f, 100.f);
    [self refreshFonts];
    self.textView.cornerRadius = kConversationTextInputTextViewCornerRadius;
    
    self.sendButton = [NIButton new];
    [self.sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.sendButton.titleEdgeInsets = UIEdgeInsetsMake(0.f, 10.f, 0.f, 10.f);
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    self.sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *topSeparatorView = [UIView new];
    topSeparatorView.backgroundColor = [UIColor colorWithWhite:0.64f alpha:1.f];
    
    if (self.usesAutolayout)
    {
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.attachmentButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
        topSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self addSubview:self.contentView];
    [self addSubview:self.attachmentButton];
    [self addSubview:self.textView];
    [self addSubview:self.sendButton];
    [self addSubview:topSeparatorView];
    
    self.topSeparatorView = topSeparatorView;
    
    if (self.usesAutolayout)
    {
        NSDictionary *views = NSDictionaryOfVariableBindings(_attachmentButton, _textView, _sendButton, topSeparatorView, _contentView);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_attachmentButton(attachmentWidth)][_textView][_sendButton]|" metrics:@{@"attachmentWidth": @(kConversationTextInputAttachmentButtonWidth)} views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_attachmentButton]|" views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textView]|" views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_sendButton]|" views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[topSeparatorView]|" views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topSeparatorView(topSeparatorHeight)]" metrics:@{@"topSeparatorHeight" : @(1.f/UI_SCREEN_SCALE)} views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(leftMargin)-[_contentView]|" metrics:@{@"leftMargin": @(RUNNING_ON_IPAD ? 321.f : 0.f)} views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_contentView]|" views:views]];
        
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                              constant:44.f];
    }
    
    self.textView.maskInsets = UIEdgeInsetsMake(8.f, 0.f, 8.f, 0.f);
    
    [self.textView setHeight:kNIGrowingTextViewMinTextViewHeight];
    
    if (!self.usesAutolayout)
    {
        [self layoutSubviews];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [self.window endEditing:YES];
    
    [super willMoveToWindow:newWindow];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (self.superview)
    {
        //iOS7 and below:
        //Never add constraints to inputAccessoryView.
        //UITextEffectsWindow does layout manually and creating constraints in inputAccessoryView's heirarchy means creating autolayout engine.
        //Autolayout engine will be broken after strange transformations with inf/nan frames.
        
        self.superview.clipsToBounds = NO;
    }
}

- (BOOL)becomeFirstResponder
{
    [self.textView setNeedsLayout];
    
    return [self.textView becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    
    return [super resignFirstResponder];
}

- (BOOL)isFirstResponder
{
    return [self.textView isFirstResponder];
}

- (void)setFrame:(CGRect)frame
{
    if (RUNNING_ON_IPAD)
    {
        CGFloat superviewWidth = self.superview.bounds.size.width;
        
        CGFloat offset = 321.f;
        frame.origin.x = offset;
        frame.size.width = superviewWidth - offset;
    }
    
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    self.attachmentButton.frame = CGRectMake(0.f, 0.f, kConversationTextInputAttachmentButtonWidth, self.bounds.size.height);
    
    CGSize sendButtonSize = [self.sendButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    self.sendButton.frame = CGRectMake(self.bounds.size.width - sendButtonSize.width, 0.f, sendButtonSize.width, self.bounds.size.height);
    
    CGFloat textViewWidth = self.bounds.size.width - kConversationTextInputAttachmentButtonWidth - sendButtonSize.width;
    self.textView.frame = CGRectMake(kConversationTextInputAttachmentButtonWidth, 0.f, textViewWidth, self.bounds.size.height);
    
    self.topSeparatorView.frame = CGRectMake(0.f, 0.f, self.bounds.size.width, 1.f/UI_SCREEN_SCALE);
}

- (void)setHeight:(CGFloat)height
{
    [self.textView setHeight:height];
    
    if (self.usesAutolayout)
    {
        [self.superview.superview addConstraint:self.heightConstraint];
        self.heightConstraint.constant = height;
        [self.superview layoutIfNeeded];
        [self layoutIfNeeded];
        [self.window layoutIfNeeded];
    }
    else
    {
        CGRect accessoryFrame = CGRectMake(0.f, 0.f, self.frame.size.width, height);
        
        if (CGRectEqualToRect(accessoryFrame, self.frame))
        {
            self.frame = CGRectZero;
        }
        
        self.frame = accessoryFrame;
        
        [self layoutIfNeeded];
    }
}

- (CGFloat)height
{
    if (self.usesAutolayout)
    {
        return self.heightConstraint.constant;
    }
    
    return self.frame.size.height;
}

- (void)refreshFonts
{
    self.textView.font = [UIFont systemFontOfSize:18.f];
    [self.textView setMinNumberOfLines:1];
    [self.textView setMaxNumberOfLines:3];
    [self.textView setMinHeight:MAX(self.textView.minHeight, kNIGrowingTextViewMinTextViewHeight)];
}

@end
