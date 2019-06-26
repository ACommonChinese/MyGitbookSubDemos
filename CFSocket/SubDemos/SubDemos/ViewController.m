//
//  ViewController.m
//  SubDemos
//
//  Created by liuweizhen on 2019/5/14.
//  Copyright © 2019 BanMa. All rights reserved.
//

#import "ViewController.h"
#import "Cell_0_ViewController.h"
#import "Cell_1_ViewController.h"
#import "Cell_2_ViewController.h"
#import "Cell_3_ViewController.h"
#import "Cell_4_ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = @[@"0: getLocalIPAddress", @"1: SSID", @"2: NSInputStream | NSOutputStream", @"3: CFSocket", @"4: 使用NSInputSream&outputStream进行Socket通信"];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cellID"];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: { // getLocalIPAddress
            Cell_0_ViewController *controller = [[Cell_0_ViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 1: { // SSID
            Cell_1_ViewController *controller = [[Cell_1_ViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 2: { // NSInputStream | NSOutputStream
            Cell_2_ViewController *controller = [[Cell_2_ViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 4: {
            Cell_4_ViewController *controller = [[Cell_4_ViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        default:
            break;
    }
}

@end
