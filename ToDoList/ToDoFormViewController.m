//
//  ToDoFormViewController.m
//  ToDoList
//
//  Created by Hussachai Puripunpinyo on 11/14/13.
//  Copyright (c) 2013 Hussachai Puripunpinyo. All rights reserved.
//

#import "ToDoFormViewController.h"
#import "ToDoTableViewController.h"
#import "WebServiceClient.h"

@interface ToDoFormViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTxt;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTxt;
@property (weak, nonatomic) IBOutlet UIButton *priorityBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@end

@implementation ToDoFormViewController
{
    WebServiceClient *client;
    BOOL priority;
    Task *task;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"Load form view");
    client = [[WebServiceClient alloc] init];
    client.delegate = self;
    priority = NO;
    self.saveBtn.enabled = NO;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissKeyboardTapped:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)saveBtnTapped:(id)sender {
    task = [[Task alloc] init];
    task.title = self.titleTxt.text;
    task.subtitle = self.subtitleTxt.text;
    task.priority = priority;
    task.completed = NO;
    [client createTask:task];
}
- (IBAction)cancelBtnTapped:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)titleTxtEditingChanged:(id)sender {
    NSString *value = [self.titleTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([value isEqualToString:@""]){
        self.saveBtn.enabled = NO;
    }else{
        self.saveBtn.enabled = YES;
    }
}

- (IBAction)priorityBtnTapped:(UIButton*)sender {
    if([sender.titleLabel.text isEqualToString:@"High"]){
        [sender setTitle:@"Normal" forState:UIControlStateNormal];
        priority = NO;
        [sender setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }else{
        [sender setTitle:@"High" forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        priority = YES;
    }
}

- (void) requestCompleted:(NSDictionary *)response {
//    [self.navigationController popToRootViewControllerAnimated:YES];
    ToDoTableViewController *vc = [self.navigationController.viewControllers objectAtIndex:0];
    NSString *result = [response objectForKey:@"result"];
    if([result isEqualToString:@"success"]){
        task.taskId = [[response objectForKey:@"data"] intValue];
        [vc.taskList addObject:task];
        [vc.tableView reloadData];
        [self.navigationController popToViewController:vc animated:YES];
    }
}

@end
