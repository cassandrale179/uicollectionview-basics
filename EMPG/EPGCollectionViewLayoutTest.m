#import "EPGCollectionViewLayout.h"
#import "DataModel.h"
#import "ViewController.h"

@implementation EPGCollectionViewLayout {
  // Dictionary for cell types and time array
  NSMutableDictionary *_itemAttributes;
  NSMutableDictionary *_channelAttributes;
  NSMutableDictionary *_hourAttributes;
  // NSMutableArray *_timeArray;
  CGSize _contentSize;
}

// Measurement constants
static const CGFloat kCellHeight = 100;
static const CGFloat kHalfHourWidth = 400;
static const CGFloat kVerticalPadding = 50;

// Constants for views
static const NSString *kTimeIndicatorKind = @"TimeIndicatorView";
static const NSString *kTimeCellKind = @"HourHeaderView";
static const NSString *kStationCellKind = @"ChannelHeaderView";

// Constants for supplementary view
static const CGFloat kHourHeaderHeight = 40;      // height of each time cell
static const CGFloat kChannelHeaderHeight = 100;  // height of each channel cell
static const CGFloat kChannelHeaderWidth = 100;   // width of each channel cell
static const CGFloat kThumbnailSize = 0.5;        // size of the video thumbnail
static const CGFloat topOfIndicator = 20;         // space between screen and tip of time indicator

// Other attributes

// BOOL needSetup = YES;
- (void)initWithDelegate:(id<EPGDataSource>)dataSourceDelegate {
  _dataSource = dataSourceDelegate;
}

#pragma mark Prepare Layout
// Return content size.
- (CGSize)collectionViewContentSize {
  return _contentSize;
}

// Calculating the bounds (origin x and y) of the cells.
- (void)prepareLayout {
  //_timeArray = [_dataSource epgTimeArrayForLayout:self];

  // setting the frame for the various cells
  [self setAttributesForTimeHeaders];
  [self setAttributesForEPGCells];
  [self setAttributesForChannelCells];
}

- (void)setAttributesForTimeHeaders {
  // Create attributes for the Hour Header.
  NSArray *hourHeaderViewIndexPaths = [self indexPathsOfHourHeaderViews];
  _hourAttributes = [[NSMutableDictionary alloc] init];
  for (NSIndexPath *indexPath in hourHeaderViewIndexPaths) {
    UICollectionViewLayoutAttributes *attributes =
        [self layoutAttributesForSupplementaryViewOfKind:kTimeCellKind atIndexPath:indexPath];

    // Make the hour header pin to the top when scrolling vertically.
    CGFloat yOffSet = self.collectionView.contentOffset.y;
    CGPoint origin = attributes.frame.origin;
    origin.y = yOffSet;
    attributes.frame = (CGRect){.origin = origin, .size = attributes.frame.size};
    attributes.zIndex = [self zIndexForElementKind:kTimeCellKind];
    _hourAttributes[indexPath] = attributes;
  }
}

