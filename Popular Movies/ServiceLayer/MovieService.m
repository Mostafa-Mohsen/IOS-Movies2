//
//  MovieService.m
//  Popular Movies
//
//  Created by Mostafa on 3/30/19.
//  Copyright © 2019 M-M_M. All rights reserved.
//

#import "MovieService.h"

@implementation MovieService

-(void)getMovies:(id<IMoviePresenter>)moviePresenter:(NSString*)dataUrl:(NSString*)type{
    self.moviePresenter = moviePresenter;
    self.type = type;
    [NetworkManager connectGetToURL:dataUrl serviceName:@"MoviesService" serviceProtocol:self];
}

-(void) getTrailers : (id<IMoviePresenter>) moviePresenter movie: (Movie*) movie{
    self.movie = movie;
    self.moviePresenter = moviePresenter;
    [NetworkManager connectGetToURL:[NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@/videos?api_key=1e90167726d4a14aa046260118a10a24",self.movie.idd] serviceName:@"TrailersService" serviceProtocol:self];
}

-(void) getReviews{
    [NetworkManager connectGetToURL:[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@/reviews?api_key=1e90167726d4a14aa046260118a10a24",self.movie.idd] serviceName:@"ReviewsService" serviceProtocol:self];
}

-(void)handleSuccessWithJSONData:(id)jsonData :(NSString *)serviceName{
    
    if ([serviceName isEqualToString:@"MoviesService"]) {
        NSDictionary *dic = (NSDictionary*)jsonData;
        NSArray *array = [dic objectForKey:@"results"];
        self.movies = [NSMutableArray new];
        for(int i = 0 ; i < array.count ; i++){
            NSDictionary *dic1 = array[i];
            Movie *movie = [Movie new];
            movie.idd = [dic1 objectForKey:@"id"];
            Movie *mv = [SQLManager favChecker:movie];
            if(mv != nil){
                [self.movies addObject:mv];
            }else{
                movie.fav = @"false";
                movie.vote_average = [dic1 objectForKey:@"vote_average"];
                movie.title = [dic1 objectForKey:@"title"];
                movie.poster_path = [dic1 objectForKey:@"poster_path"];
                movie.overview = [dic1 objectForKey:@"overview"];
                movie.release_date = [dic1 objectForKey:@"release_date"];
                movie.type = self.type;
                [self.movies addObject:movie];
            }
            
        }
        [self.moviePresenter onSuccess:self.movies];
    }
    
    else if ([serviceName isEqualToString:@"TrailersService"]) {
        NSDictionary *dic = (NSDictionary*)jsonData;
                NSArray* array = [dic objectForKey:@"results"];
                for(int i = 0 ; i < array.count ; i++){
                    NSDictionary *dic1 = array[i];
                    NSString *idd1 = [dic1 objectForKey:@"key"];
                    MovieTrailers *mt = [MovieTrailers new];
                    mt.url = idd1;
                    Movie *mv = [SQLManager favChecker:self.movie];
                    if(mv == nil){
                        [self.movie.trailers addObject:mt];
                    }else if(mv.trailers.count < array.count){
                        [SQLManager saveTrailers:mv Trailer:mt];
                    }
                }
        [self getReviews];
    }
    
    else if ([serviceName isEqualToString:@"ReviewsService"]) {
        NSDictionary *dic = (NSDictionary*)jsonData;
        NSArray* array = [dic objectForKey:@"results"];
        //        NSLog(@"%@",array);
        for(int i = 0 ; i < array.count ; i++){
            NSDictionary *dic1 = array[i];
            MovieReviews *mr = [MovieReviews new];
            mr.author = [dic1 objectForKey:@"author"];
            mr.content = [dic1 objectForKey:@"content"];
            Movie *mv = [SQLManager favChecker:self.movie];
            if(mv == nil){
                [self.movie.reviews addObject:mr];
            }else if(mv.reviews.count < array.count){
                [SQLManager saveReviews:mv Review:mr];
            }
        }
        [self.moviePresenter openMovieDetails2:self.movie];
    }
}

-(void)handleFailWithErrorMessage:(NSString *)errorMessage: (NSString*) serviceName{

    if([serviceName isEqualToString:@"ReviewsService"] || [serviceName isEqualToString:@"TrailersService"]){
         [self.moviePresenter openMovieDetails2:self.movie];
    }else{
        [self.moviePresenter onFail:errorMessage];
    }
    
    
}

-(void) handleSuccessWithSQL : (NSString*) serviceName  : (NSArray*) movies{
    if ([serviceName isEqualToString:@"MoviesSQLService"]) {
        [self.moviePresenter onSuccess:movies];
    }else if([serviceName isEqualToString:@"MoviesFavSQLService"]){
        [self.favMoviePresenter onSuccess:movies];
    }else if([serviceName isEqualToString:@"update"]){
        printf("reload at service\n");
        [self.detailMoviePresenter reloadAfterUpdate : movies[0]];
    }
}
-(void) handleSQLFailWithErrorMessage : (NSString*) serviceName : (NSString*) errorMessage{
    if ([serviceName isEqualToString:@"MoviesSQLService"]) {
        [self.moviePresenter onFail:errorMessage];
    }else if([serviceName isEqualToString:@"MoviesFavSQLService"]){
        [self.favMoviePresenter onFail:errorMessage];
    }
}

-(void)getFavMovies:(id<IFavMoviePresenter>)favMoviePresenter:(NSString*)type{
    self.favMoviePresenter = favMoviePresenter;
    self.type = type;
    if([self.type isEqualToString:@"popular"]){
        [SQLManager ReadFromSqlServiceName:@"MoviesFavSQLService" serviceProtocol:self type:@"type == 'popular' AND fav == 'true'"];
    }else if([self.type isEqualToString:@"rate"]){
        [SQLManager ReadFromSqlServiceName:@"MoviesFavSQLService" serviceProtocol:self type:@"type == 'rate' AND fav == 'true'"];
    }else if([self.type isEqualToString:@"rate AND type == 'popular'"]){
        [SQLManager ReadFromSqlServiceName:@"MoviesFavSQLService" serviceProtocol:self type:@"fav == 'true'"];
    }
}

-(void) updateMovie :(id<IDetailMoviePresenter>) detialMoviePresenter movie:(Movie*)movie fav: (NSString*) fav{
    self.detailMoviePresenter = detialMoviePresenter;
    [SQLManager UpdateFav:movie favourite:fav serviceName:@"update" serviceProtocol:self];
}

-(void)clearUnFav{
    [SQLManager clearUnFav];
}
@end
