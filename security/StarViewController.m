//
//  StarViewController.m
//  security
//
//  Created by 辉仔 on 2016/11/26.
//  Copyright © 2016年 辉仔. All rights reserved.
//

#import "StarViewController.h"
#import "ViewController.h"

@interface StarViewController ()
@property (weak, nonatomic) IBOutlet UITextField *ip;
@property (weak, nonatomic) IBOutlet UITextField *port;

@end

@implementation StarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ViewController* vc=segue.destinationViewController;
    vc.ip=self.ip.text;
    vc.port=self.port.text;
}


@end
