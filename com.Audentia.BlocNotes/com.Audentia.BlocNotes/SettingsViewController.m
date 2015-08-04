//
//  SettingsViewController.m
//  com.Audentia.BlocNotes
//
//  Created by Douglas Hewitt on 7/9/15.
//  Copyright © 2015 Bloc. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressBackButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)iCloudSwitch:(UISwitch *)sender forEvent:(UIEvent *)event {
    if (sender.on == YES) {
        NSLog(@"switch is on");
    } else {
        NSLog(@"switch is off");
    }
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
