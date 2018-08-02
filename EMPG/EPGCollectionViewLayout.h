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
@end
@protocol EPGDataSourceDelegate <NSObject>
-(NSDate *)layout:(EPGCollectionViewLayout *)epgLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
-(NSDate *)layoutStartTimeForEPG:(EPGCollectionViewLayout *)epgLayout;
-(NSInteger *)layoutBinarySearchForTime:(EPGCollectionViewLayout *)epgLayout forItemAtIndexPath:(NSIndexPath *)indexPath;
-(NSDate *)layout:(EPGCollectionViewLayout *)epgLayout EndTimeForItemAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger *)epgTimeArrayCountForLayout:(EPGCollectionViewLayout *)epgLayout;
-(NSInteger) epgStationCountForLayout: (EPGCollectionViewLayout *) epgLayout;
-(NSTimeInterval)layoutTimeIntervalBeforeAiring:(EPGCollectionViewLayout *)epgLayout withClosestTimeIndex:(NSInteger)closestTimeIndex withAiringStartTime:(NSDate *)startTime;
@end
