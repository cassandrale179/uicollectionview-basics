#import "EPGCollectionViewLayout.h"
#import "DataModel.h"

@implementation EPGCollectionViewLayout{
// Dictionary for cell types and time array
  NSMutableDictionary *itemAttributes;
  NSMutableDictionary *channelAttributes;
  NSMutableDictionary *hourAttrDict;
  NSMutableArray *timeArray;
}

// Measurement constants
CGFloat const kCellHeight = 100;
CGFloat const kHalfHourWidth = 400;


// Constants for views
NSString *timeIndicatorKind = @"TimeIndicatorView";
NSString *timeCellKind = @"HourHeaderView";
NSString *stationCellKind = @"ChannelHeaderView";

// Constants for supplementary view
static const CGFloat kHourHeaderHeight = 40;      // height of each time cell
static const CGFloat kChannelHeaderHeight = 100;  // height of each channel cell
static const CGFloat kChannelHeaderWidth = 100;   // width of each channel cell
static const CGFloat kThumbnailSize = 0.5;        // size of the video thumbnail
static const CGFloat topOfIndicator = 20;         // space between screen and tip of time indicator

// Other attributes
EPGRenderer *epg;
CGSize contentSize;
Boolean needSetup = true;


#pragma mark Prepare Layout Method
// Return content size.
- (CGSize)collectionViewContentSize {
  return contentSize;
}

