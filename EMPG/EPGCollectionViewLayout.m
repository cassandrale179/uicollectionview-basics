#import "EPGCollectionViewLayout.h"

@implementation EPGCollectionViewLayout

// List of constants and variables
NSMutableDictionary *cellAttrDict;
CGFloat CELL_HEIGHT = 100;
CGFloat CELL_WIDTH = 200;
CGSize contentSize;
CGFloat borderPadding = 30;
CGFloat timeInterval = 30;
CGFloat currentTime = 15;
CGFloat endTime = 25;
CGFloat firstTime = 0;

// Constants for the hour header
static const NSUInteger Hours = 3;                          // display show within next 7 hours
static const CGFloat HourHeaderHeight = 40;                 // height of the header
static const CGFloat ChannelHeaderWidth = 100;

- (CGSize)collectionViewContentSize{
  return contentSize;
}


# pragma mark -------- LAYOUT METHODS -------
- (void)prepareLayout{

  // Calculating the bounds (origin x and y) of the cells
  cellAttrDict = [[NSMutableDictionary alloc] init];


  // Draw the border of where the cell starts and end
  if(self.collectionView.numberOfSections>0){

    for(int section = 0; section<self.collectionView.numberOfSections; section++){

      if([self.collectionView numberOfItemsInSection:section] > 0){
        CGFloat xPos = 0;
        for (int item = 0; item<[self.collectionView numberOfItemsInSection:section]; item++){

          // For each cell, the multiplication factor is start and end time of the movie
          NSIndexPath *cellIndex = [NSIndexPath indexPathForItem:item inSection:section];
          CGFloat yPos = section*CELL_HEIGHT+borderPadding*section;
          CGFloat multFactor = (endTime - firstTime)/timeInterval;


          // Specify the cell xPosition, yPosition, width and height
          UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          attr.frame = CGRectMake(xPos, yPos, CELL_WIDTH, CELL_HEIGHT);
          xPos += multFactor*CELL_WIDTH;
          [cellAttrDict setValue:attr forKey:cellIndex];
        }
      }


      // Return content size here (sum of all cell height and width)
      CGFloat contentWidth = [self.collectionView numberOfItemsInSection:0]*CELL_WIDTH;
      CGFloat contentHeight = [self.collectionView numberOfSections]*CELL_HEIGHT;
      contentSize = CGSizeMake(contentWidth, contentHeight);
    }
  }
}


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
  for (NSIndexPath *indexPath in hourHeaderViewIndexPaths) {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:@"HourHeaderView" atIndexPath:indexPath];
    if(CGRectIntersectsRect(rect, attributes.frame)){
      [attributesInRect addObject:attributes];

    }
//    NSLog(@"attributes for sup %@", attributes);
  }
  //NSLog(@"This is the attrinrect %@", attributesInRect);
  return attributesInRect;
}

# pragma mark ------ SUPPLEMENTARY VIEW METHODS FOR HOURS --------
- (UICollectionViewLayoutAttributes *) layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                      atIndexPath:(NSIndexPath *)indexPath{
  UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
   CGFloat totalWidth = [self collectionViewContentSize].width;
  // If it's the hour header view, draw the frame for it
  if ([kind isEqualToString:@"HourHeaderView"]) {
    CGFloat availableWidth = totalWidth - ChannelHeaderWidth;
    CGFloat widthPerHalfHour = availableWidth / Hours;
    attributes.frame = CGRectMake(ChannelHeaderWidth + (widthPerHalfHour * indexPath.item), 0, widthPerHalfHour, HourHeaderHeight);
//    attributes.zIndex = -10;
  }
  return attributes;
}

// Calculate the x coordinate of the hour
- (NSInteger)hourIndexFromXCoordinate:(CGFloat)xPosition
{
  CGFloat contentWidth = [self collectionViewContentSize].width - ChannelHeaderWidth;          // width of the entire UICollectionView
  CGFloat widthPerHalfHour = contentWidth / Hours;                                             // width for each hour cell = content / 3
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


# pragma mark ----- HELPER METHODS ------
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
  return [cellAttrDict objectForKey:indexPath];
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
  return YES;
}

@end
