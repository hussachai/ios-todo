//
//  WebServiceClient.h
//  ToDoList
//
//  Created by Hussachai Puripunpinyo on 11/14/13.
//  Copyright (c) 2013 Hussachai Puripunpinyo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Task.h"
#import "WebServiceCallHandler.h"

@interface WebServiceClient : NSObject

@property (nonatomic, strong) id<WebServiceCallHandler> delegate;

- (void) loadTasks;

- (void) createTask: (Task*) task;

- (void) deleteTask: (int) taskId;

- (void) setTask: (int) taskId status: (BOOL) completed;

@end
