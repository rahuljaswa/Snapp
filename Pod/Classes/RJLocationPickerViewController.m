//
//  RJLocationPickerViewController.m
//  Pods
//
//  Created by Rahul Jaswa on 4/5/15.
//
//

#import "RJGooglePlacesAPIClient.h"
#import "RJLocationPickerViewController.h"
#import "RJStyleManager.h"
@import CoreLocation.CLGeocoder;
@import CoreLocation.CLLocationManager;
@import CoreLocation.CLLocationManagerDelegate;
@import CoreLocation.CLPlacemark;

static NSString *const kRJLocationPickerViewControllerCellID = @"RJLocationPickerViewControllerCellID";


@interface RJLocationPickerViewController () <CLLocationManagerDelegate, UISearchBarDelegate>

@property (nonatomic, assign) CLAuthorizationStatus authStatus;
@property (nonatomic, strong, readonly) CLGeocoder *geocoder;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSString *currentLocationString;

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSString *searchString;

@end


@implementation RJLocationPickerViewController

@synthesize geocoder = _geocoder;
@synthesize locationManager = _locationManager;
@synthesize searchBar = _searchBar;

#pragma mark - Public Properties

- (void)setSelectedLocation:(CLLocation *)selectedLocation {
    if (_selectedLocation != selectedLocation) {
        _selectedLocation = selectedLocation;
        if ([self.delegate respondsToSelector:@selector(locationPickerViewControllerSelectedLocationDidChange:)]) {
            [self.delegate locationPickerViewControllerSelectedLocationDidChange:self];
        }
    }
}

- (void)setSelectedLocationString:(NSString *)selectedLocationString {
    if (_selectedLocationString != selectedLocationString) {
        _selectedLocationString = selectedLocationString;
        if (_selectedLocationString) {
            self.title = _selectedLocationString;
        } else {
            self.title = NSLocalizedString(@"Pick a location", nil);
        }
    }
}

#pragma mark - Private Properties

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = 1690.0f*2.0f;
        _locationManager.desiredAccuracy = 1690.0f*2.0f;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 44.0f)];
        _searchBar.tintColor = [[RJStyleManager sharedInstance] tintBlueColor];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

#pragma mark - Private Protocols - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.searchString = nil;
    } else {
        self.searchString = searchText;
        [[RJGooglePlacesAPIClient sharedAPIClient] getCitiesWithSearchString:self.searchString success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *cities = [responseObject objectForKey:@"predictions"];
            self.searchResults = [cities valueForKey:@"description"];
            [self.tableView reloadData];
        } failure:nil];
    }
    [self.tableView reloadData];
}

#pragma mark - Private Protocols - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    self.authStatus = status;
    if ((self.authStatus == kCLAuthorizationStatusAuthorized) ||
        (self.authStatus == kCLAuthorizationStatusAuthorizedWhenInUse))
    {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.geocoder reverseGeocodeLocation:[locations firstObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placemark = [placemarks firstObject];
            self.currentLocation = placemark.location;
            self.currentLocationString = [NSString stringWithFormat:@"%@, %@, %@", placemark.locality, placemark.administrativeArea, placemark.country];
            if (!self.selectedLocationString) {
                self.selectedLocation = self.currentLocation;
                self.selectedLocationString = self.currentLocationString;
            }
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Private Protocols - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return !!self.currentLocation;
    } else {
        return [self.searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRJLocationPickerViewControllerCellID forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.textLabel.text = self.currentLocationString;
    } else {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - Private Protocols - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.selectedLocation = self.currentLocation;
        self.selectedLocationString = self.currentLocationString;
    } else {
        NSString *addressString = [self.searchResults objectAtIndex:indexPath.row];
        self.selectedLocationString = addressString;
        [self.geocoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                CLPlacemark *placemark = [placemarks firstObject];
                self.selectedLocation = placemark.location;
            }
        }];
    }
}

#pragma mark - Public Instance Methods

- (instancetype)initWithInitiallySelectedLocation:(CLLocation *)location {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _selectedLocation = location;
        if (_selectedLocation) {
            [self.geocoder reverseGeocodeLocation:_selectedLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if (!error) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    self.selectedLocationString = [NSString stringWithFormat:@"%@, %@, %@", placemark.locality, placemark.administrativeArea, placemark.country];
                    if ([self.delegate respondsToSelector:@selector(locationPickerViewControllerSelectedLocationDidChange:)]) {
                        [self.delegate locationPickerViewControllerSelectedLocationDidChange:self];
                    }
                }
            }];
        }
        
        self.authStatus = [CLLocationManager authorizationStatus];
        if ((self.authStatus == kCLAuthorizationStatusAuthorized) ||
            (self.authStatus == kCLAuthorizationStatusAuthorizedWhenInUse))
        {
            [self.locationManager startUpdatingLocation];
        }
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.authStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_selectedLocation) {
        self.title = NSLocalizedString(@"Pick a location", nil);
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRJLocationPickerViewControllerCellID];
    self.tableView.tableHeaderView = self.searchBar;
}

@end
