#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AiringRenderer : NSObject
@property (nonatomic) NSString *airingTitle;;
@property (nonatomic) NSDate *airingStartTime;
@property (nonatomic) NSDate *airingEndTime;
@end


// For each station, create a list of airings
@interface StationRenderer : NSObject
@property (nonatomic) NSMutableArray <AiringRenderer*> *airings;
@property (nonatomic) NSString *stationName;
@property (nonatomic) UIImage *networkLogo;
@end


// Create a list of stations
@interface EPGRenderer : NSObject
@property (nonatomic) NSMutableArray<StationRenderer *> *stations;
@property (nonatomic) long startTime;
@property (nonatomic) long endTime;
@end
