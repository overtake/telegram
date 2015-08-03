//
//  main.m
//  Updater
//
//  Created by keepcoder on 08.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>




int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        NSMutableDictionary *arguments = [[NSMutableDictionary alloc] init];
        
        for(int i=1;i<argc;i++) {
            NSString *arg = [NSString stringWithFormat:@"%s",argv[i]];
            
            NSArray *s = [arg componentsSeparatedByString:@"="];
            
            arguments[s[0]] = s[1];
        }
        
        
        if(!arguments[@"--bundle_id"])
            arguments[@"--bundle_id"] = @"ru.keepcoder.Telegram";
        
        if(!arguments[@"--download_path"])
            arguments[@"--download_path"] = @"/Users/mikhailfilimonov/desktop/telegram.dmg";
        
        if(!arguments[@"--app_path"])
            arguments[@"--app_path"] = @"/Users/mikhailfilimonov/desktop/Telegram.app";

        
        if(arguments[@"--close_others"]) {
            
            NSArray *applications = [NSRunningApplication runningApplicationsWithBundleIdentifier:arguments[@"--bundle_id"]];
            
            applications = [applications sortedArrayUsingComparator:^NSComparisonResult(NSRunningApplication *obj1, NSRunningApplication *obj2) {
                return [obj1.launchDate compare:obj2.launchDate];
            }];
            
            if(applications.count > 1)
            {
                [applications enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, applications.count -1)] options:0 usingBlock:^(NSRunningApplication *obj, NSUInteger idx, BOOL *stop) {
                    
                    [obj forceTerminate];
                    
                    
                }];
                
            }

            return 0;
        }
        
        
        
     
        if(![[NSFileManager defaultManager] fileExistsAtPath:arguments[@"--download_path"] isDirectory:nil] || ![[NSFileManager defaultManager] fileExistsAtPath:arguments[@"--app_path"] isDirectory:nil])
            return 0;
        
        NSTask *attach_dmg = [[NSTask alloc] init];
        [attach_dmg setLaunchPath:@"/usr/bin/hdiutil"];
        [attach_dmg setArguments:[NSArray arrayWithObjects:@"attach",
                                  @"-nobrowse",
                             arguments[@"--download_path"], nil]];
        
        [attach_dmg launch];
        [attach_dmg waitUntilExit];
        
        if(attach_dmg.terminationStatus == 0) {
            NSArray *applications = [NSRunningApplication runningApplicationsWithBundleIdentifier:arguments[@"--bundle_id"]];
            
            
            
            applications = [applications sortedArrayUsingComparator:^NSComparisonResult(NSRunningApplication *obj1, NSRunningApplication *obj2) {
                return [obj1.launchDate compare:obj2.launchDate];
            }];
            
            if(applications.count > 0)
            {
                [applications enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, applications.count )] options:0 usingBlock:^(NSRunningApplication *obj, NSUInteger idx, BOOL *stop) {
                    
                    [obj terminate];
                    
                    
                }];
                
            }
            
            NSString *backup_path = [NSString stringWithFormat:@"%@/backup.app",[arguments[@"--download_path"] stringByDeletingLastPathComponent]];
            
            [[NSFileManager defaultManager] moveItemAtPath:arguments[@"--app_path"] toPath:backup_path error:nil];
            
            
            NSTask *cpApplication = [[NSTask alloc] init];
            [cpApplication setLaunchPath:@"/bin/cp"];
            [cpApplication setArguments:[NSArray arrayWithObjects:@"-R",
                                         @"/Volumes/Telegram/Telegram.app",
                                         arguments[@"--app_path"],
                                         nil]];
            
            
            [cpApplication launch];
            [cpApplication waitUntilExit];
            
            
            NSTask *detach = [[NSTask alloc] init];
            [detach setLaunchPath:@"/usr/bin/hdiutil"];
            [detach setArguments:[NSArray arrayWithObjects:@"detach",
                                  @"/Volumes/Telegram",
                                  nil]];
            
            [detach launch];
            [detach waitUntilExit];
            
            if(cpApplication.terminationStatus == 0) {
                [[NSFileManager defaultManager] removeItemAtPath:arguments[@"--download_path"] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:backup_path error:nil];
            } else {
                [[NSFileManager defaultManager] moveItemAtPath:backup_path toPath:arguments[@"--app_path"] error:nil];
            }
            
        }
        
        
        
//        
       
//        
        
        

     
        
         [[NSWorkspace sharedWorkspace] launchApplication:arguments[@"--app_path"]];
        
    }
    return 0;
}



