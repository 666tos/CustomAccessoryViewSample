//
//  NIButton.m
//
//  Copyright (c) 2014. All rights reserved.
//

#import "NIButton.h"

@interface NIButton()

@property (nonatomic, strong) NSMutableDictionary *originalTitleColors;

@end

@implementation NIButton

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    
    return CGSizeMake(size.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      size.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize ownSize = [super sizeThatFits:size];
    
    return CGSizeMake(ownSize.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      ownSize.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    if (self.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed)
    {
        //Inactive
        UIColor *disabledColor = [self.originalTitleColors objectForKey:@(UIControlStateDisabled)];
        
        if (disabledColor)
        {
            [self updateTitleTextColor:disabledColor forState:UIControlStateNormal];
        }
    }
    else
    {
        UIColor *normalColor = [self.originalTitleColors objectForKey:@(UIControlStateNormal)];
        
        if (normalColor)
        {
            [self updateTitleTextColor:normalColor forState:UIControlStateNormal];
        }
    }
}

- (NSMutableDictionary *)originalTitleColors
{
    if (!_originalTitleColors)
    {
        _originalTitleColors = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    
    return _originalTitleColors;
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    if (color)
    {
        [self.originalTitleColors setObject:color forKey:@(state)];
    }
    else
    {
        [self.originalTitleColors removeObjectForKey:@(state)];
    }
    
    [self updateTitleTextColor:color forState:state];
}

- (void)updateTitleTextColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleColor:color forState:state];
}

@end
