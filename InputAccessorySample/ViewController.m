//
//  ViewController.m
//  InputAccessorySample
//
//  Created by Nikita Ivaniushchenko on 7/29/14.
//  Copyright (c) 2014 NGTI. All rights reserved.
//

#import "ViewController.h"
#import "CustomInputAccessoryView.h"

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *customInputAccessoryView;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputAccessoryView
{
    if (!self.customInputAccessoryView)
    {
        self.customInputAccessoryView = [[CustomInputAccessoryView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, 44.f)];
    }
    
    return self.customInputAccessoryView;
}

#pragma mark - 
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

@end
