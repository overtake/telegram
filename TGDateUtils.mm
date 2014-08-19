#include "TGDateUtils.h"
#include <time.h>

static time_t midnightOnDay(time_t t)
{
    struct tm theday;
    localtime_r(&t, &theday);
    theday.tm_hour = 0;
    theday.tm_min = 0;
    theday.tm_sec = 0;
    return mktime(&theday);
}

static time_t todayMidnight()
{
    return midnightOnDay(time(0));
}

static bool areSameDay(time_t t1, time_t t2)
{
    struct tm tm1, tm2;
    localtime_r(&t1, &tm1);
    localtime_r(&t2, &tm2);
    return ((tm1.tm_mday == tm2.tm_mday) && (tm1.tm_mon == tm2.tm_mon) && (tm1.tm_year == tm2.tm_year));
}

static int daysBetween(time_t t1, time_t t2)
{
    // we'll be rounding down fractional days, so set t1 to midnight and then do division
    time_t newt1 = midnightOnDay(t1);
    return (int) ((t2 - newt1) / (60 * 60 * 24));
}

static bool value_dateHas12hFormat = false;
static __strong NSString *value_monthNamesGenShort[] = {
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
};
static __strong NSString *value_monthNamesGenFull[] = {
    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
};
static __strong NSString *value_weekdayNamesShort[] = {
    nil, nil, nil, nil, nil, nil, nil
};
static __strong NSString *value_weekdayNamesFull[] = {
    nil, nil, nil, nil, nil, nil, nil
};

static bool value_dialogTimeMonthNameFirst = false;
static NSString *value_dialogTimeFormat = nil;

static NSString *value_today = nil;
static NSString *value_yesterday = nil;
static NSString *value_tomorrow = nil;
static NSString *value_at = nil;

static char value_date_separator = '.';
static bool value_monthFirst = false;

