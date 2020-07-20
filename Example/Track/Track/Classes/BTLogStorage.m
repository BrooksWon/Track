//
//  BTLogStorage.m
//  Track_Example
//
//  Created by Brooks on 2020/7/20.
//  Copyright © 2020 BrooksWon. All rights reserved.
//

#import "BTLogStorage.h"

#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<sys/mman.h>

#define kLogFolderName @"BTLogStorage"

//如果不需要test case，以下头文件无需导入
#import <mach/mach_time.h>
#import <UIKit/UIKit.h>
#import "ViewTrackModel.h"

//时间测量方法
CGFloat LogTimeBlock (void (^block)(void)) {
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;
    
    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;
    
    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
}

// 映射文件到内存
int MapFile( int fd , void ** outDataPtr, size_t mapSize , struct stat * stat);
// 处理文件
int readProcessFile( char * inPathName , NSData ** outData);
// 处理文件
int writeProcessFile( char * inPathName , char * string);

int readProcessFile( char * inPathName , NSData ** outData)
{
    void * dataPtr;       //
    struct stat statInfo; // 文件状态
    int fd;               // 文件
    int outError;         // 错误信息
    
    // 打开文件
    fd = open( inPathName, O_RDWR | O_CREAT, 0 );
    
    if( fd < 0 )
    {
        outError = errno;
        return 1;
    }
    
    // 获取文件状态
    int fsta = fstat( fd, &statInfo );
    if( fsta != 0 )
    {
        outError = errno;
        return 1;
    }
    
    // 需要映射的文件大小
    size_t mapsize = statInfo.st_size;
    
    if (mapsize == 0) {
        return 1;
    }
    
    // 文件映射到内存
    int result = MapFile(fd, &dataPtr, mapsize ,&statInfo);
    
    // 文件映射成功
    if( result == 0 )
    {
        //每次读取1KB，准备1KB的buffer
        int i = 0;
        int k1kb = 1024;
        uint8_t bytes[k1kb]; //1kb大小的buffer
        NSMutableData *data = [NSMutableData dataWithCapacity:0];
        while (i <= statInfo.st_size/k1kb) {
            size_t offSet = (k1kb * i);
            //每次读取1kb内容到buffer中
            memcpy(bytes, dataPtr + offSet, k1kb);
            i++;
            
            //将每次读取的数据append到dataz尾部
            [data appendBytes:bytes length:k1kb];
        }
        //        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        i = i>0 ? i-1:i;
        if (statInfo.st_size > i*statInfo.st_size/k1kb) {
            //读取剩余不足1kb的内容到buffer中
            int dataLength = statInfo.st_size - (k1kb * i);
            memcpy(bytes, dataPtr + (k1kb * i), dataLength);
            //读取的数据append到dataz尾部
            [data appendBytes:bytes length:dataLength];
        }
        //        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        *outData = data.copy;
    }
    else
    {
        // 映射失败
        NSLog(@"映射失败");
    }
    close(fd);
    return 0;
}

int writeProcessFile( char * inPathName , char * string)
{
    size_t originLength;  // 原数据字节数
    size_t dataLength;    // 数据字节数
    void * dataPtr;       //
    void * start;         //
    struct stat statInfo; // 文件状态
    int fd;               // 文件
    int outError;         // 错误信息
    
    // 打开文件
    fd = open( inPathName, O_RDWR | O_CREAT, 0 );
    
    if( fd < 0 )
    {
        outError = errno;
        return 1;
    }
    
    // 获取文件状态
    int fsta = fstat( fd, &statInfo );
    if( fsta != 0 )
    {
        outError = errno;
        return 1;
    }
    
    // 需要映射的文件大小
    dataLength = strlen(string);
    originLength = statInfo.st_size;
    size_t mapsize = originLength + dataLength;
    
    if (mapsize == 0) {
        return 1;
    }
    
    // 文件映射到内存
    int result = MapFile(fd, &dataPtr, mapsize ,&statInfo);
    
    // 文件映射成功
    if( result == 0 )
    {
        start = dataPtr;
        dataPtr = dataPtr + statInfo.st_size;
        
        memcpy(dataPtr, string, dataLength);
        
        //        fsync(fd);
        // 关闭映射，将修改同步到磁盘上，可能会出现延迟
        //        munmap(start, mapsize);
        
        // Now close the file. The kernel doesn’t use our file descriptor.
        //        close( fd );
    }
    else
    {
        // 映射失败
        NSLog(@"映射失败");
    }
    close(fd);
    return 0;
}


