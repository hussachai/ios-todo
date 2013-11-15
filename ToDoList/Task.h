//
//  Task.h
//  ToDoList
//
//  Created by Hussachai Puripunpinyo on 11/14/13.
//  Copyright (c) 2013 Hussachai Puripunpinyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic) int taskId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic) BOOL priority;
@property (nonatomic) BOOL completed;

@end
