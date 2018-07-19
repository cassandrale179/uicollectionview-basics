#import <Foundation/Foundation.h>

@interface AiringRenderer : NSObject
  @property (nonatomic, readwrite) NSString* airingTitle;;
  @property (nonatomic, readwrite) long airingStartTime;
  @property (nonatomic, readwrite) long airingEndTime;
@end


// For each station, create a list of airings
@interface StationRenderer : NSObject
  @property (nonatomic, readwrite) NSMutableArray <AiringRenderer*> *airings;
  @property (nonatomic, readwrite) NSString* stationName;
//  @property (nonatomic, readwrite) UIImage* networkLogo;

@end


// Create a list of stations
@interface EPGRenderer : NSObject
  @property (nonatomic, readwrite) NSMutableArray<StationRenderer *> *stations;
  @property (nonatomic, readwrite) long startTime;
  @property (nonatomic, readwrite) long endTime;
@end
