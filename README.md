## Creating an Objective C Collection View Programmatically
This guide is to create an Objective C UICollectionView programmatically (without Storyboard or xib files). <br>
This is a log for future documentation purpose. 


## Table of Contents 
**1. Create an EPG object** <br>
- A. Structure of an EPG <br>
- B. Implementation of an EPG in Objective C class <br>
- C. Method to create an EPG object <br>

**2. Creating UICollectionView** <br>
- A. Create the cell for the collectionview (Emily) <br>
- B. Create the flow layout for the collection view (Emily) <br>
- C. Add the cell and flow layout to the view controller (Emily) <br>
- D. Create supplementary view for the time and station cell (Minh) <br>
- E. Add supplementary view to the view controller (Minh) <br>
- F. Create supplementary view for the time indicator line (Emily) <br> 



## Steps By Steps Instruction 
### 1. Create an EPG object 
 ##### A. Structure of an EPG object:
 An EPG is a menu is displayed that lists current and upcoming television programs on all available channels.  <br>
 The structure of an EPG will look like follow: 

    epg/
    ├── FOX                      
      ├── Airing1
        ├── start-time                      
        ├── end-time                                          
        ├── description        
        ├── title   
      ├── Airing2  
        ├── start-time                      
        ├── end-time                                           
        ├── description        
        ├── title                        
    ├── CNN    
      ├── Airing1
        ├── start-time                      
        ├── end-time                       
        ├── thumbnail                      
        ├── description        
        ├── title 
        ... 

#### B. The creationg of an EPG object (DataModel.h) files:    
   
 ```objective-c
// Each airing object is a TV show / movie 

@interface AiringRenderer : NSObject
@property (nonatomic, readwrite) NSString *airingTitle;;
@property (nonatomic, readwrite) NSDate *airingStartTime;
@property (nonatomic, readwrite) NSDate *airingEndTime;
@property (nonatomic, readwrite) NSString *airingDescription;
@end


// Each station contain an array of airings 
@interface StationRenderer : NSObject
@property (nonatomic, readwrite) NSMutableArray <AiringRenderer*> *airings;
@property (nonatomic, readwrite) NSString* stationName;
@property (nonatomic, readwrite) UIImage* stationLogo;
@end


// Each epg object contain an array of stations 
@interface EPGRenderer : NSObject
@property (nonatomic, readwrite) NSMutableArray<StationRenderer *> *stations;
@property (nonatomic, readwrite) long epgStartTime;
@property (nonatomic, readwrite) long epgEndTime;
@end
``` 

#### C. Implement a method to initialize / create an EPG object: 
We create a double for loop to fill the content of the station cell, then put each station cell within an EPG object, then fill the content of each airing renderer cell, then put it in the station renderer object. 
```objective-c
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
  .... 
  NSArray *d10 = [NSArray arrayWithObjects: @"Two And A Half Man", @"Howdie Mandel All-Star Comedy Gala", nil];


  // Create an array of stations for one epg 
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
      airing.airingEndTime = [NSDate dateWithTimeInterval:arc4random() % (to-from+1) sinceDate:airing.airingStartTime];
      [station.airings addObject:airing];
    }

    station.stationName = stationTitle[i];
    [epg.stations addObject:station];
  }
}
```


### 2. Create An UICollectionView
#### D. Create supplementary view for the time and station cell  
**1. Create cusotm time and station cell files**: <br> 
There will be 3 types of cell (the airing cell, the time cell, and the station cell) 
- For station cell (StationCell.h) and time cell (TimeCell.h) create a class and method files associated with it 
- E.g, implementation for the station cell: 
```objective-c
if (self) {
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    self.descriptionText.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.thumbnailView];
  }
  
  // Setup method 
  -(void) setup: (NSString *) titleText withDescription:(NSString *)descriptionText {
  self.layer.borderWidth = 2.0f;
  self.title.text = titleText;
  self.title.frame = CGRectMake(10, 10, self.layer.frame.size.width-(2*xPadding), 30);
}
``` 

**2. Modify the flow layout to cusotmize the cell (EPGCollectionViewLayout.m):** <br>
- Create the index path for the station / time cell (e.g in this case, we are creating 9 cells for time): 
```objective-c
- (NSArray *)indexPathsOfHourHeaderViewsInRect:(CGRect)rect
{
  NSInteger minHourIndex = 0;
  NSInteger maxHourIndex = 9;
  NSMutableArray *indexPaths = [NSMutableArray array];
  for (NSInteger idx = minHourIndex; idx <= maxHourIndex; idx++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
    [indexPaths addObject:indexPath];
  }
  return indexPaths;
}
```

- Draw the coordinate and position of each cell: <br> 
For the hour cell, we want the left boundary of the entire cell header to start after the thumbnail, so the frame will be first shift by the width of the station cell column, then the thumbnail cell size (paddingSize). The y coordinate is 0 because we want the cell header to be at the top. 

```objective-c
if ([kind isEqualToString:@"HourHeaderView"]) {
    CGFloat widthPerHalfHour = CELL_WIDTH;
    CGFloat paddingSize = ThumbnailSize*CELL_WIDTH;
    attributes.frame = CGRectMake(ChannelHeaderWidth + paddingSize + (widthPerHalfHour * indexPath.item), 0, widthPerHalfHour, HourHeaderHeight);
  }
```


- Within the method layoutAttributesForElementsInRect, create 2 supplementary views for time/station: 
```objective-c
  NSArray *hourHeaderViewIndexPaths = [self indexPathsOfHourHeaderViewsInRect:rect];
  for (NSIndexPath *indexPath in hourHeaderViewIndexPaths) {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:@"HourHeaderView" atIndexPath:indexPath];
    [attributesInRect addObject:attributes];
  }
``` 


- For station cell, we want to make it stick to the left when we are scrolling horizontally:
```objective-c
    CGPoint const contentOffset = self.collectionView.contentOffset;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
      CGPoint origin = attributes.frame.origin;
      origin.x = contentOffset.x;       // change the x-coordinate of the cell to the x-coordinnate of the view 
      attributes.zIndex = 1024;
      attributes.frame = (CGRect){
        .origin = origin,
        .size = attributes.frame.size
      };
    }
```

#### E. Add the supplementary view in the View Controller 












   
