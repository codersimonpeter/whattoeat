//
//  ViewController.m
//  whatToEat
//
//  Created by lx刘逍 on 16/7/25.
//  Copyright © 2016年 IBokanWisdom. All rights reserved.
//

#import "ViewController.h"

#define MUSERNAME @"笑笑"

@interface ViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UITextView *historyView;
@property (strong, nonatomic) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self getData];

}
- (void)creatUI{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:(UIBarButtonItemStylePlain) target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.backgroundImage.userInteractionEnabled = YES;
    self.resultLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(decideToEat)];
    [self.resultLabel addGestureRecognizer:tap];
    
    self.historyView.delegate = self;
    self.historyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.historyView setEditable:NO];
    self.historyView.backgroundColor = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight|UISwipeGestureRecognizerDirectionLeft;
    [self.historyView addGestureRecognizer:swipe];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:(UIBarButtonItemStyleDone) target:self action:@selector(rightAction)];
    self.navigationItem.rightBarButtonItem = right;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLabel.textColor = [UIColor colorWithRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1];
    titleLabel.text = [NSString stringWithFormat:@"%@好，笑笑",[self getTheTimeBucket]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
}
- (void)rightAction{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"moreView"];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 提交按钮触发的方法
- (void)decideToEat{
    if (self.items.count == 0) {
        self.resultLabel.text = @"并没有菜可点,快去添加啦~~";
        return;
    }
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doSomeThing:) userInfo:nil repeats:YES];
}
#pragma mark - 获取userDefaults里面的食品
- (NSArray *)getItems{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"items"];
}

#pragma mark - 获取和保存历史记录
- (NSString *)getHistory{
    NSString *history = @"";
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    history = [userDef objectForKey:@"history"];
    return history;
}
- (BOOL)saveHistory:(NSString *)history{
    BOOL state = NO;
    NSString *str = history;
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:str forKey:@"history"];
    if ([userDef synchronize]) {
        state = YES;
    }
    return state;
}
#pragma mark - 清理历史记录
- (BOOL)clearHistory{
    BOOL state = NO;
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:@"" forKey:@"history"];
    if ([userDef synchronize]) {
        state = YES;
    }
    return state;
}
#pragma mark - 刷新数据
- (void)getData{
    self.items = [NSMutableArray arrayWithArray:[self getItems]];
    self.historyView.text = [self getHistory];
}

#pragma mark - 获取当前时间字符串
- (NSString *)getCurrentDateStr{
    NSDate *date = [NSDate date];
    NSDateFormatter *fommater = [[NSDateFormatter alloc] init];
    [fommater setDateFormat:@"yyyy/MM/dd hh:mm"];
    NSString *dateStr = [fommater stringFromDate:date];
    return dateStr;
}
#pragma mark - 轻扫手势
- (void)swipeAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"清理历史记录？" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"清理" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        self.historyView.text = @"";
        [self clearHistory];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"暂不" style:(UIAlertActionStyleCancel) handler:nil];
    [alert addAction:cancel];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 自定义时间
- (NSDate *)getCustomDateWithHour:(NSInteger)hour
{
    //获取当前时间
    NSDate * destinationDateNow = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    currentComps = [currentCalendar components:unitFlags fromDate:destinationDateNow];
    
    //设置当前的时间点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

#pragma mark - 获取时间段
- (NSString *)getTheTimeBucket
{
    NSDate * currentDate = [NSDate date];
    if ([currentDate compare:[self getCustomDateWithHour:5]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:9]] == NSOrderedAscending)
    {
        return @"早上";
    }
    else if ([currentDate compare:[self getCustomDateWithHour:9]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:11]] == NSOrderedAscending)
    {
        return @"上午";
    }
    else if ([currentDate compare:[self getCustomDateWithHour:11]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:13]] == NSOrderedAscending)
    {
        return @"中午";
    }
    else if ([currentDate compare:[self getCustomDateWithHour:13]] == NSOrderedDescending && [currentDate compare:[self getCustomDateWithHour:18]] == NSOrderedAscending)
    {
        return @"下午";
    }
    else
    {
        return @"晚上";
    }
}
#pragma mark - 计时器方法
- (void)doSomeThing:(NSTimer *)timer
{
    static int count = 0;
    count ++;
    self.resultLabel.userInteractionEnabled = NO;
    int index = arc4random()%self.items.count;
    NSLog(@"index = %d,count = %ld",index,self.items.count);
    self.resultLabel.text = self.items[index];
    if (count >= self.items.count) {
        [timer invalidate];
        timer = nil;
        NSString *text = self.historyView.text;
        NSString *textNew = [NSString stringWithFormat:@"%@%@%@ 决定去吃 %@\n",text,[self getCurrentDateStr],[self getTheTimeBucket],self.items[index]];
        self.historyView.text = textNew;
        [self saveHistory:textNew];
        count = 0;
        self.resultLabel.userInteractionEnabled = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
