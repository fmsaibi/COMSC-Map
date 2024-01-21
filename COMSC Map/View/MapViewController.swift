//
//  MapViewController.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 13/07/2023.
//

import UIKit
import MapboxMaps
import CoreLocation
import NMAKit
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation
import MapKit


protocol SearchResultDelegate {
    
    func searchViewDidSelectResult(_ result: NMAPlaceLink )
}


class MapViewController: UIViewController {
    
    @IBOutlet weak var directionAlert: UIImageView!
    @IBOutlet weak var informationView:UIView!
    @IBOutlet weak var informationLable:UILabel!
    @IBOutlet weak var addressLable:UILabel!
    @IBOutlet weak var showRouteBtn:UIButton!
    @IBOutlet var navigationMapView: NavigationMapView!
    @IBOutlet weak var postionBtn: UIButton!
    @IBOutlet weak var mapSchemeBtn: UIButton!
    let alertImageView = UIImageView()// Create a UIImageView and set the image
    var postionBtnEnable: Bool?
    var location: CLLocation?
    var configuration: UserConfiguration!
    var mainView: UIView!
    var searchController:UISearchController!
    var mapView:MapView!
    var destination:CLLocationCoordinate2D!
    var geoJSONObject: [MKGeoJSONObject]!
    

    

    var currentRouteIndex = 0 {
        didSet {
            showCurrentRoute()
        }
    }
    
    
    var currentRoute: Route? {
        return routes?[currentRouteIndex]
    }
    
    var routes: [Route]? {
        return routeResponse?.routes
    }
    
    var routeResponse: RouteResponse? {
        didSet {
            guard currentRoute != nil else {
                navigationMapView.removeRoutes()
            
                return
            }
            currentRouteIndex = 0
        }
    }
    
    func showCurrentRoute() {
        guard let currentRoute = currentRoute else { return }
        
        var routes = [currentRoute]
        routes.append(contentsOf: self.routes!.filter {
            $0 != currentRoute
        })
        navigationMapView.showcase(routes)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureLocationServices()
        configureMapView()
        configureSearchBox()
  
    }
    

    
    
    @IBAction func showRouteBtnClicked(_ sender: Any) {
        
        

        guard let btn = sender as? UIButton, let label = btn.titleLabel else { return }
        
        
        if label.text == "Show Route" {
            
            btn.setTitle("Start Navigation", for: .normal)
                        
            UIView.animate(withDuration: 1.0, animations: {
                       // Change properties you want to animate
                self.requestRoute(destination: self.destination)
            })
    
        }
        
        if label.text == "Start Navigation" {
            
            startNavigation()
            
        }
        
    }
    
    
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        
        informationLable.text = nil
        addressLable.text = nil
        showRouteBtn.setTitle("Show Route", for: .normal)
        informationView.isHidden = true
        postionBtn.isHidden = false
        mapSchemeBtn.isHidden = false
        
//        navigationMapView.removeRoutes()
        MarkerManager.share.removePlaceAnnotations(on: mapView)
        
    
    }
    
    
    
    @IBAction func positionActionBtn(_ sender: Any) {
                

        if postionBtnEnable != false {
            
            changPostionButtonApperance(buttom: postionBtn, with: POINTER_LIGHT, notification: false)
            
        } else {
            
            changPostionButtonApperance(buttom: postionBtn, with: POINTER_LIGHT_FILL, notification: true)

        }

    }
    
    
    func setImageconstraints() {
        
        // Create a UIImageView and set the image
        let imageView = UIImageView(image: UIImage(named: ""))
        imageView.contentMode = .scaleAspectFit
        
        // Disable autoresizing mask so that constraints work
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints
        NSLayoutConstraint.activate([
            // Left constraint
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
            
            // Right constraint
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
            
            // Top constraint
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            // Aspect ratio constraint (17:10)
            imageView.heightAnchor.constraint(equalTo: directionAlert.widthAnchor, multiplier: 10.0 / 17.0)
        ])
        
    }
    
    
    func changPostionButtonApperance(buttom: UIButton, with image:String, notification: Bool) {
        
        if let image = UIImage(named: image) {
            
            buttom.setImage(image, for: .normal)
            
            postionBtnEnable = notification
            
        }
    }
}
    
//Mark:- Buttons
extension MapViewController {
    func configureLocationServices(){
        //Ask the user access to location services of device
        LocationServices.shared.delegate = self
    }
    
