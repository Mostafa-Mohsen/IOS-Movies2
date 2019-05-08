//
//  MovieDetailPresenter.m
//  Popular Movies
//
//  Created by Mostafa on 4/5/19.
//  Copyright © 2019 M-M_M. All rights reserved.
//

#import "MovieDetailPresenter.h"
#import "MovieService.h"

@implementation MovieDetailPresenter{
    UIButton* heartBtnImg;
}

-(instancetype)initWithDetailPresenter : (Movie*)movie : (id<IBaseDetailView>) movieView{
    self = [super init];
    if(self){
        self.movie = movie;
        self.movieView = movieView;
    };
    return self;
}

-(Movie*) getMovie{
    return self.movie;
}

-(void) openTrailer : (int) trailer{
    MovieTrailers *mt = self.movie.trailers[trailer];
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",mt.url]];
    [self.movieView opeTrailerPage:url];
}

-(void) updateState : (Movie*) movie{
    MovieService *movieService = [MovieService new];
    if([movie.fav isEqualToString:@"true"]){
        [movieService updateMovie:self movie:movie fav:@"false"];
    }else{
        [movieService updateMovie:self movie:movie fav:@"true"];
    }
}

-(void) reloadAfterUpdate : (Movie*) movie{
    printf("reload at presenter\n");
    [self.movieView updateFavState:movie :heartBtnImg];
}

-(void) getBtn : (UIButton*) heartButton{
    heartBtnImg = heartButton;
}

@end