/// 映射文件到内存
/// @param fd 代表文件
/// @param outDataPtr 映射出的文件内容
/// @param mapSize 映射的size
/// @param stat 状态
/// return  an errno value on error (see sys/errno.h) or zero for success
int MapFile( int fd, void ** outDataPtr, size_t mapSize , struct stat * stat)
{
    int outError;         // 错误信息
    struct stat statInfo; // 文件状态
    
    statInfo = * stat;
    
    // Return safe values on error.
    outError = 0;
    *outDataPtr = NULL;
    
    *outDataPtr = mmap(NULL,
                       mapSize,
                       PROT_READ|PROT_WRITE,
                       MAP_FILE|MAP_SHARED,
                       fd,
                       0);
    
    // * outDataPtr 文本内容
    
    //        NSLog(@"映射出的文本内容：%s", * outDataPtr);
    if( *outDataPtr == MAP_FAILED )
    {
        outError = errno;
    }
    else
    {
        // 调整文件的大小
        ftruncate(fd, mapSize);
        fsync(fd);//刷新文件
    }
    
    return outError;
}

//static dispatch_queue_t __BTLogStorage_log_queue() {
//    static dispatch_queue_t bTLogStorage_log_queue;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        bTLogStorage_log_queue = dispatch_queue_create("com.BT.BTLogStorage.log", DISPATCH_QUEUE_SERIAL);
//    });
//
//    return bTLogStorage_log_queue;
//}

@interface BTLogStorage()
@property (copy, nonatomic) NSString *fullpath;
@property (copy, nonatomic) NSString *mapFullpath;
@property (copy, nonatomic) NSString *archiveFullpath;
@property (copy, nonatomic) NSString *logFileName;
@property (strong, nonatomic) NSString *logFolder;
@property (strong, nonatomic) NSString *logFileAbsolutePath;
@property (strong, nonatomic) NSFileManager *fileManager;

@end

@implementation BTLogStorage

+ (instancetype)shraed {
    static BTLogStorage *ls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ls = [[BTLogStorage alloc] init];
    });
    
    return ls;
}