- (void)setAttributesForEPGCells {
  // Create attributes for the Airing Cells.
  CGFloat xMax = 0;
  _itemAttributes = [[NSMutableDictionary alloc] init];
  if (self.collectionView.numberOfSections > 0) {
    for (NSUInteger section = 0; section < self.collectionView.numberOfSections; section++) {
      if ([self.collectionView numberOfItemsInSection:section] > 0) {
        CGFloat xPos = kChannelHeaderWidth;
        CGFloat yPos = kVerticalPadding + section * kCellHeight + kBorderPadding * section;
        CGFloat numHalfHourIntervals;

        // Calculate the frame of each airing cell.
        for (NSUInteger item = 0; item < [self.collectionView numberOfItemsInSection:section];
             item++) {
          NSIndexPath *cellIndex = [NSIndexPath indexPathForItem:item inSection:section];
          UICollectionViewLayoutAttributes *attr;

          // If the cell is not a thumbnail
          if (item != 0) {
            NSDate *currentAiringStartTime = [_dataSource layout:self
                                     startTimeForItemAtIndexPath:cellIndex];
            xPos = [self startingXPositionForAiring:currentAiringStartTime withIndexPath:cellIndex];
            NSDate *currentAiringEndTime = [_dataSource layout:self
                                     EndTimeForItemAtIndexPath:cellIndex];
            numHalfHourIntervals = [self numOfHalfHourIntervals:currentAiringStartTime
                                                    withEndTime:currentAiringEndTime];
            attr =
                [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          } else {
            // Set constant for the size of the thumbnail.
            numHalfHourIntervals = kThumbnailSize;
            attr =
                [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          }
          attr.frame = CGRectMake(xPos, yPos, numHalfHourIntervals * kHalfHourWidth, kCellHeight);
          _itemAttributes[cellIndex] = attr;
        }
        xMax = MAX(xMax, xPos + numHalfHourIntervals * kHalfHourWidth);
      }

      // Return total content size of all cells within it.
      CGFloat contentWidth = xMax;
      CGFloat contentHeight =
          [self.collectionView numberOfSections] * (kCellHeight + kBorderPadding) +
          kVerticalPadding;
      _contentSize = CGSizeMake(contentWidth, contentHeight);
    }
  }
}

- (void)setAttributesForChannelCells {
  // Create attributes for the Channel Header.
  NSArray *channelHeaderIndexPaths = [self indexPathsOfChannelHeaderViews];
  _channelAttributes = [[NSMutableDictionary alloc] init];
  for (NSIndexPath *indexPath in channelHeaderIndexPaths) {
    UICollectionViewLayoutAttributes *attributes =
        [self layoutAttributesForSupplementaryViewOfKind:kStationCellKind atIndexPath:indexPath];

    // Make the network header pin to the left when scrolling horizontally.
    CGFloat xOffset = self.collectionView.contentOffset.x;
    CGPoint origin = attributes.frame.origin;
    origin.x = xOffset;
    attributes.zIndex = [self zIndexForElementKind:kStationCellKind];

    // Get attributes of the airing cells to vertically align the channel and airing cells.
    UICollectionViewLayoutAttributes *cellattr =
        _itemAttributes[[NSIndexPath indexPathForItem:0 inSection:indexPath.section]];
    attributes.frame = CGRectMake(xOffset, cellattr.frame.origin.y, 100, 100);
    _channelAttributes[indexPath] = attributes;
  }
}

#pragma mark Airing Cell Calculations
// Return the factor by which the standard cell width should be multipled, given a certain duration
- (CGFloat)numOfHalfHourIntervals:(NSDate *)airingStartTime withEndTime:(NSDate *)airingEndTime {
  return [airingEndTime timeIntervalSinceDate:airingStartTime] / (kAiringIntervalMinutes * 60.);
}

// Return the x position that the airing cell should start at in relation to the header time cells
- (CGFloat)startingXPositionForAiring:(NSDate *)airingStartTime
                        withIndexPath:(NSIndexPath *)indexPath {
  NSInteger closestTimeIndex = [_dataSource layoutBinarySearchForTime:self
                                                   forItemAtIndexPath:indexPath];
  UICollectionViewLayoutAttributes *hourAttributes =
      _hourAttributes[[NSIndexPath indexPathForItem:closestTimeIndex inSection:0]];
  return [_dataSource layoutTimeIntervalBeforeAiring:self
                                withClosestTimeIndex:closestTimeIndex
                                 withAiringStartTime:airingStartTime] /
             (kAiringIntervalMinutes * 60.) * kHalfHourWidth +
         hourAttributes.frame.origin.x;
}

#pragma mark Layout Attribute for Element in Rect and Supplementary View
// Return the frame for each cell (333.333 0; 200 100).
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *attributesInRect = [[NSMutableArray alloc] init];

  // Add all the attributes to attributesInRect (the entire view).
  for (NSIndexPath *indexPath in _itemAttributes) {
    UICollectionViewLayoutAttributes *attributes = _itemAttributes[indexPath];
    if (CGRectIntersectsRect(rect, attributes.frame)) {
      [attributesInRect addObject:attributes];
    }
  }
  for (NSIndexPath *indexPath in _channelAttributes) {
    UICollectionViewLayoutAttributes *attributes = _channelAttributes[indexPath];
    if (CGRectIntersectsRect(rect, attributes.frame)) {
      [attributesInRect addObject:attributes];
    }
  }
  for (NSIndexPath *indexPath in _hourAttributes) {
    UICollectionViewLayoutAttributes *attributes = _hourAttributes[indexPath];
    if (CGRectIntersectsRect(rect, attributes.frame)) {
      [attributesInRect addObject:attributes];
    }
  }

  // Supplementary view for time indicator cell.
  UICollectionViewLayoutAttributes *attributes = [self
      layoutAttributesForSupplementaryViewOfKind:kTimeIndicatorKind
                                     atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
  [attributesInRect addObject:attributes];
  return attributesInRect;
}

// Layout Attribute for Supplementary View (the time header and the channel header).
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:
                                                                         (NSIndexPath *)indexPath {
  UICollectionViewLayoutAttributes *attributes =
      [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind
                                                                     withIndexPath:indexPath];
  if ([kind isEqualToString:kTimeCellKind]) {
    CGFloat widthPerHalfHour = kHalfHourWidth;
    CGFloat paddingSize = kThumbnailSize * kHalfHourWidth;
    attributes.frame =
        CGRectMake(kChannelHeaderWidth + paddingSize + (widthPerHalfHour * indexPath.item), 0,
                   widthPerHalfHour, kHourHeaderHeight);
  } else if ([kind isEqualToString:kStationCellKind]) {
    NSIndexPath *channelIndex = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];

    // Find frame of the airing cell as reference.
    UICollectionViewLayoutAttributes *attr = _itemAttributes[channelIndex];
    attributes.frame =
        CGRectMake(0, attr.frame.origin.y, kChannelHeaderWidth, kChannelHeaderHeight);
  } else if ([kind isEqualToString:kTimeIndicatorKind]) {
    NSDate *timeAtFront = [_dataSource layoutStartTimeForEPG:self];
    CGFloat currentTimeMarker =
        [[timeAtFront dateByAddingTimeInterval:1080] timeIntervalSinceDate:timeAtFront] /
        (60 * 30.) * kHalfHourWidth;
    
    attributes.frame = CGRectMake(currentTimeMarker, topOfIndicator, 2, _contentSize.height);
    attributes.zIndex = [self zIndexForElementKind:kTimeIndicatorKind];
  }
  return attributes;
}

// Return z index for the type of cells.
- (CGFloat)zIndexForElementKind:(NSString *)elementKind {
  if ([elementKind isEqualToString:kTimeIndicatorKind]) {
    return 10;
  } else if ([elementKind isEqualToString:kStationCellKind]) {
    return 20;
  } else if ([elementKind isEqualToString:kTimeCellKind]) {
    return 30;
  }
  return 1;
}

#pragma mark Method for Hour Header View

// Return an array of all the index paths for the hour.
- (NSArray *)indexPathsOfHourHeaderViews {
  NSMutableArray *indexPaths = [NSMutableArray array];
  NSInteger timeCellCount = [_dataSource epgTimeArrayCountForLayout:self];
  for (NSInteger hourIndex = 0; hourIndex < timeCellCount; hourIndex++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:hourIndex inSection:0];
    [indexPaths addObject:indexPath];
  }
  return indexPaths;
}

#pragma mark Methodfor Station Column VIew

// Return index path for the stations.
- (NSArray *)indexPathsOfChannelHeaderViews {
  NSInteger minChannelIndex = 0;
  NSInteger maxChannelIndex = [_dataSource epgStationCountForLayout:self];
  NSMutableArray *indexPaths = [NSMutableArray array];
  for (NSInteger idx = minChannelIndex; idx < maxChannelIndex; idx++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
    [indexPaths addObject:indexPath];
  }
  return indexPaths;
}

#pragma mark Helper methods

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  return _itemAttributes[indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  return YES;
}

@end
