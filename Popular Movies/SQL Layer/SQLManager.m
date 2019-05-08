//
//  SQLManager.m
//  Popular Movies
//
//  Created by Mostafa on 3/31/19.
//  Copyright © 2019 M-M_M. All rights reserved.
//

#import "SQLManager.h"

@implementation SQLManager

static id<SQLObserver> SQLObserverDelegate;
static NSString* classServiceName;

+(void) clearUnFav{
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [Movie objectsWhere:@"fav == 'false'"];
    if(results.count > 0){
        [realm beginWriteTransaction];
        for (Movie *movie in results){
            [realm deleteObject:movie];
        }
    [realm commitWriteTransaction];
}
    
   
}

+(void) ReadFromSqlServiceName : (NSString*) serviceName serviceProtocol : (id<SQLServiceProtocol>) serviceProtocol type: (NSString*) type{
    classServiceName = serviceName;
    SQLObserverDelegate = serviceProtocol;
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [Movie objectsWhere:type];
    [results sortedResultsUsingKeyPath:@"date" ascending:NO];
    if(results.count > 0){
        [SQLObserverDelegate handleSuccessWithSQL:classServiceName :results];
    }else{
        [SQLObserverDelegate handleSQLFailWithErrorMessage:serviceName :@"failed to load data"];
    }
}

+(void) UpdateFav: (Movie*)movie favourite: (NSString*)fav serviceName: (NSString*)serviceName serviceProtocol: (id<SQLServiceProtocol>) serviceProtocol{
    classServiceName = serviceName;
    SQLObserverDelegate = serviceProtocol;
    RLMRealm *realm =[RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    if(![self favChecker:movie] && [fav isEqualToString:@"true"]){
        movie.fav = @"true";
        movie.idd = [NSString stringWithFormat:@"%@",movie.idd];
        movie.vote_average = [NSString stringWithFormat:@"%@",movie.vote_average];
        movie.date = [NSDate date];
        [realm addObject:movie];
    }else if([fav isEqualToString:@"true"]){
        RLMResults<Movie*> *results = [Movie objectsWhere:[NSString stringWithFormat:@"idd == '%@'",movie.idd]];
        results[0].fav = @"true";
    }
    else{
        RLMResults<Movie*> *results = [Movie objectsWhere:[NSString stringWithFormat:@"idd == '%@'",movie.idd]];
        results[0].fav = @"false";
    }
    [realm commitWriteTransaction];
    RLMResults *results = [Movie objectsWhere:[NSString stringWithFormat:@"idd == '%@'",movie.idd]];
    [SQLObserverDelegate handleSuccessWithSQL:classServiceName :results];
}

+(Movie*) favChecker : (Movie*) movie{
    RLMResults<Movie*> *results = [Movie objectsWhere:[NSString stringWithFormat:@"idd == '%@'",movie.idd]];
    if(results.count > 0){
        return results[0];
    }else{
        return nil;
    }
}

+(void) saveTrailers:(Movie*) movie Trailer:(MovieTrailers*) trailer{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [movie.trailers addObject:trailer];
    [realm commitWriteTransaction];
}

+(void) saveReviews:(Movie*) movie Review:(MovieReviews*) review{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [movie.reviews addObject:review];
    [realm commitWriteTransaction];
}

@end