- (void)prepareLayout {
  // Calculate the bounds (origin x and y) of the cells.
  if (needSetup) {
    epg = [DataModel createEPG];
    timeArray = [DataModel calculateEPGTime:epg timeInterval:kAiringIntervalMinutes];
    needSetup = false;
  }
  // Create attributes for the Hour Header.
  NSArray *hourHeaderViewIndexPaths = [self indexPathsOfHourHeaderViews];
  hourAttrDict = [[NSMutableDictionary alloc] init];
  for (NSIndexPath *indexPath in hourHeaderViewIndexPaths) {
    UICollectionViewLayoutAttributes *attributes =
        [self layoutAttributesForSupplementaryViewOfKind:timeCellKind atIndexPath:indexPath];

    // Make the hour header pin to the top when scrolling vertically.
    CGFloat yOffSet = self.collectionView.contentOffset.y;
    CGPoint origin = attributes.frame.origin;
    origin.y = yOffSet;
    attributes.frame = (CGRect){.origin = origin, .size = attributes.frame.size};
    attributes.zIndex = [self zIndexForElementKind:timeCellKind];
    [hourAttrDict setValue:attributes forKey:indexPath];
  }
  CGFloat xMax = 0;
  itemAttributes = [[NSMutableDictionary alloc] init];
  if (self.collectionView.numberOfSections > 0) {
    for (int section = 0; section < self.collectionView.numberOfSections; section++) {
      if ([self.collectionView numberOfItemsInSection:section] > 0) {
        CGFloat xPos = kChannelHeaderWidth;
        CGFloat yPos = kVerticalPadding + section * kCellHeight + kBorderPadding * section;
        CGFloat numHalfHourIntervals;

        // Calculate the frame of each airing.
        for (int item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
          NSIndexPath *cellIndex = [NSIndexPath indexPathForItem:item inSection:section];
          
          UICollectionViewLayoutAttributes *attr;

          // If the cell is not a thumbnail
          if (item != 0) {
            
            // Subtract 1 to account for the thumbnail cell at item index 0.
            AiringRenderer *currentAiring = epg.stations[section].airings[item - 1];
            NSDate *closerStartTime = [timeArray objectAtIndex:0];
            if ([closerStartTime earlierDate:currentAiring.airingStartTime]){
              closerStartTime = currentAiring.airingStartTime;
            }
            NSInteger closestTimeIndex =[timeArray indexOfObject:currentAiring.airingStartTime inSortedRange:NSMakeRange(0, timeArray.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(NSDate *time1, NSDate *time2){
              return [time1 compare:time2];
            }]-1;
            UICollectionViewLayoutAttributes *hourAttributes = [hourAttrDict objectForKey:[NSIndexPath indexPathForItem:closestTimeIndex inSection:0]];
            xPos = [closerStartTime timeIntervalSinceDate:[timeArray objectAtIndex:closestTimeIndex]] /
            (kAiringIntervalMinutes * 60.)*kHalfHourWidth + hourAttributes.frame.origin.x;
            numHalfHourIntervals =
                [currentAiring.airingEndTime
                    timeIntervalSinceDate:closerStartTime] /
                (kAiringIntervalMinutes * 60.);
            attr =
                [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          } else {
            // Set thumbnail size.
            numHalfHourIntervals = kThumbnailSize;
            attr =
                [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          }
          attr.frame = CGRectMake(xPos, yPos, numHalfHourIntervals * kHalfHourWidth, kCellHeight);
          xPos += numHalfHourIntervals * kHalfHourWidth;
          [itemAttributes setValue:attr forKey:cellIndex];
        }
        xMax = MAX(xMax, xPos+numHalfHourIntervals * kHalfHourWidth);
      }

      // Return total content size of all cells within it.
      CGFloat contentWidth = xMax;
      CGFloat contentHeight =
          [self.collectionView numberOfSections] * (kCellHeight + kBorderPadding) + kVerticalPadding;
      contentSize = CGSizeMake(contentWidth, contentHeight);
    }
  }

  // Create attributes for the Channel Header.
  NSArray *channelHeaderIndexPaths = [self indexPathsOfChannelHeaderViews];
  channelAttributes = [[NSMutableDictionary alloc] init];
  for (NSIndexPath *indexPath in channelHeaderIndexPaths) {
    UICollectionViewLayoutAttributes *attributes =
        [self layoutAttributesForSupplementaryViewOfKind:stationCellKind
                                             atIndexPath:indexPath];

    // Make the network header pin to the left when scrolling horizontally.
    CGFloat xOffset = self.collectionView.contentOffset.x;
    CGPoint origin = attributes.frame.origin;
    origin.x = xOffset;
    attributes.zIndex = [self zIndexForElementKind:stationCellKind];

    // Getting attributes of the airing cells to vertically align the channel and airing cells.
    UICollectionViewLayoutAttributes *cellattr =
        [itemAttributes objectForKey:[NSIndexPath indexPathForItem:0 inSection:indexPath.section]];
    attributes.frame = CGRectMake(xOffset, cellattr.frame.origin.y, kChannelHeaderWidth, kChannelHeaderHeight);
    [channelAttributes setValue:attributes forKey:indexPath];
  }

  
}

#pragma mark Layout Attribute for Element in Rect and Supplementary View
// Return the frame for each cell (333.333 0; 200 100).
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *attributesInRect = [[NSMutableArray alloc] init];

  // Add all the attributes to attributesInRect (the entire view).
  for (NSIndexPath *indexPath in itemAttributes) {
    UICollectionViewLayoutAttributes *attributes = [itemAttributes objectForKey:indexPath];
    if (CGRectIntersectsRect(rect, attributes.frame)) {
      [attributesInRect addObject:attributes];
    }
  }
  for (NSIndexPath *indexPath in channelAttributes) {
    UICollectionViewLayoutAttributes *attributes = [channelAttributes objectForKey:indexPath];
    if (CGRectIntersectsRect(rect, attributes.frame)) {
      [attributesInRect addObject:attributes];
    }
  }
  for (NSIndexPath *indexPath in hourAttrDict) {
    UICollectionViewLayoutAttributes *attributes = [hourAttrDict objectForKey:indexPath];
    if (CGRectIntersectsRect(rect, attributes.frame)) {
      [attributesInRect addObject:attributes];
    }
  }

  // Supplementary view for time indicator cell.
  UICollectionViewLayoutAttributes *attributes = [self
      layoutAttributesForSupplementaryViewOfKind:@"TimeIndicatorView"
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
  if ([kind isEqualToString:timeCellKind]) {
    CGFloat widthPerHalfHour = kHalfHourWidth;
    CGFloat paddingSize = kThumbnailSize * kHalfHourWidth;
    attributes.frame =
        CGRectMake(kChannelHeaderWidth + paddingSize + (widthPerHalfHour * indexPath.item), 0,
                   widthPerHalfHour, kHourHeaderHeight);
  } else if ([kind isEqualToString:stationCellKind]) {
    NSIndexPath *channelIndex = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];

    // Find frame of the airing cell as reference.
    UICollectionViewLayoutAttributes *attr = [itemAttributes objectForKey:channelIndex];
    attributes.frame = CGRectMake(0, attr.frame.origin.y, kChannelHeaderWidth, kChannelHeaderHeight);
  } else if ([kind isEqualToString:timeIndicatorKind]) {
    NSDate *timeAtFront = [timeArray objectAtIndex:0]; 
    CGFloat currentTimeMarker =
        [[timeAtFront dateByAddingTimeInterval:1080] timeIntervalSinceDate:timeAtFront] /
        (60 * 30.) * kHalfHourWidth;
    attributes.frame = CGRectMake(currentTimeMarker, topOfIndicator, 2, contentSize.height);
    attributes.zIndex = [self zIndexForElementKind:timeIndicatorKind];
  }
  return attributes;
}

- (CGFloat)zIndexForElementKind:(NSString *)elementKind{
  if ([elementKind isEqualToString:timeIndicatorKind]){
    return 10;
  }else if([elementKind isEqualToString:stationCellKind]){
    return 20;
  }else if([elementKind isEqualToString:timeCellKind]){
    return 30;
  }
  return 1;
}

#pragma mark Method for Hour Header View
// Return an array of all the index paths for the hour.
- (NSArray *)indexPathsOfHourHeaderViews {
  NSMutableArray *indexPaths = [NSMutableArray array];
  for (NSInteger hourIndex = 0; hourIndex <= [timeArray count]; hourIndex++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:hourIndex inSection:0];
    [indexPaths addObject:indexPath];
  }
  return indexPaths;
}

#pragma mark Methodfor Station Column VIew
// Calculate the Y Coordinate of each channel.
- (NSInteger)channelIndexFromYCoordinate:(CGFloat)yPosition {
  return epg.stations.count;
}

// Return index path for the stations.
- (NSArray *)indexPathsOfChannelHeaderViews {
  NSInteger minChannelIndex = 0;
  NSInteger maxChannelIndex = epg.stations.count - 1;
  NSMutableArray *indexPaths = [NSMutableArray array];
  for (NSInteger idx = minChannelIndex; idx <= maxChannelIndex; idx++) {
    // changed rev indexpath and section.
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
    [indexPaths addObject:indexPath];
  }
  return indexPaths;
}

#pragma mark Helper methods
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [itemAttributes objectForKey:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  return YES;
}

@end
