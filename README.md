## Creating an Objective C Collection View Programmatically
This guide is to create an Objective C UICollectionView programmatically (without Storyboard or xib files). <br>
This is a log for future documentation purpose. 


### 1. Create an EPG object 
 An EPG is a menu is displayed that lists current and upcoming television programs on all available channels.  <br>
 The structure of an EPG will look like follow: 

    epg/
    ├── FOX                      
      ├── Airing1
        ├── start-time                      
        ├── end-time                       
        ├── thumbnail                      
        ├── description        
        ├── title   
      ├── Airing2  
        ├── start-time                      
        ├── end-time                       
        ├── thumbnail                      
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

The creationg of an EPG object (DataModel.h) files:    
   
 ```
@interface AiringRenderer : NSObject
@property (nonatomic, readwrite) NSString *airingTitle;;
@property (nonatomic, readwrite) NSDate *airingStartTime;
@property (nonatomic, readwrite) NSDate *airingEndTime;

@end


// For each station, create a list of airings
@interface StationRenderer : NSObject
@property (nonatomic, readwrite) NSMutableArray <AiringRenderer*> *airings;
@property (nonatomic, readwrite) NSString* stationName;
@property (nonatomic, readwrite) UIImage* networkLogo;
@end


// Create a list of stations
@interface EPGRenderer : NSObject
@property (nonatomic, readwrite) NSMutableArray<StationRenderer *> *stations;
@property (nonatomic, readwrite) long startTime;
@property (nonatomic, readwrite) long endTime;
@end
``` 
   