    func configureMapView(){
        print("Map configure")
        //
        navigationMapView.delegate = self
        //Initinating mapView
        mapView = navigationMapView.mapView
        //Remove InfoButtonOrnament - About this map Button
        mapView.ornaments.attributionButton.isHidden = true
        //Enable gestures
        mapView.gestures.delegate = self
        //Setup Map view in 2D postion
        mapView.location.options.puckType = .puck2D()
        //Show Compass View
        mapView.ornaments.options.compass.visibility = .visible
        //Hide Scale Bar
        mapView.ornaments.options.scaleBar.visibility = .visible

        if location != nil {
            //Show user Location
            mapView.location.options.puckBearingEnabled = true
            //Enabling Postion Button
            postionBtnEnable = true
        }
    }
    

}


//MArk:- Gesture
extension MapViewController: GestureManagerDelegate{
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didBegin gestureType: MapboxMaps.GestureType) {
        

        changPostionButtonApperance(buttom: postionBtn, with: POINTER_LIGHT, notification: false)
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEnd gestureType: MapboxMaps.GestureType, willAnimate: Bool) {
    }
    
    func gestureManager(_ gestureManager: MapboxMaps.GestureManager, didEndAnimatingFor gestureType: MapboxMaps.GestureType) {
    }
    
}


//MArk:- Location Services
extension MapViewController: LocationServicesDelegate {
    
    func didUpdateLocation(_ location: CLLocation) {
        
        if postionBtnEnable != false {
            
            self.mapView.mapboxMap.setCamera(to: CameraOptions(center: location.coordinate, zoom: 15.0))
            
        }
    }
}

//MArk:- Search Bar
extension MapViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        if let controller  = searchController.searchResultsController as? SearchViewController {
            
            guard
                let text = searchController.searchBar.text
            else {
                controller.cachedSuggestions = []

                controller.reloadData()
                return
            }
            
            
            let coordinate = mapView.location.latestLocation?.coordinate
            
            guard let lat = coordinate?.latitude, let lon = coordinate?.longitude else { return }
            
            let location = NMAGeoCoordinates(latitude: lat, longitude: lon)
            // MARK: - Searching for location
            
            
            if let searchRequest = NMAPlaces.sharedInstance()?.createSearchRequest(location: location, query: text) {
                
                searchRequest.start({ (request, data, error) in
                    

                    if data != nil {

                        guard let resultPage = data as? NMADiscoveryPage else { return }

                        controller.cachedSuggestions = resultPage.discoveryResults

                        controller.reloadData()

                    } else{
                        print("no value")
                    }
                })
            }
        }
    }
    
    func configureSearchBox() {
        let searchResultsController = searchResultTable()
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.searchTextField.textColor = .black
        searchController.searchBar.searchTextField.tintColor = .black
        searchController.searchBar.searchTextField.backgroundColor = .white
        
        if let placeholder = searchController.searchBar.searchTextField.placeholder {
            let attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]) // Change the color as needed
            searchController.searchBar.searchTextField.attributedPlaceholder = attributedPlaceholder
        }
        
        navigationItem.searchController = searchController
      }
}


extension MapViewController: SearchResultDelegate {

    func searchResultTable() -> UIViewController {

        var table = UIViewController()
        
        if let  searchTable = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            
            searchTable.delegate = self
            
            table = searchTable
            
        }
        
        return table
    }
    
    func searchViewDidSelectResult(_ result: NMAPlaceLink) {
                
        postionBtnEnable = false
        
        postionBtn.isHidden = true
        
        mapSchemeBtn.isHidden = true
        
        changPostionButtonApperance(buttom: postionBtn, with: POINTER_LIGHT, notification: false)
        
        navigationItem.searchController?.searchBar.text = result.name
        
        guard let lat = result.position?.latitude, let lon = result.position?.longitude else { return }
        
        let result_location = CLLocation(latitude: lat, longitude: lon)
        
        UIView.animate(withDuration: 2.0, animations: {
                   // Change properties you want to animate
            
            self.mapView.mapboxMap.setCamera(to: CameraOptions(center: result_location.coordinate, zoom: 15.0))
        })

        MarkerManager.share.placeAnnotations(on: mapView, with: result_location.coordinate, markerType: .red_pin)
        
        informationView.isHidden = false
        
        informationLable.text = result.name
        
        addressLable.text = result.vicinityDescription?.replacingOccurrences(of: "<br/>", with: " ")
        
        guard let lat = result.position?.latitude, let lon = result.position?.longitude else { return }
        
        destination = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        

    }
    
}



