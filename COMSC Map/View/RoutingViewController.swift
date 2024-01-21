//
//  RoutingViewController.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 30/08/2023.
//

import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxMaps

class RoutingViewController: UIViewController, NavigationMapViewDelegate, NavigationViewControllerDelegate {
    
    var navigationMapView: NavigationMapView! {
        didSet {
            if oldValue != nil {
                oldValue.removeFromSuperview()
            }
            
            navigationMapView.translatesAutoresizingMaskIntoConstraints = false
            
            view.insertSubview(navigationMapView, at: 0)
            
            NSLayoutConstraint.activate([
                navigationMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigationMapView.topAnchor.constraint(equalTo: view.topAnchor),
                navigationMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }

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
    
    
    // MARK: - UIViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapView = NavigationMapView(frame: view.bounds)
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationMapView.delegate = self
        navigationMapView.userLocationStyle = .puck2D()
        
        let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        navigationViewportDataSource.options.followingCameraOptions.zoomUpdatesAllowed = false
        navigationViewportDataSource.followingMobileCamera.zoom = 13.0
        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource
        
        view.addSubview(navigationMapView)
        

    }
    
    // Override layout lifecycle callback to be able to style the start button.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }


    func requestRoute(destination: CLLocationCoordinate2D) {
        guard let userLocation = navigationMapView.mapView.location.latestLocation else { return }
        
        let location = CLLocation(latitude: userLocation.coordinate.latitude,
                                  longitude: userLocation.coordinate.longitude)
        
        let userWaypoint = Waypoint(location: location,
                                    heading: userLocation.heading,
                                    name: "user")
        
        let destinationWaypoint = Waypoint(coordinate: destination)
        
        let navigationRouteOptions = NavigationRouteOptions(waypoints: [userWaypoint, destinationWaypoint])
        
        Directions.shared.calculate(navigationRouteOptions) { [weak self] (_, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let self = self else { return }

                self.routeResponse = response

                if let routes = self.routes,
                   let currentRoute = self.currentRoute {
                    self.navigationMapView.show(routes)
                    self.navigationMapView.showWaypoints(on: currentRoute)
                }
            }
        }
    }
//
//    // Delegate method called when the user selects a route
//    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
//        self.currentRouteIndex = self.routes?.firstIndex(of: route) ?? 0
//    }
//
//    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
//        let duration = 1.0
//        navigationViewController.navigationView.topBannerContainerView.hide(duration: duration)
//        navigationViewController.navigationView.bottomBannerContainerView.hide(duration: duration,
//                                                                               animations: {
//            navigationViewController.navigationView.wayNameView.alpha = 0.0
//            navigationViewController.navigationView.floatingStackView.alpha = 0.0
//            navigationViewController.navigationView.speedLimitView.alpha = 0.0
//        },
//                                                                               completion: { [weak self] _ in
//            navigationViewController.dismiss(animated: false) {
//                guard let self = self else { return }
//
//                // Show previously hidden button that allows to start active navigation.
//                self.startButton.isHidden = false
//
//                // Since `NavigationViewController` assigns `NavigationMapView`'s delegate to itself,
//                // delegate should be re-assigned back to `NavigationMapView` that is used in preview mode.
//                self.navigationMapView.delegate = self
//
//                // Replace `NavigationMapView` instance with instance that was used in active navigation.
//                self.navigationMapView = navigationViewController.navigationMapView
//
//                // Since `NavigationViewController` uses `UserPuckCourseView` as a default style
//                // of the user location indicator - revert to back to default look in preview mode.
//                self.navigationMapView.userLocationStyle = .puck2D()
//
//                // Showcase originally requested routes.
//                if let routes = self.routes {
//                    let cameraOptions = CameraOptions(bearing: 0.0, pitch: 0.0)
//                    self.navigationMapView.showcase(routes,
//                                                    routesPresentationStyle: .all(shouldFit: true, cameraOptions: cameraOptions),
//                                                    animated: true,
//                                                    duration: duration)
//                }
//            }
//        })
//    }
}

