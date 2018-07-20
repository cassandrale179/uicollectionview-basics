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
CGFloat firstTime = 0;//first time showing on the screen
EPGRenderer *epg;
CGFloat yPadding = 50;
Boolean needSetup = true;

- (CGSize)collectionViewContentSize{
  return contentSize;
  
}

- (void)prepareLayout{
  // calculating the bounds (origin x and y) of the cells
  if(needSetup){
    [self createEPG];
    NSLog(@"This is the new epg !%@", epg);
    needSetup = false;
  }
  
  CGFloat xMax = 0;
  cellAttrDict = [[NSMutableDictionary alloc] init];
  if(self.collectionView.numberOfSections>0){
    
    for(int section = 0; section<self.collectionView.numberOfSections; section++){
      
      if([self.collectionView numberOfItemsInSection:section] > 0){
        CGFloat xPos = 0;
        CGFloat yPos = yPadding+section*CELL_HEIGHT+borderPadding*section;
        for (int item = 0; item<[self.collectionView numberOfItemsInSection:section]; item++){
          NSIndexPath *cellIndex = [NSIndexPath indexPathForItem:item inSection:section];
          CGFloat multFactor;
          UICollectionViewLayoutAttributes *attr;
          if(item!=0){
            multFactor= [epg.stations[section].airings[item-1].airingEndTime timeIntervalSinceDate:epg.stations[section].airings[item-1].airingStartTime]/(timeInterval * 60.);
            attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          }else{
            //some random constant for the size of the thumbnail
            multFactor = 0.5;
            attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:cellIndex];
          }
          
          attr.frame = CGRectMake(xPos, yPos, multFactor*CELL_WIDTH, CELL_HEIGHT);
          //for the live epx10 video
          if(item==0){
            xPos+=CELL_WIDTH/2;
          }else{
            xPos += multFactor*CELL_WIDTH;
          }
          [cellAttrDict setValue:attr forKey:cellIndex];
        }
        xMax = MAX(xMax, xPos);
      }
      CGFloat contentWidth = xMax;
      CGFloat contentHeight = [self.collectionView numberOfSections]*(CELL_HEIGHT+borderPadding)+yPadding;
      contentSize = CGSizeMake(contentWidth, contentHeight);
      
    }
  }
}


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

- (void) createEPG{
  // Timestamp generator;
  int timestamp = [[NSDate date] timeIntervalSince1970];
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
      
      NSLocale* currentLocale = [NSLocale currentLocale];
      airing.airingStartTime = [NSDate date];
      airing.airingEndTime = [NSDate dateWithTimeInterval:(arc4random() % (to-from+1)) sinceDate:airing.airingStartTime];
      
      [station.airings addObject:airing];
    }
    
    station.stationName = stationTitle[i];
    [epg.stations addObject:station];
  }
}

@end
