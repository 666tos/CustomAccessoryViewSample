//
//  CustomInputAccessoryView.m
//  InputAccessorySample
//
//  Copyright (c) 2014. All rights reserved.
//

#import "CustomInputAccessoryView.h"

@interface CustomInputAccessoryView()

@property (nonatomic, strong) NSLayoutConstraint *customInputAccessoryViewHeightConstraint;

@end

BOOL IsRunningOnIOS8()
{
    static BOOL sIsRunningOnIOS8 = NO;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sIsRunningOnIOS8 = ([UIDevice currentDevice].systemVersion.floatValue >= 8.f);
    });
    
    return sIsRunningOnIOS8;
}

@implementation CustomInputAccessoryView

- (UIStepper *)createStepperView
{
    UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 44.f)];
    stepper.minimumValue = 44.0;
    stepper.maximumValue = 200.0;
    stepper.stepValue = 10.0;
    stepper.value = 44.0;
    [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    return stepper;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *stepperView = [self createStepperView];
        stepperView.translatesAutoresizingMaskIntoConstraints = !IsRunningOnIOS8();
        [self addSubview:stepperView];
        
        //iOS7 and below:
        //Never add constraints to inputAccessoryView.
        //UITextEffectsWindow does layout manually and creating constraints in inputAccessoryView's heirarchy means creating autolayout engine.
        //Autolayout engine will be broken after strange transformations with inf/nan frames.
        //
        //iOS8: use autolayout
        
        if (IsRunningOnIOS8())
        {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[stepperView(200)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(stepperView)]];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stepperView(44)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(stepperView)]];
            
            self.customInputAccessoryViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                                         attribute:NSLayoutAttributeHeight
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:nil
                                                                                         attribute:NSLayoutAttributeHeight
                                                                                        multiplier:1.f
                                                                                          constant:44.f];
        }

    }
    return self;
}

- (void)stepperValueChanged:(UIStepper *)stepper
{
    if (IsRunningOnIOS8())
    {
        [self.superview addConstraint:self.customInputAccessoryViewHeightConstraint];
        self.customInputAccessoryViewHeightConstraint.constant = stepper.value;
        [self.superview layoutIfNeeded];
    }
    else
    {
        CGRect frame = self.frame;
        frame.size.height = stepper.value;
        
        self.frame = frame;
    }
}

@end
