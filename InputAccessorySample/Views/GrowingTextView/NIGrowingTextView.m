//
//  NIGrowingTextView.m
//
//  Copyright (c) 2014. All rights reserved.
//

#import "NIGrowingTextView.h"

const CGFloat kNIGrowingTextViewMinTextViewHeight = 44.f;

@interface NIGrowingTextViewMaskLayer : CALayer

@property (assign, nonatomic) CGFloat height;

@end

@implementation NIGrowingTextViewMaskLayer

- (id)initWithLayer:(id)aLayer
{
    if ((self = [super initWithLayer:aLayer]))
    {
        // Typically, the method is called to create the Presentation layer.
        // We must copy the parameters to look the same.
        if([aLayer isKindOfClass:self.class])
        {
            NIGrowingTextViewMaskLayer *anOtherLayer = aLayer;
            
            self.height = anOtherLayer.height;
        }
    }
    
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"height"])
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)aContext
{
    UIBezierPath *thePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.f, 0.f, self.bounds.size.width, self.height) cornerRadius:self.cornerRadius];
    CGContextSetFillColorWithColor(aContext, [UIColor blackColor].CGColor);
    
    CGContextAddPath(aContext, thePath.CGPath);
    CGContextFillPath(aContext);
}

@end

@interface NIGrowingTextView()

@property (nonatomic, strong) CALayer *frameLayer;

@property (assign, nonatomic) BOOL usingAutolayout;

@end

@implementation NIGrowingTextView

- (id)initWithAutolayout:(BOOL)usingAutolayout
{
    if (self = [self init])
    {
        self.usingAutolayout = usingAutolayout;
        
        [self commonInitialiser];
    }
    
    return self;
}

- (void)setMaskInsets:(UIEdgeInsets)maskInsets
{
    _maskInsets = maskInsets;
    
    [self updateLayerFrames];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    
    self.layer.mask.cornerRadius = cornerRadius;
    self.frameLayer.cornerRadius = cornerRadius;
}

- (void)updateLayerFrames
{
    [CATransaction begin];
    [CATransaction setValue:@(0.0) forKey:kCATransactionAnimationDuration];
    CGRect layerFrame = UIEdgeInsetsInsetRect(self.bounds, _maskInsets);
    self.layer.mask.frame = layerFrame;
    self.frameLayer.frame = layerFrame;
    [CATransaction commit];
    
    [self.layer.mask display];
}

- (void)commonInitialiser
{
    [super commonInitialiser];
    
    self.animateHeightChange = NO;
    
    NIGrowingTextViewMaskLayer *maskLayer = [NIGrowingTextViewMaskLayer new];
    maskLayer.frame = self.bounds;
    maskLayer.contentsScale = UI_SCREEN_SCALE;
    maskLayer.cornerRadius = self.cornerRadius;
    self.layer.mask = maskLayer;
    
    self.frameLayer = [CALayer new];
    self.frameLayer.contentsScale = UI_SCREEN_SCALE;
    self.frameLayer.cornerRadius = self.cornerRadius;
    self.frameLayer.borderColor = [UIColor colorWithWhite:172.f/255.f alpha:1.f].CGColor;
    self.frameLayer.borderWidth = 1.f/UI_SCREEN_SCALE;
    [self.layer addSublayer:self.frameLayer];
}

- (void)setHeight:(CGFloat)height
{
    CGFloat maskLayerHeight = height - self.maskInsets.top - self.maskInsets.bottom;
    
    NIGrowingTextViewMaskLayer *maskLayer = (NIGrowingTextViewMaskLayer *)self.layer.mask;
    maskLayer.height = maskLayerHeight;
    [maskLayer setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateLayerFrames];
}

@end
