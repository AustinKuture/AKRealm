//
//  ViewController.m
//  AKRealmCoreData
//
//  Created by 李亚坤 on 2017/8/23.
//  Copyright © 2017年 Kuture. All rights reserved.
//

#import "ViewController.h"
#import "RLMRealmConfiguration.h"
#import "YFPerson.h"

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

//结果数组
@property (nonatomic,strong) RLMResults <YFPerson *> *resultsArray;

//数据变化通知
@property (nonatomic,strong) RLMNotificationToken *notificationToken;

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //视图初始化
    [self setupMainViewInitSetting];
    //监听
    [self notificationToken];
}

#pragma mark ***视图初始化***
- (void)setupMainViewInitSetting{
    
    //创建多个联系人
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"创建多个联系人" style:UIBarButtonItemStyleDone target:self action:@selector(addManyPersons)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //创建个人联系人
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addUniquePerson)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    //初始化tableview
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Width, Height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

#pragma mark ***初始化数据源***
- (RLMResults<YFPerson *> *)resultsArray {
    
    if (!_resultsArray) {
        
        /* 按照年龄来排序 */
        _resultsArray = [[YFPerson allObjects]sortedResultsUsingKeyPath:@"age" ascending:YES];
    }
    
    return _resultsArray;
    
}

#pragma mark ***监听数据库中的数据变化***
- (RLMNotificationToken *)notificationToken {
    
    __weak typeof(self)weakSelf = self;
    if (!_notificationToken) {
        
        _notificationToken = [self.resultsArray addNotificationBlock:^(RLMResults<YFPerson *> * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"打开 realm 数据库失败,%@",error);
                
                return;
                
            } /* 如果数据库的变化为空, 则仅仅刷新 tableView */
            
            if (!change) {
                
                [weakSelf.tableView reloadData];
                
            } /* 如果变化不为空,则更新 tableView的数据源, 并刷新 tableView */ /* tableView开始更新 */
            
            [weakSelf.tableView beginUpdates];
            
            /* tableView 删除数据 */
            [weakSelf.tableView deleteRowsAtIndexPaths:[change deletionsInSection:0] withRowAnimation:UITableViewRowAnimationTop];
            // 因为只有第0组,所以所有的更新都在第0组 /* tableView 添加数据 */
            [weakSelf.tableView insertRowsAtIndexPaths:[change insertionsInSection:0] withRowAnimation:UITableViewRowAnimationTop];
            /* tableView 刷新数据 */
            [weakSelf.tableView reloadRowsAtIndexPaths:[change modificationsInSection:0] withRowAnimation:UITableViewRowAnimationTop];
            /* tableView 结束更新 */
            [weakSelf.tableView endUpdates];
        }];
    }
    /* 在这里打印一下沙盒的地址, 然后可以看到待会儿可以看到可视化的数据库 */
    NSLog(@"%@",NSHomeDirectory());
    
    return _notificationToken;
}

#pragma mark ***添加多个数据***
- (void)addManyPersons {
    /* 添加多个数据是耗时操作, 我们重新开启一个线程来操作 */
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (NSUInteger i = 0; i < 5; i++) {
            /* 循环内部的逻辑就跟添加单个数据一样了 */
            [[RLMRealm defaultRealm]beginWriteTransaction];
            
            [YFPerson createInRealm:[RLMRealm defaultRealm] withValue:@[[NSString stringWithFormat:@"Austin:%ld",i + arc4random_uniform(10000)],@((long)(arc4random_uniform(100)))]];
            [[RLMRealm defaultRealm]commitWriteTransaction];
        }
    });
    
    NSLog(@"===============ResultArray:%@",_resultsArray);
}

#pragma mark ***添加单个数据***
- (void)addUniquePerson{
    /* 这个类是专门开始创建数据库的 */
    /* 开始写入业务 */
    [[RLMRealm defaultRealm]beginWriteTransaction];
    
    /* 这个方法是创造一个Realm实例对象,并存储到 Realm 数据库中 */
    [YFPerson createInRealm:[RLMRealm defaultRealm] withValue:@[@"Kuture",@(323)]];
    
    /* 提交写入业务 */
    [[RLMRealm defaultRealm]commitWriteTransaction];
}

#pragma mark ***返回行数***
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _resultsArray.count;
}

#pragma mark ***Cell中的内容***
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell){
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = _resultsArray[indexPath.row].name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Age:%ld",_resultsArray[indexPath.row].age];
    
    return cell;
}

#pragma mark ***侧滑打开的方法 *** 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* 删除数据,其实方法和添加数据是差不多的 */
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[RLMRealm defaultRealm]beginWriteTransaction];
        [[RLMRealm defaultRealm]deleteObject:self.resultsArray[indexPath.row]];
        [[RLMRealm defaultRealm]commitWriteTransaction];
    }
}




/*
- (void)creatDataBaseWithName{
    
    NSString *databaseName = @"iOS_Realm_Data_00";
    
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [docPath objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:databaseName];
    
    NSLog(@"数据库目录 = %@",filePath);
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.fileURL = [NSURL URLWithString:filePath];
//    config.objectClasses = @[MyClass.class, MyOtherClass.class];
    config.readOnly = NO; int currentVersion = 1.0;
    config.schemaVersion = currentVersion;
    
    __weak typeof(config) weakConfig = config;
    config.migrationBlock = ^(RLMMigration *migration , uint64_t oldSchemaVersion) {
        
        // 这里是设置数据迁移的block
        
        if (oldSchemaVersion < currentVersion) {
        
        };
    
    [RLMRealmConfiguration setDefaultConfiguration:weakConfig];
    
    };
}
 */


    


























@end
