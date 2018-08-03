#import <UIKit/UIKit.h>
/**
 * UICollectionViewFlowLayout dictate how the cells will align
 * and what supplementary views will be shown.
 */
@protocol EPGDataSourceDelegate;
@interface EPGCollectionViewLayout : UICollectionViewFlowLayout
@property (nonatomic, weak) id<EPGDataSourceDelegate> dataSource;
extern CGFloat const kVerticalPadding = 50;
extern CGFloat const kBorderPadding = 30;
extern CGFloat const kAiringIntervalMinutes = 30;
-(void)initWithDelegate:(id<EPGDataSourceDelegate>)dataSourceDelegate;
-(CGFloat)numOfHalfHourIntervals:(NSDate *)airingStartTime withEndTime:(NSDate *)airingEndTime;
-(CGFloat) startingXPositionForAiring:(NSDate *)airingStartTime withIndexPath:(NSIndexPath *)indexPath;
@end
@protocol EPGDataSourceDelegate <NSObject>
// Return start time for airing cell
-(NSDate *)layout:(EPGCollectionViewLayout *)epgLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
// Return end time for an airing cell
-(NSDate *)layout:(EPGCollectionViewLayout *)epgLayout EndTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
// Return start time for the entire epg (the first start time)
-(NSDate *)layoutStartTimeForEPG:(EPGCollectionViewLayout *)epgLayout;
// Binary search for time
-(NSInteger)layoutBinarySearchForTime:(EPGCollectionViewLayout *)epgLayout forItemAtIndexPath:(NSIndexPath *)indexPath;
// Return how many cells for hour header view
-(NSUInteger)epgTimeArrayCountForLayout:(EPGCollectionViewLayout *)epgLayout;
// Return how many cells for station cell count
-(NSInteger)epgStationCountForLayout: (EPGCollectionViewLayout *) epgLayout;
// Closest time interval before airing
-(NSTimeInterval)layoutTimeIntervalBeforeAiring:(EPGCollectionViewLayout *)epgLayout withClosestTimeIndex:(NSInteger)closestTimeIndex withAiringStartTime:(NSDate *)startTime;
@end
