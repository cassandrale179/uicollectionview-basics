#import "EPGCollectionViewLayout.h"
#import "DataModel.h"

@implementation EPGCollectionViewLayout
NSMutableDictionary *cellAttrDict;
CGFloat CELL_HEIGHT = 100;
CGFloat CELL_WIDTH = 400;
CGSize contentSize;
CGFloat borderPadding = 30;
CGFloat timeInterval = 30;
CGFloat currentTime = 15;
CGFloat endTime = 25;
CGFloat firstTime = 0;                                          //first time showing on the screen
EPGRenderer *epg;
CGFloat yPadding = 50;
Boolean needSetup = true;
NSString *timeIndicatorKind = @"TimeIndicatorView";

// Constants
static const NSUInteger HalfHours = 3;                          // display show within next 3 half-hour
static const NSUInteger StationsPerColumn = 10;                 // list of stations to display
static const CGFloat HourHeaderHeight = 40;                     // height of each time cell
static const CGFloat ChannelHeaderHeight = 100;                 // height of each channel cell
static const CGFloat ChannelHeaderWidth = 100;                  // width of each channel cell
static const CGFloat ThumbnailSize = 0.5;                       // size of the video thumbnail



// Return content size here
- (CGSize)collectionViewContentSize{
  return contentSize;
}


# pragma mark -------- LAYOUT METHODS -------
- (void)prepareLayout{
  // Calculating the bounds (origin x and y) of the cells
  if(needSetup){
    [self createEPG];
    needSetup = false;
  }

  CGFloat xMax = 0;
  cellAttrDict = [[NSMutableDictionary alloc] init];
  if(self.collectionView.numberOfSections>0){

    for(int section = 0; section<self.collectionView.numberOfSections; section++){
      if([self.collectionView numberOfItemsInSection:section] > 0){
        CGFloat xPos = ChannelHeaderWidth;
        CGFloat yPos = yPadding+section*CELL_HEIGHT+borderPadding*section;

        // Calculate the frame of each airing
        for (int item = 0; item<[self.collectionView numberOfItemsInSection:section]; item++){
          NSIndexPath *cellIndex = [NSIndexPath indexPathForItem:item inSection:section];
          CGFloat multFactor;
          UICollectionViewLayoutAttributes *attr;

          // If the cell is not a thumbnail
          if(item!=0){
            multFactor= [epg.stations[section].airings[item-1].airingEndTime timeIntervalSinceDate:epg.stations[section].airings[item-1].airingStartTime]/(timeInterval * 60.);
            attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          }else{
            //some random constant for the size of the thumbnail
            multFactor = ThumbnailSize;
            attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          }

          attr.frame = CGRectMake(xPos, yPos, multFactor*CELL_WIDTH, CELL_HEIGHT);
          xPos += multFactor*CELL_WIDTH;
          [cellAttrDict setValue:attr forKey:cellIndex];
        }
        xMax = MAX(xMax, xPos);
      }

      // Return total content size of all cells within it
      CGFloat contentWidth = xMax;
      CGFloat contentHeight = [self.collectionView numberOfSections]*(CELL_HEIGHT+borderPadding)+yPadding;
      contentSize = CGSizeMake(contentWidth, contentHeight);

    }
  }
}


