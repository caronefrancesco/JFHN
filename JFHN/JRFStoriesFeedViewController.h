//
//  JRFStoriesFeedViewController.h
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRFEntryCell.h"
#import <NTDCoreDataTableViewController/NTDCoreDataTableViewController.h>

@interface JRFStoriesFeedViewController : NTDCoreDataTableViewController<JRFEntryCellDelegate>

@end
