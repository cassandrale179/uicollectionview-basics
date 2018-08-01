#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class EPGCollectionViewLayout;
/**
 * The Airing Class representing the shows that are going to be aired.
 */
@interface AiringRenderer : NSObject

/** The title of the featured show. */
@property(nonatomic, nonnull, readonly) NSString *airingTitle;

/** The start time of the featured show. */
@property(nonatomic, nonnull, readonly) NSDate *airingStartTime;

/** The end time of the featured show. */
@property(nonatomic, nonnull, readonly) NSDate *airingEndTime;

/** The setter for the title of the sample show. */
- (void)setAiringTitle:(NSString *)titleValue;

/** The setter for the start time of the featured show, given as a NSDate. */
- (void)setAiringStartTime:(NSDate *)startTimeValue;

/** The setter for the end time of the featured show, given as a NSDate. */
- (void)setAiringEndTime:(NSDate *)endTimeValue;

/**
 * Sets the start and end time of an airing
 *
 * @param duration A string representing in HH:mm-HH:mm format the start to end time
 * @param airing The airing whose start and end time will be set
 */
- (void)addTimes:(NSString *)duration forAiring:(AiringRenderer *)airing;

@end

/**
 * The Station Class for each station/row in the EPG.
 */
@interface StationRenderer : NSObject

/** The array of featured shows on that channel. */
@property(nonatomic, nonnull, readonly) NSMutableArray<AiringRenderer *> *airings;

/** The name of the channel. */
@property(nonatomic, nonnull, readonly) NSString *stationName;

/** The image of the channel that will be displayed. */
@property(nonatomic, nonnull, readonly) UIImage *networkLogo;

/** Sets the array of featured shows for this channel. */
- (void)setAirings:(NSMutableArray<StationRenderer *> *)airingsArray;

/** Sets the stations name. */
- (void)setStationName:(NSString *)stationNameValue;

@end

/**
 * The EPG Class that contains the data for the stations and airings.
 */
@interface EPGRenderer : NSObject

/** The array of featured stations that will be displayed on the epg. */
@property(nonatomic, nonnull, readonly) NSMutableArray<StationRenderer *> *stations;

/** The earliest time of the first airing show. */
@property(nonatomic, nonnull, readonly) NSDate *startTime;

/** The last time of the latest airing show. */
@property(nonatomic, nonnull, readonly) NSDate *endTime;

/** Sets the stations array with the stations that will be shown in the EPG. */
- (void)setStations:(NSMutableArray<StationRenderer *> *)stationsArray;

@end

/**
 * The Data Model Class that contains the sample data
 * with both the stations and their airings for the EPG.
 */
@interface DataModel : NSObject

/** Creates the sample data used in the EPG. */
+ (EPGRenderer *)createEPG;

/** Finds the start and end time of the First and Last airing respectively.
 *
 * @param epgObject The EPG containing all of the sample data.
 * @param timeInterval The number of minutes we should space out the time cell headers.
 * @return NSMutableArray of NSDates spaced timeInterval apart starting and ending with the startTime and endTime of the EPG.
 */
+ (NSMutableArray *) calculateEPGTime:(EPGRenderer *)epgObject timeInterval:(NSInteger)time;

/** Determines the most recent thirty minute time interval to the startTime and endTime of the epg.
 * ie. 9:30am if the current time is 9:37am
 *
 * @param dateToFormat The start or endTime of the epg.
 * @return The closest thirty minute time interval to dateToFormat.
 */
+ (NSDate *)formatTime:(NSDate *)dateToFormat;
@end
