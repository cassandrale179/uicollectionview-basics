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

// Display list of shows within the next 4 hours
static const NSUInteger HourPerView = 4;

- (CGSize)collectionViewContentSize{
  return contentSize;
}

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
  for(NSIndexPath *indexPath in cellAttrDict){
    UICollectionViewLayoutAttributes *attributes = [cellAttrDict objectForKey:indexPath];
    if(CGRectIntersectsRect(rect, attributes.frame)){
      [attributesInRect addObject:attributes];
    }
  }
  return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
  return [cellAttrDict objectForKey:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
  return YES;
}

@end
