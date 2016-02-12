//
//  ImageProcInfoViewController.m
//  ImageProcApp
//
//  Created by YUGWANGYONG on 2/12/16.
//  Copyright © 2016 yong. All rights reserved.
//

#import "ImageProcInfoViewController.h"

@interface ImageProcInfoViewController ()

@end

@implementation ImageProcInfoViewController

-(IBAction)PushBackClick
{   // 모달 화면을 닫는다.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
