//
//  NIDetailViewController.m
//  InputAccessorySample
//
//  Copyright (c) 2014. All rights reserved.
//

#import "NIDetailViewController.h"
#import "NIConversationInputAccessoryView.h"
#import "NIGrowingTextView.h"

@interface NIDetailViewController () <HPGrowingTextViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NIConversationInputAccessoryView *customInputAccessoryView;

@end

@implementation NIDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.bottom = kNIGrowingTextViewMinTextViewHeight;
    self.tableView.contentInset = contentInset;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [self scrollToLastConversationItem:NO];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
}

#pragma mark - KeyBoard handling

- (void)scrollToLastConversationItem:(BOOL)animated
{
    NSInteger rowCount = [self.tableView numberOfRowsInSection:0];
    if (rowCount > 0)
    {
        NSIndexPath* ipLastCell = [NSIndexPath indexPathForRow:rowCount - 1 inSection:0];
        if (ipLastCell)
        {
            [self.tableView scrollToRowAtIndexPath:ipLastCell atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    }
}

- (void)updateViewFrameByKeyboardBounds:(CGRect)aKeyboardBounds withAnimationDuration:(NSTimeInterval)aDuration
{
    CGRect keyboardBounds = [self.view convertRect:aKeyboardBounds fromView:nil];
    
    CGFloat theKeyboardHeight = MIN(keyboardBounds.size.width, keyboardBounds.size.height);
    
    if ((theKeyboardHeight == 0.f) && (keyboardBounds.origin.y == 0.f))
    {
        return;
    }
    
    BOOL isLastItemShown = NO;
    
    NSIndexPath *lastVisibleIndexPath = self.tableView.indexPathsForVisibleRows.lastObject;
    if (lastVisibleIndexPath.row == [self.tableView numberOfRowsInSection:lastVisibleIndexPath.section] - 1)
    {
        isLastItemShown = YES;
    }
    
    theKeyboardHeight -= self.customInputAccessoryView.bounds.size.height;
    
    __weak __typeof(self) weakSelf = self;
    
    [self setTextEntryViewBottomMargin:theKeyboardHeight duration:aDuration animationBlock:^(BOOL textInsetChanged)
    {
        if (isLastItemShown || (textInsetChanged && theKeyboardHeight > 0.f))
        {
            [weakSelf scrollToLastConversationItem:NO];
        }
    }];
}

- (void)setTextEntryViewBottomMargin:(CGFloat)aBottomMargin duration:(NSTimeInterval)aDuration animationBlock:(void (^)(BOOL aBottomMarginChanged))animationBlock
{
    if ((fabs(aBottomMargin) < 0.01) && self.customInputAccessoryView.textView.isResettingInputType)
    {
        if (animationBlock)
        {
            animationBlock(NO);
        }
        
        return;
    }
    
    UIEdgeInsets contentInset = self.tableView.contentInset;
    
    CGFloat bottomInset = contentInset.bottom;
    contentInset.bottom = MAX(aBottomMargin + self.customInputAccessoryView.bounds.size.height, kNIGrowingTextViewMinTextViewHeight);
    
    dispatch_block_t executionBlock = ^
    {
        self.tableView.contentInset = contentInset;
        
        if (animationBlock)
        {
            animationBlock(bottomInset != contentInset.bottom);
        }
    };
    
    if (aDuration > 0)
    {
        [UIView animateWithDuration:aDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:executionBlock
                         completion:nil];
    }
    else
    {
        executionBlock();
    }
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    NSTimeInterval theDuration = [(NSNumber*)[notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect theKeyboardBounds = [(NSValue*)[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self updateViewFrameByKeyboardBounds:theKeyboardBounds withAnimationDuration:theDuration];
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    NSTimeInterval theDuration = [(NSNumber*)[notif.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Move text entry view to be placed just below the table view
    [self setTextEntryViewBottomMargin:0.f duration:theDuration animationBlock:nil];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputAccessoryView
{
    if (!self.customInputAccessoryView)
    {
        self.customInputAccessoryView = [[NIConversationInputAccessoryView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, 44.f)];
        self.customInputAccessoryView.textView.delegate = self;
    }
    
    return self.customInputAccessoryView;
}

#pragma mark HPGrowingTextViewDelegate implementation

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    [growingTextView setNeedsLayout];
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    [growingTextView resignFirstResponder];
}

- (void)growingTextView:(NIGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGFloat oldHeight = growingTextView.bounds.size.height;
    
    [self.customInputAccessoryView setHeight:height];
    
    if (!growingTextView.isFirstResponder)
    {
        //No need to setup insets when keyboard is shown. Due to resize of inputAccessoryView,
        //keyboard will send UIKeyboardWillShowNotification/UIKeyboardWillHideNotification etc.
        UIEdgeInsets contentInset = self.tableView.contentInset;
        contentInset.bottom = contentInset.bottom + height - oldHeight;
        self.tableView.contentInset = contentInset;
    }
}

#pragma mark - 
#pragma mark UITableView routine

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 42;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    
    UILabel *label = (UILabel *)[cell viewWithTag:111];
    
    NSString *labelText = @"middle";
    if (indexPath.row == 0)
    {
        labelText = @"first";
    }
    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
    {
        labelText = @"last";
    }
    
    label.text = labelText;
    
    return cell;
}

@end
