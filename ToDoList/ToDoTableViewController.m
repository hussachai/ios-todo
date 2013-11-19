//
//  ToDoTableViewController.m
//  ToDoList
//
//  Created by Hussachai Puripunpinyo on 11/14/13.
//  Copyright (c) 2013 Hussachai Puripunpinyo. All rights reserved.
//

#import "ToDoTableViewController.h"
#import "ToDoFormViewController.h"
#import "WebServiceClient.h"

@interface ToDoTableViewController ()

@property (strong, nonatomic) IBOutlet UITableView *todoTableView;

@end

@implementation ToDoTableViewController
{
    WebServiceClient *client;
    dispatch_queue_t deleteQueue;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.taskList = [[NSMutableArray alloc] init];
    /* Sample data */
//    Task *task = [[Task alloc] init];
//    task.title = @"Sample title";
//    task.subtitle = @"Sample subtitle";
//    task.priority = NO;
//    task.completed = NO;
//    [self.taskList addObject:task];
    
    client = [[WebServiceClient alloc] init];
    client.delegate = self;
    [client loadTasks];
    
    deleteQueue = dispatch_queue_create("Delete Queue", NULL);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) requestCompleted:(NSDictionary *)response {
    NSLog(@"Output = %@", response);
    NSString *result = [response objectForKey:@"result"];
    if([result isEqualToString:@"success"]){
        NSString *action = [response objectForKey:@"action"];
        id data = [response objectForKey:@"data"];
        if([action isEqualToString:@"load"]){
            [self populateItemList: data];
        }
    }
}

- (void) populateItemList: (NSArray*) data{
    for(id obj in data){
        if(![obj isKindOfClass:[NSDictionary class]]){
            break;
        }
        NSDictionary *item = (NSDictionary*)obj;
        Task *task = [[Task alloc] init];
        task.taskId = [[item objectForKey:@"id"] intValue];
        task.title = [item objectForKey:@"title"];
        task.subtitle = [item objectForKey:@"subtitle"];
        task.priority = [[item objectForKey:@"priority"] boolValue];
        task.completed = [[item objectForKey:@"status"] boolValue];
        [self.taskList addObject:task];
    }
    [self.todoTableView reloadData];
//    [self.todoTableView reloadRowsAtIndexPaths:
//     [self.todoTableView indexPathsForVisibleRows]
//                               withRowAnimation:UITableViewRowAnimationNone];
}

//To handle shake, we must give the view controller the
//ability to become a first responder
- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) motionEnded: (UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(motion == UIEventSubtypeMotionShake){
        dispatch_async(deleteQueue, ^{
            for(int i=0; i< self.taskList.count; i++){
                Task *task = [self.taskList objectAtIndex:i];
                if(task.completed){
                    NSLog(@"Deleting task at index: %i", i);
                    [client deleteTask:task.taskId];
                    [self.taskList removeObjectAtIndex:i];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.taskList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"todo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Task *task = [self.taskList objectAtIndex: indexPath.row];
    cell.textLabel.text = task.title;
    cell.detailTextLabel.text = task.subtitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task = [self.taskList objectAtIndex: indexPath.row];
    if(task.priority){
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:0.47 blue:0.47 alpha:0.5];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    if(task.completed){
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed: @"checkbox-32.png" ]];
    }else{
//        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed: @"empty-checkbox-32.png" ]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Task *task = [self.taskList objectAtIndex: indexPath.row];
    if(!task.completed){
        task.completed = YES;
        [client setTask:task.taskId status:YES];
    }else{
        task.completed = NO;
        [client setTask:task.taskId status:NO];
    }
    [self.tableView reloadRowsAtIndexPaths:
     [self.tableView indexPathsForVisibleRows]
                               withRowAnimation:UITableViewRowAnimationNone];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Task *task = [self.taskList objectAtIndex:indexPath.row];
        [client deleteTask: task.taskId];
        [self.taskList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    ToDoFormViewController *vc = [segue destinationViewController];
}


@end