extension MapViewController: NavigationMapViewDelegate {
    
    
    // Delegate method called when the user selects a route
    
    
    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        
        self.currentRouteIndex = self.routes?.firstIndex(of: route) ?? 0
        
    }
    
    func requestRoute(destination: CLLocationCoordinate2D) {
        
        guard let userLocation = navigationMapView.mapView.location.latestLocation else { return }

        let location = CLLocation(latitude: userLocation.coordinate.latitude,
                                  longitude: userLocation.coordinate.longitude)

        let userWaypoint = Waypoint(location: location, heading: userLocation.heading, name: "user")

        let destinationWaypoint = Waypoint(coordinate: destination)

        let navigationRouteOptions = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])

        Directions.shared.calculate(navigationRouteOptions) { [weak self] (_, result) in
            switch result {
                
            case .failure(let error):
                
                print(error.localizedDescription)
                
            case .success(let response):
                guard let self = self else { return }

                self.routeResponse = response
                if let routes = self.routes, let currentRoute = self.currentRoute {
                    self.navigationMapView.show(routes)
                    self.navigationMapView.showWaypoints(on: currentRoute)
                }
            }
        }
    }
}

extension MapViewController: NavigationViewControllerDelegate {
    
    private func updateLabel(currentStreetName: String?, predictedCrossStreet: String?) {
        var statusString = ""
        if let currentStreetName = currentStreetName {
            statusString = "Currently on:\n\(currentStreetName)"
            
            if let predictedCrossStreet = predictedCrossStreet {
                statusString += "\nUpcoming intersection with:\n\(predictedCrossStreet)"
            } else {
                statusString += "\nNo upcoming intersections"
            }
        }
    }
  
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        
        let duration = 1.0
       navigationViewController.navigationView.topBannerContainerView.hide(duration: duration)
       navigationViewController.navigationView.bottomBannerContainerView.hide(duration: duration,
                                                                              animations: {
           navigationViewController.navigationView.wayNameView.alpha = 0.0
           navigationViewController.navigationView.floatingStackView.alpha = 0.0
           navigationViewController.navigationView.speedLimitView.alpha = 0.0
       }, completion: { [weak self] _ in
           
           
           // Since `NavigationViewController` assigns `NavigationMapView`'s delegate to itself,
           // delegate should be re-assigned back to `NavigationMapView` that is used in preview mode.
           self?.navigationMapView.delegate = self
           
           // Replace `NavigationMapView` instance with instance that was used in active navigation.
           self?.navigationMapView = navigationViewController.navigationMapView
           
           // Since `NavigationViewController` uses `UserPuckCourseView` as a default style
           // of the user location indicator - revert to back to default look in preview mode.
           self?.navigationMapView.userLocationStyle = .puck2D()
           
           // Showcase originally requested routes.
           if let routes = self?.routes {
               let cameraOptions = CameraOptions(bearing: 0.0, pitch: 0.0)
               self?.navigationMapView.showcase(routes,
                                               routesPresentationStyle: .all(shouldFit: true, cameraOptions: cameraOptions),
                                               animated: true,
                                               duration: duration)
           }
       })
        
    }
    
    
    func startNavigation() {
        
        //Read Jeson File
        
//        //For testing will use Cardiff_Intersections_Points_V2 since this captures all intersection, regardless it meet the criteria
//        geoJSONObject = GeoJSONReader().readGeoJSONFile(named: "Cardiff_Intersections_Points_V2")

        //This file contines all intersections within wales that meet project criteria
        geoJSONObject = GeoJSONReader().readGeoJSONFile(named: "wales_intersections")
        
        guard let routeResponse = routeResponse else { return }
        
        let indexedRouteResponse = IndexedRouteResponse(routeResponse: routeResponse, routeIndex: currentRouteIndex)
        
        let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse,customRoutingProvider: NavigationSettings.shared.directions,credentials: NavigationSettings.shared.directions.credentials,
            // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
                                                        simulating: .always)
         
        let navigationOptions = NavigationOptions(navigationService: navigationService,
        // Replace default `NavigationMapView` instance with instance that is used in preview mode.
        navigationMapView: navigationMapView)
         
        let navigationViewController = NavigationViewController(for: indexedRouteResponse,
        navigationOptions: navigationOptions)
        navigationViewController.delegate = self
        navigationViewController.modalPresentationStyle = .fullScreen

        
        
        if let latestValidLocation = navigationMapView.mapView.location.latestLocation?.location {
            navigationViewController.navigationMapView?.moveUserLocation(to: latestValidLocation)
        }

        // Hide top and bottom container views before animating their presentation.
        navigationViewController.navigationView.bottomBannerContainerView.hide(animated: false)
        navigationViewController.navigationView.topBannerContainerView.hide(animated: false)
         
        // Hide `WayNameView`, `FloatingStackView` and `SpeedLimitView` to smoothly present them.
        navigationViewController.navigationView.wayNameView.alpha = 0.0
        navigationViewController.navigationView.floatingStackView.alpha = 0.0
        navigationViewController.navigationView.speedLimitView.alpha = 0.0
        
            
        // Add the UIImageView to the  Navigation Controller view
        
        if let navigationView = navigationViewController.navigationMapView {
            
            alertImageView.contentMode = .scaleAspectFit
            
            navigationView.addSubview(alertImageView)
            
            // Disable autoresizing mask so that constraints work
            alertImageView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set constraints
            NSLayoutConstraint.activate([
                // Left constraint
                alertImageView.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 20),
                
                // Right constraint
                alertImageView.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -20),
                
                // Top constraint
                alertImageView.topAnchor.constraint(equalTo: navigationView.topAnchor, constant: 220),
                
                // Aspect ratio constraint (17:10)
                alertImageView.heightAnchor.constraint(equalTo: navigationView.widthAnchor, multiplier: 7 / 16.0)
            ])
        }

        
         
        present(navigationViewController, animated: false) {
            // Animate top and bottom banner views presentation.
            let duration = 1.0
            navigationViewController.navigationView.bottomBannerContainerView.show(duration: duration, animations: {
                
                navigationViewController.navigationView.wayNameView.alpha = 1.0
                navigationViewController.navigationView.floatingStackView.alpha = 1.0
                navigationViewController.navigationView.speedLimitView.alpha = 1.0
            })
                
            navigationViewController.navigationView.topBannerContainerView.show(duration: duration)
        }

    }
    
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        
        let currentLegProgress = progress.currentLegProgress
        
     
        
        if let maneuverDirection = currentLegProgress.upcomingStep?.maneuverDirection {
            
            
            switch maneuverDirection {
                
            case .right, .sharpRight:

                distanceToManeuver(currentStepProgress: currentLegProgress.currentStepProgress, alert: "right")
     
                
                
            case .left, .sharpLeft:
                distanceToManeuver(currentStepProgress: currentLegProgress.currentStepProgress, alert: "left")
                
      
                
            default:
                alertImageView.isHidden = true
                alertImageView.image = UIImage()                
            }
        }
        
    }

    
    func distanceToManeuver(currentStepProgress: RouteStepProgress, alert:String){
        
        let distanceToManeuver = currentStepProgress.distanceRemaining
     
        if distanceToManeuver <= 30, let IntersectionCoordinate = currentStepProgress.upcomingIntersection?.location {
            print("Its less then 30 Meter, trun @ [\(IntersectionCoordinate.longitude), \(IntersectionCoordinate.latitude)]")
            
            if isCoordinateContained(IntersectionCoordinate, in: geoJSONObject, tolerance: 10.00) {
               
                
                let imgStr = "left_side_trun_\(alert)"
                alertImageView.isHidden = false
                alertImageView.image = UIImage(named: imgStr)

            } else {
                
                alertImageView.isHidden = true
                alertImageView.image = UIImage()
                
            }

        } else {
            
            alertImageView.isHidden = true
            alertImageView.image = UIImage()
        }

    }


    func isCoordinateContained(_ intersectionCoordinate: CLLocationCoordinate2D, in geoJSONObject: [MKGeoJSONObject], tolerance: Double) -> Bool {
        for item in geoJSONObject {
            if let feature = item as? MKGeoJSONFeature {
                for geo in feature.geometry {
                    if let multipoint = geo as? MKMultiPoint {
                        // Convert the UnsafeMutablePointer to an array of MKMapPoint
                        let mapPoints = Array(UnsafeBufferPointer(start: multipoint.points(), count: Int(multipoint.pointCount)))
                        
                        for mapPoint in mapPoints {
                            let coordinate = mapPoint.coordinate
                            let location1 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            let location2 = CLLocation(latitude: intersectionCoordinate.latitude, longitude: intersectionCoordinate.longitude)
                            let distance = location1.distance(from: location2)
                            
                            if distance <= tolerance {
                                return true
                            }
                        }
                    }
                }
            }
        }
        
        return false
    }

}

