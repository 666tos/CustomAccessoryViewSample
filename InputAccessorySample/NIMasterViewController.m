//
//  NIMasterViewController.m
//
//  Copyright (c) 2014. All rights reserved.
//

#import "NIMasterViewController.h"
#import "NIRootViewController.h"

@interface NIMasterViewController ()

@end

@implementation NIMasterViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (RUNNING_ON_IPAD)
    {
        [[NIRootViewController instance] masterItemSelectedAtIndexPath:indexPath];
    }
    else
    {
        [self performSegueWithIdentifier:@"detailSegue" sender:self];
    }
}

@end
