//
//  SQLManager.h
//  Popular Movies
//
//  Created by Mostafa on 3/31/19.
//  Copyright © 2019 M-M_M. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLObserver.h"
#import "SQLServiceProtocol.h"
#import <Realm.h>
#import "Movie.h"

@interface SQLManager : NSObject

+(void) clearUnFav;
+(void*) ReadFromSqlServiceName : (NSString*) serviceName serviceProtocol : (id<SQLServiceProtocol>) serviceProtocol type: (NSString*)type;
+(void) UpdateFav: (Movie*)movie favourite: (NSString*)fav serviceName: (NSString*)serviceName serviceProtocol: (id<SQLServiceProtocol>) serviceProtocol;
+(Movie*) favChecker : (Movie*) movie;
+(void) saveTrailers:(Movie*) movie Trailer:(MovieTrailers*) trailer;
+(void) saveReviews:(Movie*) movie Review:(MovieReviews*) review;
@end