static bool TGDateUtilsInitialized = false;
static void initializeTGDateUtils()
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[dateFormatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[dateFormatter PMSymbol]];
    value_dateHas12hFormat = !(amRange.location == NSNotFound && pmRange.location == NSNotFound);
    
    dateString = [NSDateFormatter dateFormatFromTemplate:@"MdY" options:0 locale:[NSLocale currentLocale]];
    if ([dateString rangeOfString:@"."].location != NSNotFound)
    {
        value_date_separator = '.';
    }
    else if ([dateString rangeOfString:@"/"].location != NSNotFound)
    {
        value_date_separator = '/';
    }
    else if ([dateString rangeOfString:@"-"].location != NSNotFound)
    {
        value_date_separator = '-';
    }
    
    if ([dateString rangeOfString:[NSString stringWithFormat:@"M%cd", value_date_separator]].location != NSNotFound)
    {
        value_monthFirst = true;
    }
    
    value_monthNamesGenShort[0] = NSLocalizedString(@"Month.ShortJanuary", @"");
    value_monthNamesGenShort[1] = NSLocalizedString(@"Month.ShortFebruary", @"");
    value_monthNamesGenShort[2] = NSLocalizedString(@"Month.ShortMarch", @"");
    value_monthNamesGenShort[3] = NSLocalizedString(@"Month.ShortApril", @"");
    value_monthNamesGenShort[4] = NSLocalizedString(@"Month.ShortMay", @"");
    value_monthNamesGenShort[5] = NSLocalizedString(@"Month.ShortJune", @"");
    value_monthNamesGenShort[6] = NSLocalizedString(@"Month.ShortJuly", @"");
    value_monthNamesGenShort[7] = NSLocalizedString(@"Month.ShortAugust", @"");
    value_monthNamesGenShort[8] = NSLocalizedString(@"Month.ShortSeptember", @"");
    value_monthNamesGenShort[9] = NSLocalizedString(@"Month.ShortOctober", @"");
    value_monthNamesGenShort[10] = NSLocalizedString(@"Month.ShortNovember", @"");
    value_monthNamesGenShort[11] = NSLocalizedString(@"Month.ShortDecember", @"");
    
    value_monthNamesGenFull[0] = NSLocalizedString(@"Month.GenJanuary", @"");
    value_monthNamesGenFull[1] = NSLocalizedString(@"Month.GenFebruary", @"");
    value_monthNamesGenFull[2] = NSLocalizedString(@"Month.GenMarch", @"");
    value_monthNamesGenFull[3] = NSLocalizedString(@"Month.GenApril", @"");
    value_monthNamesGenFull[4] = NSLocalizedString(@"Month.GenMay", @"");
    value_monthNamesGenFull[5] = NSLocalizedString(@"Month.GenJune", @"");
    value_monthNamesGenFull[6] = NSLocalizedString(@"Month.GenJuly", @"");
    value_monthNamesGenFull[7] = NSLocalizedString(@"Month.GenAugust", @"");
    value_monthNamesGenFull[8] = NSLocalizedString(@"Month.GenSeptember", @"");
    value_monthNamesGenFull[9] = NSLocalizedString(@"Month.GenOctober", @"");
    value_monthNamesGenFull[10] = NSLocalizedString(@"Month.GenNovember", @"");
    value_monthNamesGenFull[11] = NSLocalizedString(@"Month.GenDecember", @"");
    
    value_weekdayNamesShort[0] = NSLocalizedString(@"Weekday.ShortMonday", @"");
    value_weekdayNamesShort[1] = NSLocalizedString(@"Weekday.ShortTuesday", @"");
    value_weekdayNamesShort[2] = NSLocalizedString(@"Weekday.ShortWednesday", @"");
    value_weekdayNamesShort[3] = NSLocalizedString(@"Weekday.ShortThursday", @"");
    value_weekdayNamesShort[4] = NSLocalizedString(@"Weekday.ShortFriday", @"");
    value_weekdayNamesShort[5] = NSLocalizedString(@"Weekday.ShortSaturday", @"");
    value_weekdayNamesShort[6] = NSLocalizedString(@"Weekday.ShortSunday", @"");
    
    value_weekdayNamesFull[0] = NSLocalizedString(@"Weekday.Monday", @"");
    value_weekdayNamesFull[1] = NSLocalizedString(@"Weekday.Tuesday", @"");
    value_weekdayNamesFull[2] = NSLocalizedString(@"Weekday.Wednesday", @"");
    value_weekdayNamesFull[3] = NSLocalizedString(@"Weekday.Thursday", @"");
    value_weekdayNamesFull[4] = NSLocalizedString(@"Weekday.Friday", @"");
    value_weekdayNamesFull[5] = NSLocalizedString(@"Weekday.Saturday", @"");
    value_weekdayNamesFull[6] = NSLocalizedString(@"Weekday.Sunday", @"");
    
    value_dialogTimeMonthNameFirst = [NSLocalizedString(@"Date.DialogDateFormat", @"") hasPrefix:@"{month}"];
    value_dialogTimeFormat = [[NSLocalizedString(@"Date.DialogDateFormat", @"") stringByReplacingOccurrencesOfString:@"{month}" withString:@"%@"] stringByReplacingOccurrencesOfString:@"{day}" withString:@"%d"];
    
    value_today = NSLocalizedString(@"Time.today", @"");
    value_yesterday = NSLocalizedString(@"Time.yesterday", @"");
    value_tomorrow = NSLocalizedString(@"Time.tomorrow", @"");
    value_at = NSLocalizedString(@"Time.at", @"");
    
    TGDateUtilsInitialized = true;
}

static inline bool dateHas12hFormat()
{
    if (!TGDateUtilsInitialized)
        initializeTGDateUtils();
    
    return value_dateHas12hFormat;
}

bool TGUse12hDateFormat()
{
    if (!TGDateUtilsInitialized)
        initializeTGDateUtils();
    
    return value_dateHas12hFormat;
}

static inline NSString *weekdayNameShort(int number)
{
    if (!TGDateUtilsInitialized)
        initializeTGDateUtils();
    
    if (number < 0)
        number = 0;
    if (number > 6)
        number = 6;
    
    if (number == 0)
        number = 6;
    else
        number--;
    
    return value_weekdayNamesShort[number];
}

static inline NSString *weekdayNameFull(int number)
{
    if (!TGDateUtilsInitialized)
        initializeTGDateUtils();
    
    if (number < 0)
        number = 0;
    if (number > 6)
        number = 6;
    
    if (number == 0)
        number = 6;
    else
        number--;
    
    return value_weekdayNamesFull[number];
}

static inline NSString *monthNameGenShort(int number)
{
    if (!TGDateUtilsInitialized)
        initializeTGDateUtils();
    
    if (number < 0)
        number = 0;
    if (number > 11)
        number = 11;
    
    return value_monthNamesGenShort[number];
}

