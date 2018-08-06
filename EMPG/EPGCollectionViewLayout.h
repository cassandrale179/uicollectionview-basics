#import <UIKit/UIKit.h>
/**
 * UICollectionViewFlowLayout dictate how the cells will align
 * and what supplementary views will be shown.
 */
@protocol EPGDataSource;
@interface EPGCollectionViewLayout : UICollectionViewFlowLayout
@property(nonatomic, weak) id<EPGDataSource> dataSource;
extern CGFloat const kBorderPadding = 30;
extern CGFloat const kAiringIntervalMinutes = 30;
- (void)initWithDelegate:(id<EPGDataSource>)dataSourceDelegate;
@end
@protocol EPGDataSource <NSObject>
- (NSDate *)layout:(EPGCollectionViewLayout *)epgLayout
    startTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)layoutStartTimeForEPG:(EPGCollectionViewLayout *)epgLayout;
- (NSInteger *)layoutBinarySearchForTime:(EPGCollectionViewLayout *)epgLayout
                      forItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)layout:(EPGCollectionViewLayout *)epgLayout
    EndTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger *)epgTimeArrayCountForLayout:(EPGCollectionViewLayout *)epgLayout;
- (NSInteger)epgStationCountForLayout:(EPGCollectionViewLayout *)epgLayout;
- (NSTimeInterval)layoutTimeIntervalBeforeAiring:(EPGCollectionViewLayout *)epgLayout
                            withClosestTimeIndex:(NSInteger)closestTimeIndex
                             withAiringStartTime:(NSDate *)startTime;
@end
