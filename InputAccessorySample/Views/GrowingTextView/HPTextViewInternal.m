//
//  HPTextViewInternal.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "HPTextViewInternal.h"

@implementation HPTextViewInternal

static UITextView *sTempTextView = nil;

- (UITextView *)tempTextView
{
    if (!sTempTextView)
    {
        sTempTextView = [UITextView new];
    }
    
    [UIView performWithoutAnimation:^
     {
         sTempTextView.text = nil;
         
         if (sTempTextView.font != self.font)
         {
             sTempTextView.font = self.font;
         }
         
         sTempTextView.frame = self.frame;
         sTempTextView.contentInset = self.contentInset;
         sTempTextView.textAlignment = self.textAlignment;
         
         sTempTextView.text = self.text;
     }];
    
    return sTempTextView;
}

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    if (self = [super initWithFrame:frame textContainer:textContainer])
    {
        // NIPH-2094, NIPH-2095, NIPH-3425: enable context menu for the input field
        self.canDisplayMenu = YES;
    }
    return self;
}

- (CGSize)customContentSize
{
    return [[self tempTextView] sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)];
}

- (void)layoutSubviews
{
    CGPoint contentOffset = self.contentOffset;
    
    [super layoutSubviews];
    
    CGSize customContentSize = self.customContentSize;
    self.contentSize = customContentSize;
    self.contentOffset = contentOffset;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    CGSize customContentSize = self.customContentSize;
    
    if (!RUNNING_ON_IOS8)
    {
        // Fix "undersizing" bug
        
        UIView *subview = [self.subviews firstObject];
        
        CGRect subviewFrame = subview.frame;
        if (subviewFrame.size.height < customContentSize.height)
        {
            subviewFrame.size.height = customContentSize.height;
            subview.frame = subviewFrame;
        }
    }
    
    // Fix "overscrolling" bug
    if (contentOffset.y > customContentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging)
    {
        contentOffset = CGPointMake(contentOffset.x, customContentSize.height - self.frame.size.height);
    }
    
    [super setContentOffset:contentOffset];
}

- (void)setContentSize:(CGSize)contentSize
{
    CGPoint contentOffset = self.contentOffset;
    [super setContentSize:contentSize];
    
    self.contentOffset = contentOffset;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.displayPlaceHolder && self.placeholder && self.placeholderColor)
    {
        if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.alignment = self.textAlignment;
            [self.placeholder drawInRect:CGRectMake(5, 8 + self.contentInset.top, self.frame.size.width-self.contentInset.left, self.frame.size.height- self.contentInset.top) withAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:self.placeholderColor, NSParagraphStyleAttributeName:paragraphStyle}];
        }
        else
        {
            [self.placeholderColor set];
            
            if (nil != self.font)
            {
                NSDictionary *attributes = @{NSFontAttributeName: self.font};
                [self.placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, self.frame.size.height - 16.0f) withAttributes:attributes];
            }
        }
    }
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    
    [self setNeedsDisplay];
}

- (UIResponder *)nextResponder
{
    return (_overrideNextResponder != nil) ? _overrideNextResponder : [super nextResponder];
}

- (void)paste:(id)sender
{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    UIImage *pastedImage = pasteBoard.image;
    
    if (pastedImage)
    {
        if (self.pasteImageDelegate)
        {
            [self.pasteImageDelegate growingTextView:self didPasteImage:pastedImage];
        }
    }
    else
    {
        [super paste:sender];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (self.canDisplayMenu && !self.overrideNextResponder)
    {
        return [super canPerformAction:action withSender:sender];
    }
    return NO;
}

@end
