//
//  MoviePresenter.m
//  Popular Movies
//
//  Created by Mostafa on 3/30/19.
//  Copyright © 2019 M-M_M. All rights reserved.
//

#import "MoviePresenter.h"

@implementation MoviePresenter{
    Boolean state;
    int pagesPop;
    int pagesRate;
    id<IBaseDetailView> movieViewDetails;
    MovieService *movieService;
    NSString *type;
}

-(instancetype)initWithMoviewView : (id<IMovieView>) movieView{
    self = [super init];
    if(self){
        self.movieView = movieView;
        movieService = [MovieService new];
        pagesPop = 1;
        pagesRate = 1;
    };
    return self;
}

-(void) getPopularMovies :(Boolean)reset{
    [self.movieView showLoading];
    state = true;
    if(reset){
        pagesPop = 1;
    }
    [movieService getMovies:self:[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/popular?page=%d&api_key=1e90167726d4a14aa046260118a10a24",pagesPop]:@"popular"];
    type = @"popular";
}

-(void) getRatingMovies :(Boolean)reset{
    [self.movieView showLoading];
    state = true;
    if(reset){
        pagesRate = 1;
    }
    [movieService getMovies:self:[NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/top_rated?page=1%d&api_key=1e90167726d4a14aa046260118a10a24&language=en-US",pagesRate]:@"rate"];
    type = @"rate";
}

-(void) onSuccess : (NSMutableArray*) movies{
    [self.movieView renderMoviesWithObjects:movies];
    [self.movieView hideLoading];
    state = false;
    if([type isEqualToString:@"popular"]){
        pagesPop++;
        pagesRate = 1;
    }else if([type isEqualToString:@"rate"]){
        pagesRate++;
        pagesPop = 1;
    }
}
-(void)onFail : (NSString*) errorMessage{
    [self.movieView showErrorMessage:errorMessage];
    [self.movieView hideLoading];
    state = false;
}
-(void)menuPop{
    if(!state){
        [self.movieView createPopMenu];
    }else{
        [self.movieView changeLoader];
    }
}
-(void) openMovieDetails: (Movie*)movie movieView: (id<IBaseDetailView>)movieView{
    movieViewDetails = movieView;
    [movieService getTrailers:self movie:movie];
}

-(void) openMovieDetails2 : (Movie*)movie{
    MovieDetailPresenter *movieDetailPresenter = [[MovieDetailPresenter alloc] initWithDetailPresenter:movie:movieViewDetails];
    [self.movieView openDetails:movieDetailPresenter];
}


-(void) updateList: (NSInteger) row title: (NSString*)title{
    if([title isEqualToString:@"Popular Movies"] && row == (((pagesPop-1) * 20) - 2)){
        [self getPopularMovies:false];
    }else if([title isEqualToString:@"High Rating Movies"] && row == (((pagesRate-1) * 20) - 2)){
        [self getRatingMovies:false];
    }
}

-(void) clearUnFav{
    [movieService clearUnFav];
}

@end