# pragma mark ------ LAYOUT ATTRRIBUTE FOR ELEMENT IN RECT AND SUPPLEMENTARY VIEW --------
// Return the frame for each cell (333.333 0; 200 100)
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{

  NSMutableArray *attributesInRect = [[NSMutableArray alloc] init];

  // Array for normal airing cells
  for(NSIndexPath *indexPath in cellAttrDict){
    UICollectionViewLayoutAttributes *attributes = [cellAttrDict objectForKey:indexPath];
    if(CGRectIntersectsRect(rect, attributes.frame)){
      [attributesInRect addObject:attributes];
    }
  }


  // Supplementary view for the header of the hours (9:00 PM - 10:00 PM)
  NSArray *hourHeaderViewIndexPaths = [self indexPathsOfHourHeaderViewsInRect:rect];
  //NSLog(@"array count for hour %ld", [hourHeaderViewIndexPaths count]);
  for (NSIndexPath *indexPath in hourHeaderViewIndexPaths) {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:@"HourHeaderView" atIndexPath:indexPath];
    [attributesInRect addObject:attributes];
  }
  

  // Suplementary view for the station header of all the networks (Fox, CNN, ...etc.)
  NSArray *channelHeaderIndexPaths = [self indexPathsOfChannelHeaderViewsInRect:rect];
  //NSLog(@"array count for channel %ld", [channelHeaderIndexPaths count]);
  for (NSIndexPath *indexPath in channelHeaderIndexPaths) {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:@"ChannelHeaderView" atIndexPath:indexPath];
    // Make the network header scrolling pin to the left when scrolling horizontally
    CGPoint const contentOffset = self.collectionView.contentOffset;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
      CGPoint origin = attributes.frame.origin;
      origin.x = contentOffset.x;
      attributes.zIndex = 1024;
      attributes.frame = (CGRect){
        .origin = origin,
        .size = attributes.frame.size
      };
    }
    NSLog(@"For the index %@ the attr is %@", indexPath, attributesInRect);
    [attributesInRect addObject:attributes];
  }
  
   //Supplementary view for time indicator cell
  UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:@"TimeIndicatorView" atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
  [attributesInRect addObject:attributes];

  return attributesInRect;
}


// Layout Attribute for Supplementary View (the time header and the channel header)
- (UICollectionViewLayoutAttributes *) layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                      atIndexPath:(NSIndexPath *)indexPath{
  UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
  CGFloat totalWidth = [self collectionViewContentSize].width;

  // If it's the hour header view 
  if ([kind isEqualToString:@"HourHeaderView"]) {
    CGFloat availableWidth = totalWidth - ChannelHeaderWidth;
    CGFloat widthPerHalfHour = availableWidth / HalfHours;
    attributes.frame = CGRectMake(ChannelHeaderWidth + (widthPerHalfHour * indexPath.item), 0, widthPerHalfHour, HourHeaderHeight);
  }
   // If it's the station header view                                                                      
   else if ([kind isEqualToString:@"ChannelHeaderView"]) {
     NSIndexPath *channelIndex = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
     //Finding frame of the airing cell as reference.
     UICollectionViewLayoutAttributes *attr = [cellAttrDict objectForKey:channelIndex];
     //NSLog(@"getting the attr for %@ ", attr);
    attributes.frame = CGRectMake(0, attr.frame.origin.y, ChannelHeaderWidth, ChannelHeaderHeight);
  } 
 // If it's the time indicator view  
 else if([kind isEqualToString:timeIndicatorKind]){
    CGFloat cellStandardWidth = 400;
    NSDate *timeAtFront = [NSDate date];
    CGFloat currentTimeMarker = [[timeAtFront dateByAddingTimeInterval:1080] timeIntervalSinceDate:timeAtFront]/(60*30.)*cellStandardWidth;
    CGFloat topOfIndicator = 20;
    attributes.frame = CGRectMake(currentTimeMarker, topOfIndicator, 2, contentSize.height);
  }
  return attributes;
}

# pragma mark ------ SUPPLEMENTARY VIEW METHODS FOR HOURS --------
// Calculate the x coordinate of the hour
- (NSInteger)hourIndexFromXCoordinate:(CGFloat)xPosition
{
  CGFloat contentWidth = [self collectionViewContentSize].width - ChannelHeaderWidth;          // width of the entire UICollectionView
  CGFloat widthPerHalfHour = contentWidth / HalfHours;                                         // width for each hour cell = content / 3
  NSInteger hourIndex = MAX((NSInteger)0, (NSInteger)((xPosition - ChannelHeaderWidth) / widthPerHalfHour));
  return hourIndex;
}


// Return an array of all the index paths for the hour
- (NSArray *)indexPathsOfHourHeaderViewsInRect:(CGRect)rect
{
  if (CGRectGetMinY(rect) > HourHeaderHeight) {
    return [NSArray array];
  }
  NSInteger minHourIndex = [self hourIndexFromXCoordinate:CGRectGetMinX(rect)];
  NSInteger maxHourIndex = [self hourIndexFromXCoordinate:CGRectGetMaxX(rect)];
  NSMutableArray *indexPaths = [NSMutableArray array];
  for (NSInteger idx = minHourIndex; idx <= maxHourIndex; idx++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
    [indexPaths addObject:indexPath];
  }
  return indexPaths;
}

