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
            } else {
                NSLog(@"操作数据库成功");
            }
            [db close];
        }
    }
}

- (IBAction)queryData:(id)sender {
    
    // You must always invoke -[FMResultSet next] before attempting to access the values returned in a query, even if you're only expecting one
    if ([db open]) {
        FMResultSet *resultSet = [db executeQuery:@"select * from userinfo"];
        while ([resultSet next]) {
            //retrieve values for each record
            int userId = [resultSet intForColumn:@"id"];
            NSString *name = [resultSet stringForColumn:@"name"];
            int age = [resultSet intForColumn:@"age"];
            NSString *gender = [resultSet stringForColumn:@"gender"];
            
            NSLog(@"uid:%d name:%@ age:%d gender:%@", userId, name, age, gender);
        }
    }
    
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
            } else {
                NSLog(@"数据 (%@, %d, %@) 插入成功", name, age, (age % 2) == 0 ? @"Male" : @"Female");
            }
        }
    }
    
    [db close];
}

- (IBAction)deleteData:(id)sender {
    
    if ([db open]) {
        if (![db executeUpdate:@"delete from userinfo"]) {
            NSLog(@"操作数据库失败");
        } else {
            NSLog(@"操作数据库成功");
        }
    }
    
    [db close];
}

- (IBAction)updateData:(id)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
