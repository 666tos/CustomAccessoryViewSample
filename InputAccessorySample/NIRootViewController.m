//
//  NIRootViewController.m
//
//  Copyright (c) 2014. All rights reserved.
//

#import "NIRootViewController.h"

@interface NIRootViewController ()

@property (nonatomic, strong) UINavigationController *masterViewController;
@property (nonatomic, strong) UINavigationController *detailedViewController;

@end

@implementation NIRootViewController

+ (NIRootViewController*)instance
{
    return (NIRootViewController*)[UIApplication sharedApplication].delegate.window.rootViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINavigationController *theNavigationController = [self.viewControllers objectAtIndex:0];
    self.masterViewController = theNavigationController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
}

- (void)setDetailedViewController:(UINavigationController *)aDetailedViewController
{
    self.viewControllers = @[self.masterViewController, aDetailedViewController];
}

- (UINavigationController *)detailedViewController
{
    if (self.viewControllers.count > 1)
    {
        return [self.viewControllers objectAtIndex:1];
    }
    
    return nil;
}

- (void)masterItemSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *theNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailNavigationController"];
    self.detailedViewController = theNavigationController;
}

- (BOOL)hasPresendedViewController
{
    if (self.presentedViewController || self.masterViewController.presentedViewController || self.detailedViewController.presentedViewController)
    {
        return YES;
    }
    
    return NO;
}

- (UIView *)inputAccessoryView
{
    if ([self hasPresendedViewController])
    {
        return nil;
    }
    
    //Apple's iMessages approach, thanks to Morgan Winer
    return self.detailedViewController.inputAccessoryView;
}

@end
