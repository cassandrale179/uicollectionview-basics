#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AiringRenderer : NSObject
@property(nonatomic, nonnull, readonly) NSString *airingTitle;
@property(nonatomic, nonnull, readonly) NSDate *airingStartTime;
@property(nonatomic, nonnull, readonly) NSDate *airingEndTime;
- (void)setAiringTitle:(NSString *)titleValue;
- (void)setAiringStartTime:(NSDate *)startTimeValue;
- (void)setAiringEndTime:(NSDate *)endTimeValue;
@end
// For each station, create a list of airings
@interface StationRenderer : NSObject
@property(nonatomic, nonnull, readonly) NSMutableArray<AiringRenderer *> *airings;
@property(nonatomic, nonnull, readonly) NSString *stationName;
@property(nonatomic, nonnull, readonly) UIImage *networkLogo;
- (void)setAirings:(NSMutableArray<StationRenderer *> *)airingsArray;
- (void)setStationName:(NSString *)stationNameValue;
@end
// Create a list of stations
@interface EPGRenderer : NSObject
@property(nonatomic, nonnull, readonly) NSMutableArray<StationRenderer *> *stations;
@property(nonatomic, nonnull, readonly) NSDate *startTime;
@property(nonatomic, nonnull, readonly) NSDate *endTime;
- (void)setStations:(NSMutableArray<StationRenderer *> *)stationsArray;
@end
// Create DataModel Class
@interface DataModel : NSObject
+ (EPGRenderer *)createEPG;
@end
