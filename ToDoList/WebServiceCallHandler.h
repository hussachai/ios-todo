//
//  WebServiceCallHandler.h
//  ToDoList
//
//  Created by Hussachai Puripunpinyo on 11/15/13.
//  Copyright (c) 2013 Hussachai Puripunpinyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebServiceCallHandler <NSObject>

- (void) requestCompleted: (NSDictionary*) response;

@end
