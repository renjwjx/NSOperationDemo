//
//  ViewController.m
//  NSOperationDemo
//
//  Created by renjinwei on 2020/12/31.
//  Copyright © 2020 renjinwei. All rights reserved.
//

#import "ViewController.h"
#import "HFOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [self operationWithoutQueue];
//    [self invocationOperationWithQueue];
//    [self blockOperationWithQueue];
//    [self blockOperationWithQueue2];
//    [self customOperation];
//    [self operationSerial];
//    [self operationDependency];

}
//添加依赖, 避免依赖循环， 依赖循环不会crash。
- (void)operationDependency
{
    NSBlockOperation* block1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block1 -- %@", [NSThread currentThread]);
    }];
    NSBlockOperation* block2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block2 -- %@", [NSThread currentThread]);
    }];
    NSBlockOperation* block3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block3 -- %@", [NSThread currentThread]);
    }];
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];

    [block1 addDependency:block2];
    [block1 addDependency:block3];
    [block2 addDependency:block3];
    //依赖必须在addOperation前面， addOperation就直接开始执行
    [queue addOperation:block1];
    [queue addOperation:block2];
    [queue addOperation:block3];
    

}


//控制最大并发任务数， 线程串行执行
- (void)operationSerial
{
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    [queue addOperationWithBlock:^{
        NSLog(@"block1 -- %@", [NSThread currentThread]);
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"block2 -- %@", [NSThread currentThread]);
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"block3 -- %@", [NSThread currentThread]);
    }];
    
    [queue addOperationWithBlock:^{
        NSLog(@"block4 -- %@", [NSThread currentThread]);
    }];
    
}
//自定义Operation
- (void)customOperation
{
    HFOperation* op1 = [[HFOperation alloc] init];
    HFOperation* op2 = [[HFOperation alloc] init];
    
//    NSOperationQueue* queue = [NSOperationQueue mainQueue];
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        //如果是waitUntilFinished YES, 那么必须不能是主队列[NSOperationQueue mainQueue]， 否则死锁
    [queue addOperations:@[op1, op2] waitUntilFinished:YES];
    
    NSLog(@"customOperation end");
}

- (void)blockOperationWithQueue2
{
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];

    [queue addOperationWithBlock:^{
        NSLog(@"block1 -- %@", [NSThread currentThread]);
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"block2 -- %@", [NSThread currentThread]);
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"block2 -- %@", [NSThread currentThread]);
    }];
    
}

- (void)blockOperationWithQueue
{
    NSBlockOperation* block1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block1 -- %@", [NSThread currentThread]);
    }];
    NSBlockOperation* block2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block2 -- %@", [NSThread currentThread]);
    }];
    NSBlockOperation* block3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block3 -- %@", [NSThread currentThread]);
    }];
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];

    [queue addOperation:block1];
    [queue addOperation:block2];
    [queue addOperation:block3];
    
    [queue addOperationWithBlock:^{
                NSLog(@"add operation -- %@", [NSThread currentThread]);
    }];
    
}
//不用Queue， 必须要自己start
- (void)operationWithoutQueue
{
    NSBlockOperation* op= [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operation block");
    }];
    op.completionBlock = ^{
        NSLog(@"op complete");
    };
    [op start];
}

- (void)invocationOperationWithQueue
{
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(download1) object:nil];

    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(download1) object:nil];
    
    NSInvocationOperation *op3 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(download1) object:nil];
    
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}

- (void)download1
{
    NSLog(@"downalod -- %@", [NSThread currentThread]);
}


@end
