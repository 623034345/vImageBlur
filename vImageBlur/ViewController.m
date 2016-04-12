//
//  ViewController.m
//  vImageBlur
//
//  Created by Kael on 16/4/12.
//  Copyright © 2016年 Kael. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray *array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *d1=@{@"title":@"Blur",@"class":@"BlurViewController"};
    NSDictionary *d2=@{@"title":@"Test1",@"class":@"TestDemoViewController",@"sel":@"demo1"};
    NSDictionary *d3=@{@"title":@"Test2",@"class":@"TestDemoViewController",@"sel":@"demo2"};
    _array=@[d1,d2,d3];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict=self.array[indexPath.row];
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text=dict[@"title"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     NSDictionary *dict=self.array[indexPath.row];
    
    Class class=NSClassFromString(dict[@"class"]);
    SEL sel=NSSelectorFromString(dict[@"sel"]);
    if (class) {
        UIViewController *vc=[[class alloc]init];
        if (sel) {
            [vc performSelector:sel];
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}


@end
