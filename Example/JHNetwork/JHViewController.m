//
//  JHViewController.m
//  JHNetwork
//
//  Created by gelm on 12/06/2017.
//  Copyright (c) 2017 gelm. All rights reserved.
//

#import "JHViewController.h"
#import <JHNetwork/JHNetworking.h>

@interface JHViewController ()

@end

@implementation JHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    JHBaseRequest *request = [[JHBaseRequest alloc]init];
    [request startRequestWithHandleCompletionSuccess:^(__kindof JHBaseRequest *request) {
        
    } failure:^(__kindof JHBaseRequest *request, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
