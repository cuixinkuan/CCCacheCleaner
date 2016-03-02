//
//  ViewController.m
//  CCCacheCleaner
//  一键清理缓存
//  Created by admin on 16/3/2.
//  Copyright © 2016年 CuiXinKuan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate
,UIAlertViewDelegate>
{
    UITableView *  _tableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"清理缓存";
    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    self.navigationController.navigationBar.barTintColor = [UIColor purpleColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
}

#pragma mark - UITableViewDataSource - 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}


#pragma mark - UITableViewDelegate -
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell1"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    if (indexPath.row == 0 ) {
        cell.textLabel.text = @"清理缓存";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1fM",[self obtainForfilePath]];
    }
    return cell;
}

// 获取缓存大小
- (CGFloat)obtainForfilePath {
    NSString * cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [self folderSizeAtpath:cachePath];
}

// 遍历文件夹返回文件大小（M）
- (float)folderSizeAtpath:(NSString *)folderPath {
    NSFileManager * manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    NSEnumerator * childfilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString * fileName;
    long long folderSize = 0;
    while ((fileName = [childfilesEnumerator nextObject]) != nil) {
        NSString * fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtpath:fileAbsolutePath];
    }
    return folderSize / (1024.0 * 1024.0);
}

// 计算返回单个文件大小
- (long long)fileSizeAtpath:(NSString *)filepath {
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filepath]) {
        return [[manager attributesOfItemAtPath:filepath error:nil] fileSize];
    }
    return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 ) {
        // 清理缓存
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否清理缓存?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 1011;
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate - 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 1011) {
        [self cleanrFilecache];
    }
}

// 清理缓存
- (void)cleanrFilecache {
    NSString * cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSArray * files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
    
    for (NSString * path  in files) {
        NSError * error = nil;
        NSString * absolutepath = [cachePath stringByAppendingPathComponent:path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:absolutepath]) {
            [[NSFileManager defaultManager] removeItemAtPath:absolutepath error:&error];
        }
    }
    
    [self performSelectorOnMainThread:@selector(cleanrCacheSuccess) withObject:nil waitUntilDone:YES];
}


// 清除成功
- (void)cleanrCacheSuccess {
// 刷新缓存显示
    NSIndexPath * index = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