# pragma mark ------ SUPPLEMENTARY VIEW METHODS FOR CHANNELS --------
// Calculate the Y Coordinate of each channel
- (NSInteger) channelIndexFromYCoordinate:(CGFloat)yPosition{
  //changing the way this is calculated to be from the actual number of channels
//  NSInteger stationIndex = MAX((NSInteger)0, (NSInteger)(yPosition - HourHeaderHeight) / ChannelHeaderHeight);
//  NSLog(@"stationindex %ld", stationIndex);
  return epg.stations.count;
}


// Return index path for the stations
- (NSArray *)indexPathsOfChannelHeaderViewsInRect:(CGRect)rect
{
  if (CGRectGetMinX(rect) > ChannelHeaderWidth) {
    return [NSArray array];
  }

  NSInteger minChannelIndex = 0;
  NSInteger maxChannelIndex = [self channelIndexFromYCoordinate:CGRectGetMaxY(rect)]-1;
  NSMutableArray *indexPaths = [NSMutableArray array];
  for (NSInteger idx = minChannelIndex; idx <= maxChannelIndex; idx++) {
    //changed rev indexpath and section
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
    [indexPaths addObject:indexPath];
  }
  return indexPaths;
}


# pragma mark ----- HELPER METHODS ------
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
  return [cellAttrDict objectForKey:indexPath];
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
  return YES;
}

- (void) createEPG{
  // Timestamp generator;
  int from = 900;
  int to = 7200;

  // Create a list of stations
  epg = [[EPGRenderer alloc]init];
  epg.stations = [[NSMutableArray alloc] init];
  NSArray *stationTitle = [NSArray arrayWithObjects: @"fox", @"kpix5", @"abc7", @"nbc11", @"thecw", @"food", @"hgtv", @"showtime", @"premiere", @"disney",nil];

  // Create arrays to fill out information
  NSArray *d1 = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *d2 = [NSArray arrayWithObjects: @"East TN South vs Furman", @"Postgame", @"The Late Show with Stephen Colbert", nil];
  NSArray *d3 = [NSArray arrayWithObjects: @"The Gong Show", @"Battle of Network Stars", nil];
  NSArray *d4 = [NSArray arrayWithObjects: @"I Want A Dog For Christmas, Charlie Brown", nil];
  NSArray *d5 = [NSArray arrayWithObjects: @"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];
  NSArray *d6 = [NSArray arrayWithObjects: @"New Girl", @"The Mick", @"Big Bang Theory", nil];
  NSArray *d7 = [NSArray arrayWithObjects: @"East TN South vs Furman", @"Postgame", @"The Late Show with Stephen Colbert", nil];
  NSArray *d8 = [NSArray arrayWithObjects: @"The Gong Show", @"Battle of Network Stars", nil];
  NSArray *d9 = [NSArray arrayWithObjects: @"I Want A Dog For Christmas, Charlie Brown", nil];
  NSArray *d10 = [NSArray arrayWithObjects: @"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];

  // Create a nested array to hold all information
  NSArray *allTitles = [NSArray arrayWithObjects: d1, d2, d3, d4, d5,d6, d7, d8, d9, d10, nil];


  // Create an array of stations for one epg s
  for (int i = 0; i < [stationTitle count]; i++){

    StationRenderer *station = [[StationRenderer alloc] init];
    station.airings = [[NSMutableArray alloc] init];

    // Create dummy variables for now
    NSArray *dummyTitle = allTitles[i];

    // Create an array of airings for each station
    for (int j = 0; j < [dummyTitle count]; j++){
      AiringRenderer *airing = [[AiringRenderer alloc] init];
      airing.airingTitle = dummyTitle[j];
      airing.airingStartTime = [NSDate date];
      airing.airingEndTime = [NSDate dateWithTimeInterval:(arc4random() % (to-from+1)) sinceDate:airing.airingStartTime];

      [station.airings addObject:airing];
    }

    station.stationName = stationTitle[i];
    [epg.stations addObject:station];
  }
}

@end
