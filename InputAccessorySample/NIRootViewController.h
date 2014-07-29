//
//  NIRootViewController.h
//
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIRootViewController : UISplitViewController

+ (NIRootViewController*)instance;

- (void)masterItemSelectedAtIndexPath:(NSIndexPath *)indexPath;

@end
