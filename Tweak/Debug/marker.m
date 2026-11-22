#import <Foundation/Foundation.h>
#import <unistd.h>

__attribute__((constructor))
static void DKMarkerInstall(void) {
    NSString *name = NSBundle.mainBundle.bundleIdentifier ?: NSProcessInfo.processInfo.processName;
    NSString *file = [NSString stringWithFormat:@"darkula-loaded-%@.txt", name];
    NSString *content = [NSString stringWithFormat:@"pid %d\n", getpid()];
    for (NSString *directory in @[NSTemporaryDirectory(), @"/var/tmp", @"/tmp", @"/var/mobile/Library/Caches"]) {
        [content writeToFile:[directory stringByAppendingPathComponent:file] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}