#pragma mark - public method
//遍历文件夹获得文件夹大小，返回多少M
+ (float)logFolderSize
{
    NSFileManager* manager = BTLogStorage.shraed.fileManager;
    if (![manager fileExistsAtPath: BTLogStorage.shraed.logFolder]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:BTLogStorage.shraed.logFolder] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString* fileAbsolutePath = [BTLogStorage.shraed.logFolder stringByAppendingPathComponent:fileName];
        folderSize += [self __fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (void)pushLog:(NSString *)log {
    if (![self __pushLog:log]) {
        NSLog(@"%s,发生错误啦", __func__);
    }
}
- (void)popLog:(BOOL(^)(NSData *))block {
    if (![self __popLog:block]) {
        NSLog(@"%s,发生错误啦", __func__);
    }
}

#pragma mark - private method
// 根据文件名字创建文件
- (NSString *)__createWithFileName:(NSString *)fileName
{
    BOOL existed = [self.fileManager fileExistsAtPath:self.logFolder isDirectory:nil];
    if (!existed) {
        //创建文件
        [self.fileManager createDirectoryAtPath:self.logFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",self.logFolder, fileName];
    
    if (![self.fileManager fileExistsAtPath:filePath]) {
        [self.fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    return filePath;
}

+ (long long)__fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (BOOL)__pushLog:(NSString *)log {
    int result = writeProcessFile([self.logFileAbsolutePath UTF8String], [log.description UTF8String]);
    if (result == 0) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)__popLog:(BOOL(^)(NSData *))block {
    if (![self.fileManager fileExistsAtPath:self.logFolder isDirectory:nil]) {
        return YES;//本地没有log
    }
    
    BOOL popFlag = YES;
    
    NSEnumerator* chileFilesEnumerator = [[self.fileManager subpathsAtPath:self.logFolder] objectEnumerator];
    NSString* fileName;
    while ((fileName = [chileFilesEnumerator nextObject]) != nil) {
        if ([fileName isEqualToString:self.logFileName] || ![fileName containsString:@"log_"]) {//取之前的log，跳过本次启动采集的log
            continue;
        }
        
        NSString* fileAbsolutePath = [self.logFolder stringByAppendingPathComponent:fileName];
        
        NSData *logs = nil;
        popFlag = readProcessFile([fileAbsolutePath UTF8String], &logs) == 0 ? YES:NO;
        if (!popFlag) {
            return NO;
        }
        
//        NSString *result = [[NSString alloc] initWithData:logs encoding:NSUTF8StringEncoding];
//        NSLog(@"ProcessFile-\n %@", result);
                
        if (block) {
            popFlag = block(logs);
        }
        
        //删除log文件
        if (popFlag) {
            [self.fileManager removeItemAtPath:fileAbsolutePath error:NULL];
        }else {
            break;
        }
    }
    
    return popFlag;
}


#pragma mark - setter/getter

- (NSString *)fullpath {
    if (!_fullpath || _fullpath.length == 0) {
        _fullpath = [self __createWithFileName:@"text.txt"];
    }
    return _fullpath;
}

- (NSString *)mapFullpath {
    if (!_mapFullpath || _mapFullpath.length == 0) {
        _mapFullpath = [self __createWithFileName:@"mapText.txt"];
    }
    return _mapFullpath;
}

-(NSString *)archiveFullpath {
    if (!_archiveFullpath || _archiveFullpath.length == 0) {
        _archiveFullpath = [self __createWithFileName:@"archiveText.txt"];
    }
    return _archiveFullpath;
    
}

-(NSString *)logFileAbsolutePath {
    if (!_logFileAbsolutePath || _logFileAbsolutePath.length == 0) {
        _logFileAbsolutePath = [self __createWithFileName:self.logFileName];
    }
    return _logFileAbsolutePath;
    
}

- (NSString *)logFileName {
    if (!_logFileName || _logFileName.length == 0) {
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:date];
        _logFileName = [NSString stringWithFormat:@"log_%@.txt", strDate];
    }
    return _logFileName;
}

-(NSString *)logFolder {
    if (!_logFolder) {
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;//Documents路径
        _logFolder = [docPath stringByAppendingPathComponent:@"BTLogStorage"];
    }
    return _logFolder;
    
}

-(NSFileManager *)fileManager {
    if (!_fileManager) {
        _fileManager = [NSFileManager new];
    }
    return _fileManager;
    
}



#pragma mark - test case
-  (void)eventAction {
    
#if 1
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 普通存储
        NSLog(@"File write start");
        CGFloat time1 = LogTimeBlock(^{
            for (int i=0; i<50; i++) {
                // 取
                NSString *result = [NSString stringWithContentsOfFile:self.fullpath encoding:NSUTF8StringEncoding error:nil];
                
                // 存
                ViewTrackModel *log = ViewTrackModel.new;
                log.tag = [NSString stringWithFormat:@"tag_%i",i];
                log.position = i;
                log.data = @{@"key":[NSString stringWithFormat:@"value_%i", i]};
                
                NSString *str = [NSString stringWithFormat:@"%@%@", result, [NSString stringWithFormat:@"*%@", log.description]];
                [str writeToFile:self.fullpath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
            }
        });
        NSLog(@"File write File 🙂%@s", @(time1));
    });
    
#endif
#if 0
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 普通取
        NSLog(@"File read start");
        CGFloat time2 = LogTimeBlock(^{
            // 取
            NSString *result = [NSString stringWithContentsOfFile:self.fullpath encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"File-\n %@", result);
        });
        NSLog(@"File read File 🙂%@s", @(time2));
    });
    
#endif
    
#if 0
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 映射的方式
        NSLog(@"ProcessFile write start");
        CGFloat time1 = LogTimeBlock(^{
            for (int i=0; i<50; i++) {
                ViewTrackModel *log = ViewTrackModel.new;
                log.tag = [NSString stringWithFormat:@"tag_%i",i];
                log.position = i;
                log.data = @{@"key":[NSString stringWithFormat:@"value_%i", i]};
                
                int result2 = writeProcessFile([self.mapFullpath UTF8String], [log.description UTF8String]);
                if (result2 == 1) {
                    NSLog(@"发生错误啦");
                }
            }
        });
        NSLog(@"ProcessFile write File 🙂%@s", @(time1));
    });
#endif
#if 0
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"ProcessFile read start");
        CGFloat time2 = LogTimeBlock(^{
            //取
            size_t size;
            getFileSize([self.mapFullpath UTF8String], &size);
            NSLog(@"file size is %@", @(size));
            char * buffer = malloc(1024);
            NSMutableString *logContents = [NSMutableString string];
            NSData *logs = nil;
            readProcessFile([self.mapFullpath UTF8String], &logs);
            NSString *result = [[NSString alloc] initWithData:logs encoding:NSUTF8StringEncoding];
            NSLog(@"ProcessFile-\n %@", result);
        });
        NSLog(@"ProcessFile read File 🙂%@s", @(time2));
    });
#endif
    
#if 0
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // archive write
        NSLog(@"archive write start");
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        CGFloat time1 = LogTimeBlock(^{
            for (int i=0; i<50; i++) {
                ViewTrackModel *log = ViewTrackModel.new;
                log.tag = [NSString stringWithFormat:@"tag_%i",i];
                log.position = i;
                log.data = @{@"key":[NSString stringWithFormat:@"value_%i", i]};
                
                [array addObject:log.description];
                
                [NSKeyedArchiver archiveRootObject:array toFile:self.archiveFullpath];
            }
        });
        NSLog(@"archive write File 🙂%@s", @(time1));
    });
    
#endif
#if 0
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // archive read
        NSLog(@"archive read start");
        CGFloat time2 = LogTimeBlock(^{
            //取
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archiveFullpath];
            
            NSLog(@"archive-\n %@", array);
        });
        NSLog(@"archive read File 🙂%@s", @(time2));
    });
#endif
    
    NSLog(@"正在等待结果...");
}

@end

