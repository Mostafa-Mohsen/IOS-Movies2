//
//  CollectionViewController.m
//  Popular Movies
//
//  Created by Mostafa on 3/30/19.
//  Copyright © 2019 M-M_M. All rights reserved.
//

#import "CollectionViewController.h"

@interface CollectionViewController (){
    DetailsTableViewController *DTVC;
}

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Popular Movies";
    self.urls = [NSMutableArray new];
    self.moviePresenter = [[MoviePresenter alloc] initWithMoviewView:self];
    [self.moviePresenter clearUnFav];
    [self.moviePresenter getPopularMovies:true];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return self.urls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(self.urls.count > 0){
        Movie *movie = self.urls[indexPath.row];
        NSMutableString *link = [[NSMutableString alloc]initWithString:@"http://image.tmdb.org/t/p/w185/"];
        [link appendString:movie.poster_path];
        UIImageView *imageV = (UIImageView*)[cell viewWithTag:1];
        NSURL *url = [[NSURL alloc] initWithString:link];
        [cell setAutoresizesSubviews:YES];
        [imageV sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"images.png"]];
    }
    [self.moviePresenter updateList:indexPath.row title:self.title];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat devWidth;
    CGSize size;
    if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        devWidth = self.view.bounds.size.width;
        size = CGSizeMake((devWidth/3),210.0);
    }else{
        devWidth = self.view.frame.size.width;
        size = CGSizeMake((devWidth/2),190.0);
    }
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DTVC"];
    [self.moviePresenter openMovieDetails:self.urls[indexPath.row] movieView:DTVC];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

-(void) renderMoviesWithObjects : (NSMutableArray*) movies{
    for(int i=0 ; i < movies.count ; i++){
        [self.urls addObject:movies[i]];
    }
    [self.collectionView reloadData];
}

-(void) showLoading{
    [self.collectionView reloadData];
    printf("show Loading\n");
}

-(void) hideLoading{
    printf("hide Loading\n");
}
-(void) showErrorMessage : (NSString*) errorMessage{
    printf("Show Error\n");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error !" message:@"Please check your network connection" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)menuBtn:(id)sender {
    [self.moviePresenter menuPop];
}

-(void) createPopMenu{
    [FTPopOverMenu showFromSenderFrame:CGRectMake(self.view.frame.size.width - 47, 20, 40, 40) withMenuArray:@[@"Popular",@"Rating"] doneBlock:^(NSInteger selectedIndex) {
        switch (selectedIndex) {
            case 0:{
                self.title = @"Popular Movies";
                [self.urls removeAllObjects];
                [self.moviePresenter getPopularMovies:true];
            }
                break;
            case 1:{
                self.title = @"High Rating Movies";
                [self.urls removeAllObjects];
                [self.moviePresenter getRatingMovies:true];
            }
                break;
            default:
                break;
        }
    } dismissBlock:^(){
        
    }];
}

-(void)changeLoader{
   //do nothing
}
-(void) openDetails : (MovieDetailPresenter*) movieDetailPresenter{
        DTVC.moviedetailPresenter = movieDetailPresenter;
        [DTVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:DTVC animated:YES];
}

@end