static inline NSString *monthNameGenFull(int number)
{
    if (!TGDateUtilsInitialized)
        initializeTGDateUtils();
    
    if (number < 0)
        number = 0;
    if (number > 11)
        number = 11;
    
    return value_monthNamesGenFull[number];
}

static inline bool dialogTimeMonthNameFirst()
{
    if (!TGDateUtilsInitialized)
        initializeTGDateUtils();
    
    return value_dialogTimeMonthNameFirst;
}

static inline NSString *dialogTimeFormat()
{
    if (!TGDateUtilsInitialized)
        initializeTGDateUtils();
    
    return value_dialogTimeFormat;
}

@implementation TGDateUtils

+ (NSString *)stringForShortTime:(int)time
{
    time_t t = time;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    if (dateHas12hFormat())
    {
        if (timeinfo.tm_hour < 12)
            return [[NSString alloc] initWithFormat:@"%d:%02d AM", timeinfo.tm_hour == 0 ? 12 : timeinfo.tm_hour, timeinfo.tm_min];
        else
            return [[NSString alloc] initWithFormat:@"%d:%02d PM", (timeinfo.tm_hour - 12 == 0) ? 12 : (timeinfo.tm_hour - 12), timeinfo.tm_min];
    }
    else
        return [[NSString alloc] initWithFormat:@"%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min];
}

+ (NSString *)stringForDialogTime:(int)time
{
    time_t t = time;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    if (dialogTimeMonthNameFirst())
        return [[NSString alloc] initWithFormat:dialogTimeFormat(), monthNameGenFull(timeinfo.tm_mon), timeinfo.tm_mday];
    else
        return [[NSString alloc] initWithFormat:dialogTimeFormat(), timeinfo.tm_mday, monthNameGenFull(timeinfo.tm_mon)];
}

+ (NSString *)stringForDayOfMonth:(int)date dayOfMonth:(int *)dayOfMonth
{
    time_t t = date;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    if (dayOfMonth != NULL)
        *dayOfMonth = timeinfo.tm_mday;
    
    if (dialogTimeMonthNameFirst())
        return [[NSString alloc] initWithFormat:@"%@ %d", monthNameGenShort(timeinfo.tm_mon), timeinfo.tm_mday];
    else
        return [[NSString alloc] initWithFormat:@"%d %@", timeinfo.tm_mday, monthNameGenShort(timeinfo.tm_mon)];
}

+ (NSString *)stringForDayOfMonthFull:(int)date dayOfMonth:(int *)dayOfMonth
{
    time_t t = date;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    if (dayOfMonth != NULL)
        *dayOfMonth = timeinfo.tm_mday;
    
    if (dialogTimeMonthNameFirst())
        return [[NSString alloc] initWithFormat:@"%@ %d", monthNameGenFull(timeinfo.tm_mon), timeinfo.tm_mday];
    else
        return [[NSString alloc] initWithFormat:@"%d %@", timeinfo.tm_mday, monthNameGenFull(timeinfo.tm_mon)];
}

+ (NSString *)stringForDayOfWeek:(int)date
{
    time_t t = date;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    return weekdayNameFull(timeinfo.tm_wday);
}

+ (NSString *)stringForMessageListDate:(int)date
{   
    time_t t = date;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    time_t t_now;
    time(&t_now);
    struct tm timeinfo_now;
    localtime_r(&t_now, &timeinfo_now);
    
    if (timeinfo.tm_year != timeinfo_now.tm_year)
    {
        if (value_monthFirst)
            return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
        else
            return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
    }
    else
    {   
        int dayDiff = timeinfo.tm_yday - timeinfo_now.tm_yday;// daysBetween(t_now, t);
        
        if(dayDiff == 0)
        {
            if (dateHas12hFormat())
            {
                if (timeinfo.tm_hour < 12)
                    return [[NSString alloc] initWithFormat:@"%d:%02d AM", timeinfo.tm_hour == 0 ? 12 : timeinfo.tm_hour, timeinfo.tm_min];
                else
                    return [[NSString alloc] initWithFormat:@"%d:%02d PM", (timeinfo.tm_hour - 12 == 0) ? 12 : (timeinfo.tm_hour - 12), timeinfo.tm_min];
            }
            else
                return [[NSString alloc] initWithFormat:@"%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min];
        }
        else if(dayDiff == -1)
            return weekdayNameShort(timeinfo.tm_wday);
        else if(dayDiff == -2) 
            return weekdayNameShort(timeinfo.tm_wday);
        else if(dayDiff > -7 && dayDiff <= -2) 
            return weekdayNameShort(timeinfo.tm_wday);
        /*else if (true || (dayDiff > -180 && dayDiff <= -7))
        {
            if (dialogTimeMonthNameFirst())
                return [[NSString alloc] initWithFormat:@"%@ %d", monthNameGenShort(timeinfo.tm_mon), timeinfo.tm_mday];
            else
                return [[NSString alloc] initWithFormat:@"%d %@", timeinfo.tm_mday, monthNameGenShort(timeinfo.tm_mon)];
        }*/
        else
        {
            if (value_monthFirst)
                return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
            else
                return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
        }
    }
    
    return nil;
}

+ (NSString *)stringForLastSeen:(int)date
{
    time_t t = date;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    time_t t_now;
    time(&t_now);
    struct tm timeinfo_now;
    localtime_r(&t_now, &timeinfo_now);
    
    if (timeinfo.tm_year != timeinfo_now.tm_year)
    {
        if (value_monthFirst)
            return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
        else
            return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
    }
    else
    {
        int dayDiff = timeinfo.tm_yday - timeinfo_now.tm_yday;
        
        if(dayDiff == 0 || dayDiff == -1)
        {
            if (dateHas12hFormat())
            {
                if (timeinfo.tm_hour < 12)
                    return [[NSString alloc] initWithFormat:@"%@ %@ %d:%02d AM", dayDiff == 0 ? value_today : value_yesterday, value_at, timeinfo.tm_hour == 0 ? 12 : timeinfo.tm_hour, timeinfo.tm_min];
                else
                    return [[NSString alloc] initWithFormat:@"%@ %@ %d:%02d PM", dayDiff == 0 ? value_today : value_yesterday, value_at, (timeinfo.tm_hour - 12 == 0) ? 12 : (timeinfo.tm_hour - 12), timeinfo.tm_min];
            }
            else
                return [[NSString alloc] initWithFormat:@"%@ %@ %02d:%02d", dayDiff == 0 ? value_today : value_yesterday, value_at, timeinfo.tm_hour, timeinfo.tm_min];
        }
        else if (false && dayDiff > -7 && dayDiff <= -2)
        {
            return weekdayNameShort(timeinfo.tm_wday);
        }
        else
        {
            if (value_monthFirst)
                return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
            else
                return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
        }
    }
    
    return nil;
}

+ (NSString *)stringForLastSeenShort:(int)date
{
    time_t t = date;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    time_t t_now;
    time(&t_now);
    struct tm timeinfo_now;
    localtime_r(&t_now, &timeinfo_now);
    
    if (timeinfo.tm_year != timeinfo_now.tm_year)
    {
        if (value_monthFirst)
            return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
        else
            return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
    }
    else
    {
        int dayDiff = timeinfo.tm_yday - timeinfo_now.tm_yday;
        
        if(dayDiff == 0 || dayDiff == -1)
        {
            if (dateHas12hFormat())
            {
                if (timeinfo.tm_hour < 12)
                    return [[NSString alloc] initWithFormat:@"%@%s%@ %d:%02d AM", dayDiff == 0 ? @"" : value_yesterday, dayDiff == 0 ? "" : " ", value_at, timeinfo.tm_hour == 0 ? 12 : timeinfo.tm_hour, timeinfo.tm_min];
                else
                    return [[NSString alloc] initWithFormat:@"%@%s%@ %d:%02d PM", dayDiff == 0 ? @"" : value_yesterday, dayDiff == 0 ? "" : " ", value_at, (timeinfo.tm_hour - 12 == 0) ? 12 : (timeinfo.tm_hour - 12), timeinfo.tm_min];
            }
            else
            {
                return [[NSString alloc] initWithFormat:@"%@%s%@ %02d:%02d", dayDiff == 0 ? @"" : value_yesterday, dayDiff == 0 ? "" : " ", value_at, timeinfo.tm_hour, timeinfo.tm_min];
            }
        }
        else if (false && dayDiff > -7 && dayDiff <= -2)
        {
            return weekdayNameShort(timeinfo.tm_wday);
        }
        else
        {
            if (value_monthFirst)
                return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
            else
                return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
        }
    }
    
    return nil;
}

+ (NSString *)stringForRelativeLastSeen:(int)date
{
    time_t t = date;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    time_t t_now;
    time(&t_now);
    struct tm timeinfo_now;
    localtime_r(&t_now, &timeinfo_now);
    
    if (timeinfo.tm_year != timeinfo_now.tm_year)
    {
        if (value_monthFirst)
            return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
        else
            return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
    }
    else
    {
        int dayDiff = timeinfo.tm_yday - timeinfo_now.tm_yday;
        
        int minutesDiff = (int) (t_now - date) / 60;
        int hoursDiff = (int) (t_now - date) / (60 * 60);
        
        if (dayDiff == 0 && hoursDiff <= 23)
        {
            if (minutesDiff < 1)
            {
                return NSLocalizedString(@"Time.justnow", nil);
            }
            else if (minutesDiff < 60)
            {
                return [[NSString alloc] initWithFormat:minutesDiff == 1 ? NSLocalizedString(@"Time.agoMinute",nil) : NSLocalizedString(@"Time.agoMinutes", nil), minutesDiff];
            }
            else
            {
                return [[NSString alloc] initWithFormat:hoursDiff == 1 ? NSLocalizedString(@"Time.agoHour",nil) : NSLocalizedString(@"Time.agoHours",nil), hoursDiff];
            }
        }
        else if (dayDiff == 0 || dayDiff == -1)
        {
            if (dateHas12hFormat())
            {
                if (timeinfo.tm_hour < 12)
                    return [[NSString alloc] initWithFormat:@"%@%s%@ %d:%02d AM", dayDiff == 0 ? @"" : value_yesterday, dayDiff == 0 ? "" : " ", value_at, timeinfo.tm_hour == 0 ? 12 : timeinfo.tm_hour, timeinfo.tm_min];
                else
                    return [[NSString alloc] initWithFormat:@"%@%s%@ %d:%02d PM", dayDiff == 0 ? @"" : value_yesterday, dayDiff == 0 ? "" : " ", value_at, (timeinfo.tm_hour - 12 == 0) ? 12 : (timeinfo.tm_hour - 12), timeinfo.tm_min];
            }
            else
            {
                return [[NSString alloc] initWithFormat:@"%@%s%@ %02d:%02d", dayDiff == 0 ? @"" : value_yesterday, dayDiff == 0 ? "" : " ", value_at, timeinfo.tm_hour, timeinfo.tm_min];
            }
        }
        else
        {
            if (value_monthFirst)
                return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
            else
                return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
        }
    }
    
    return nil;
}

+ (NSString *)stringForUntil:(int)date
{
    time_t t = date;
    struct tm timeinfo;
    localtime_r(&t, &timeinfo);
    
    time_t t_now;
    time(&t_now);
    struct tm timeinfo_now;
    localtime_r(&t_now, &timeinfo_now);
    
    if (timeinfo.tm_year != timeinfo_now.tm_year)
    {
        if (value_monthFirst)
            return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
        else
            return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
    }
    else
    {
        int dayDiff = timeinfo.tm_yday - timeinfo_now.tm_yday; //daysBetween(t_now, t);
        
        if(dayDiff == 0 || dayDiff == 1)
        {
            if (dateHas12hFormat())
            {
                if (timeinfo.tm_hour < 12)
                    return [[NSString alloc] initWithFormat:@"%@, %d:%02d AM", dayDiff == 0 ? value_today : value_tomorrow, timeinfo.tm_hour == 0 ? 12 : timeinfo.tm_hour, timeinfo.tm_min];
                else
                    return [[NSString alloc] initWithFormat:@"%@, %d:%02d PM", dayDiff == 0 ? value_today : value_tomorrow, (timeinfo.tm_hour - 12 == 0) ? 12 : (timeinfo.tm_hour - 12), timeinfo.tm_min];
            }
            else
                return [[NSString alloc] initWithFormat:@"%@, %02d:%02d", dayDiff == 0 ? value_today : value_tomorrow, timeinfo.tm_hour, timeinfo.tm_min];
        }
        else
        {
            if (value_monthFirst)
                return [[NSString alloc] initWithFormat:@"%d%c%d%c%02d", timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_mday, value_date_separator, timeinfo.tm_year - 100];
            else
                return [[NSString alloc] initWithFormat:@"%d%c%02d%c%02d", timeinfo.tm_mday, value_date_separator, timeinfo.tm_mon + 1, value_date_separator, timeinfo.tm_year - 100];
        }
    }
    
    return nil;
}

@end
