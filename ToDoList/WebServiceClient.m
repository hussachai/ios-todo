//
//  WebServiceClient.m
//  ToDoList
//
//  Created by Hussachai Puripunpinyo on 11/14/13.
//  Copyright (c) 2013 Hussachai Puripunpinyo. All rights reserved.
//

#import "WebServiceClient.h"
#import "Task.h"

@interface WebServiceClient()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation WebServiceClient

- (id) init {
    self = [super init];
    self.responseData = [[NSMutableData alloc] init];
    return self;
}

- (void) loadTasks {
    NSLog(@"Called loadTasks");
    [self sendRequest:@"/tasks.php" method:@"GET" requestData: @"action=load"];
}

- (void) createTask:(Task *)task {
    NSLog(@"Called createTask");
    NSString *requestData = [NSString stringWithFormat:@"action=create&title=%@&subtitle=%@&priority=%i",
                             task.title, task.subtitle, task.priority?1:0];
    [self sendRequest:@"/tasks.php" method:@"POST" requestData:requestData];
}

- (void) deleteTask:(int)taskId {
    NSLog(@"Called deleteTask");
    NSString *requestData = [NSString stringWithFormat:@"action=delete&id=%i", taskId];
    [self sendRequest:@"/tasks.php" method:@"POST" requestData:requestData];
}

- (void) setTask:(int)taskId status:(BOOL)completed {
    NSLog(@"Called setTask status");
    NSString *requestData = [NSString stringWithFormat:@"action=updateStatus&id=%i&status=%i",
                             taskId, completed?1:0];
    [self sendRequest:@"/tasks.php" method:@"POST" requestData:requestData];
}

- (void) sendRequest: (NSString*) uri method: (NSString*) method
         requestData: (NSString*) requestData  {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod: method];
    if([method isEqualToString:@"GET"]){
        if(requestData){
            uri = [uri stringByAppendingString:@"?"];
            uri = [uri stringByAppendingString:requestData];
        }
    }else if([method isEqualToString:@"POST"]){
        NSData *data = [requestData dataUsingEncoding:
                        NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *dataLength = [NSString stringWithFormat:@"%d",[data length]];
        [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        [request setHTTPBody: data];
    }
    [request setURL:[NSURL URLWithString:
                     [NSString stringWithFormat:@"http://cs.okstate.edu/~hussach/cs4153%@", uri]]];
    NSLog(@"Sending request to %@", request.URL);
    NSLog(@"With data %@", requestData);
    self.connection = [[NSURLConnection alloc]initWithRequest:request delegate: self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    NSLog(@"Recieving data: %@", data);
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *response = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response (String) = %@", response);
    NSError* error;
    NSDictionary *responseObject = nil;
    
    responseObject = [NSJSONSerialization JSONObjectWithData: self.responseData //1
            options: NSJSONReadingAllowFragments error:&error];
    NSLog(@"Response (JSON) = %@", responseObject);
    /*
    if([[self.loginResult objectForKey:@"result"] isEqual: @"ok"]){
        [self performSegueWithIdentifier:@"Main" sender: Nil];
    }else{
        self.statusLbl.text = [self.loginResult objectForKey:@"message"];
        if(error)
            NSLog(@"Error %@", error);
    }
    */
    [self.delegate requestCompleted: responseObject];
    [self.connection cancel];
    self.connection = nil;
}

@end
