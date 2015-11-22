//
//  ViewController.m
//  CAFmdbDemo
//
//  Created by Charles on 15/11/21.
//  Copyright © 2015年 Charles. All rights reserved.
//

#import "ViewController.h"
#import <FMDB/FMDatabase.h>

@interface ViewController () {
    
    FMDatabase *db;
}

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextView *resultsTextView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Create table
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"userinfo.sqlite"];
    db = [FMDatabase databaseWithPath:dbPath];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPath]) {
        // Open
        if (![db open]) {
            NSLog(@"打开数据库失败");
        } else {
            NSLog(@"打开数据库成功");
            
            NSString *sql = @"create table userinfo (id integer primary key autoincrement not NULL, 'name' text, 'age' integer, 'gender' text);";
            
            if (![db executeStatements:sql]) {
                NSLog(@"操作数据库失败");
                [self failureHandler:@"操作数据库失败"];
            } else {
                NSLog(@"操作数据库成功");
                [self successHandler:@"操作数据库成功"];
            }
            [db close];
        }
    }
}

#pragma mark - database operation

- (IBAction)queryData:(id)sender {
    
    self.resultsTextView.text = @"";
    
    // You must always invoke -[FMResultSet next] before attempting to access the values returned in a query, even if you're only expecting one
    NSMutableString *results = [[NSMutableString alloc] init];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQuery:@"select * from userinfo"];
        while ([resultSet next]) {
            //retrieve values for each record
            int userId = [resultSet intForColumn:@"id"];
            NSString *name = [resultSet stringForColumn:@"name"];
            int age = [resultSet intForColumn:@"age"];
            NSString *gender = [resultSet stringForColumn:@"gender"];
            
            [results appendString:[NSString stringWithFormat:@"uid:%d name:%@ age:%d gender:%@\n", userId, name, age, gender]];
            
            NSLog(@"uid:%d name:%@ age:%d gender:%@", userId, name, age, gender);
            [self successHandler:@"查询数据库成功"];
        }
    }
    
    self.resultsTextView.text = results;
    
    [db close];
}

- (IBAction)insertData:(id)sender {
    
    NSArray *names = @[@"Amy", @"Bob", @"Candy", @"Dove", @"Erin",
                       @"Franky", @"God", @"Holy", @"Ivy", @"Jack",
                       @"Kelly", @"Lily", @"Moon", @"Nina", @"Oliver",
                       @"Peter", @"Queen", @"Rose", @"Steve", @"Tom",
                       @"Union", @"Victor", @"Wall", @"Xanthe", @"Yoyo",
                       @"Zack"];
    if ([db open]) {
        for (NSString *name in names) {
            int age = arc4random() % 20 + 20;
            NSString *gender = (age % 2) == 0 ? @"Male" : @"Female";
            NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", @(age), @"age", gender, @"gender", nil];
            [db executeUpdate:@"INSERT INTO userinfo (name, age, gender) VALUES (:name, :age, :gender)" withParameterDictionary:argsDict];
            if (![db executeUpdate:@"INSERT INTO userinfo (name, age, gender) VALUES (:name, :age, :gender)" withParameterDictionary:argsDict]) {
                NSLog(@"操作数据库错误");
                [self failureHandler:@"插入数据库失败"];
            } else {
                NSLog(@"数据 (%@, %d, %@) 插入成功", name, age, (age % 2) == 0 ? @"Male" : @"Female");
                [self successHandler:@"插入数据库成功"];
            }
        }
    }
    
    [db close];
}

- (IBAction)deleteData:(id)sender {
    
    if ([db open]) {
        if (![db executeUpdate:@"delete from userinfo"]) {
            NSLog(@"操作数据库失败");
            [self failureHandler:@"删除数据库失败"];
        } else {
            NSLog(@"操作数据库成功");
            [self successHandler:@"删除数据库成功"];
        }
    }
    
    [db close];
}

- (IBAction)updateData:(id)sender {
    
}

#pragma mark - Show Message

- (void)successHandler:(NSString *)message {
    
    [self showMessage:message];
}

- (void)failureHandler:(NSString *)message {

    [self showMessage:message];
}

- (void)showMessage:(NSString *)message {

    self.messageLabel.text = message;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
