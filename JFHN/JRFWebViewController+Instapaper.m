//
//  JRFWebViewController+Instapaper.m
//  JFHN
//
//  Created by Jack Flintermann on 10/22/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFWebViewController+Instapaper.h"
#import "JRFInstapaperViewController.h"

@implementation JRFWebViewController (Instapaper)

- (void) toggleInstapaper {
    JRFInstapaperViewController *instapaperController = [[JRFInstapaperViewController alloc] initWithUrlRequest:self.request];
    instapaperController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    instapaperController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissInstapaper:)];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:instapaperController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void) dismissInstapaper:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
