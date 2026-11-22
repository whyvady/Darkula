#import "excluded-controller.h"
#import "keys.h"

static const NSInteger DKSwitchCell = 6;

static NSString *DKProxyString(id proxy, NSString *key) {
    if (![proxy respondsToSelector:NSSelectorFromString(key)]) return nil;
    id value = [proxy valueForKey:key];
    return [value isKindOfClass:NSString.class] ? value : nil;
}

static BOOL DKProxyHidden(id proxy) {
    if (![proxy respondsToSelector:NSSelectorFromString(@"appTags")]) return NO;
    id tags = [proxy valueForKey:@"appTags"];
    return [tags isKindOfClass:NSArray.class] && [tags containsObject:@"hidden"];
}

static NSArray *DKInstalledApplications(void) {
    Class workspaceClass = NSClassFromString(@"LSApplicationWorkspace");
    if (!workspaceClass) return @[];
    LSApplicationWorkspace *workspace = [workspaceClass defaultWorkspace];
    return [workspace allInstalledApplications] ?: @[];
}

@implementation DKExcludedController

- (NSArray *)specifiers {
    if (_specifiers) return _specifiers;
    NSMutableArray *userApps = [NSMutableArray array];
    NSMutableArray *systemApps = [NSMutableArray array];
    NSMutableSet *seen = [NSMutableSet set];
    for (id proxy in DKInstalledApplications()) {
        NSString *identifier = DKProxyString(proxy, @"applicationIdentifier");
        NSString *name = DKProxyString(proxy, @"localizedName");
        NSString *type = DKProxyString(proxy, @"applicationType");
        if (!identifier.length || !name.length) continue;
        if ([seen containsObject:identifier] || DKProxyHidden(proxy)) continue;
        [seen addObject:identifier];
        NSDictionary *entry = @{@"id": identifier, @"name": name};
        if ([type isEqualToString:@"User"]) {
            [userApps addObject:entry];
        } else {
            [systemApps addObject:entry];
        }
    }
    NSMutableArray *specifiers = [NSMutableArray array];
    [specifiers addObjectsFromArray:[self specifiersForEntries:userApps header:@"User Apps" footer:@"Apps switched on keep their original light appearance."]];
    [specifiers addObjectsFromArray:[self specifiersForEntries:systemApps header:@"System Apps" footer:nil]];
    _specifiers = specifiers;
    return _specifiers;
}

- (NSArray *)specifiersForEntries:(NSArray *)entries header:(NSString *)header footer:(NSString *)footer {
    if (!entries.count) return @[];
    NSArray *sorted = [entries sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *first, NSDictionary *second) {
        return [first[@"name"] caseInsensitiveCompare:second[@"name"]];
    }];
    NSMutableArray *result = [NSMutableArray array];
    PSSpecifier *group = [PSSpecifier groupSpecifierWithName:header];
    if (footer) [group setProperty:footer forKey:@"footerText"];
    [result addObject:group];
    for (NSDictionary *entry in sorted) {
        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:entry[@"name"] target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:DKSwitchCell edit:nil];
        [specifier setProperty:DK_PREFS_DOMAIN forKey:@"defaults"];
        [specifier setProperty:[DK_EXCLUDE_PREFIX stringByAppendingString:entry[@"id"]] forKey:@"key"];
        [specifier setProperty:@NO forKey:@"default"];
        [result addObject:specifier];
    }
    return result;
}

@end
