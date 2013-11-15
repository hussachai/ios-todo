//
//  ToDoTableViewController.h
//  ToDoList
//
//  Created by Hussachai Puripunpinyo on 11/14/13.
//  Copyright (c) 2013 Hussachai Puripunpinyo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WebServiceCallHandler.h"

@interface ToDoTableViewController : UITableViewController <WebServiceCallHandler>

@property (nonatomic, strong) NSMutableArray *taskList;

@end
