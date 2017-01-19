//
//  MoreViewController.m
//  whatToEat
//
//  Created by lx刘逍 on 16/7/25.
//  Copyright © 2016年 IBokanWisdom. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *items;

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self creatUI];
    [self getData];
    // Do any additional setup after loading the view.
}
- (void)getData{
    if (!self.items) {
        self.items = [NSMutableArray array];
    }
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    self.items = [NSMutableArray arrayWithArray:[userDef objectForKey:@"items"]];
}
- (void)creatUI{
    self.tableView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:(UIBarButtonItemStylePlain) target:self action:@selector(addItemToLocal)];
    self.navigationItem.rightBarButtonItem = right;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"count = %ld",self.items.count + 1);
    return self.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = self.items[indexPath.row];
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"delete %ld 行",indexPath.row);
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    //fjfjfhjf
        NSString *food = cell.textLabel.text;
        if ([self.items containsObject:food]) {
            [self.items removeObject:food];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            [self deleteFromItems:food];
        }
        [tableView reloadData];

    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        NSLog(@"insert");
    }
}
- (BOOL)deleteFromItems:(NSString *)food{
    BOOL state = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *foods = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"items"]];
    if ([foods containsObject:food]) {
        [foods removeObject:food];
        [userDefaults setObject:foods forKey:@"items"];
        if([userDefaults synchronize])
        {
            state = YES;
        }
    }
    return state;
}
#pragma mark - 指定表视图可编辑

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
#pragma mark - 添加食品到userDefalts
- (BOOL)addToItems:(NSString *)food{
    //数据持久化
    BOOL state = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *foods = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"items"]];
    if (![foods containsObject:food]) {
        [foods addObject:food];
        [userDefaults setObject:foods forKey:@"items"];
        if([userDefaults synchronize])
        {
            state = YES;
        }
    }
    return state;
}
- (void)addItemToLocal{
    NSLog(@"add");
    __block UITextField *TF = nil;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"输入要添加的菜品" preferredStyle:(UIAlertControllerStyleAlert)];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        TF = textField;
    }];
    UIAlertAction *OK = [UIAlertAction actionWithTitle:@"添加" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"text = %@",TF.text);
        [self addToItems:TF.text];
        [self printLast:@"添加到user后"];
        if (![self.items containsObject:TF.text]) {
            [self.items addObject:TF.text];
            [self printLast:@"添加到items后"];
        }
        [self printLast:@"刷新前"];
        [self.tableView reloadData];
        [self printLast:@"刷新后"];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alertController addAction:OK];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
    

}
- (void)printLast:(NSString *)str{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSArray *foods = [user objectForKey:@"items"];
    NSLog(@"%@偏好 last = %@",str,[foods lastObject]);
    NSLog(@"%@添加 last = %@",str,[self.items lastObject]);
}
@end
