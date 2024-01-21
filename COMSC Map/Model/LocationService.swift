import CoreLocation

protocol LocationServicesDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
}

class LocationServices: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationServices()

    private var locationManager: CLLocationManager?
    
    
    weak var delegate: LocationServicesDelegate?
    

    private override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }

    
    //Mark: - Check Authorization and updating accoding to user slected option
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if let locManger = locationManager {

            switch status {

            case .notDetermined:

                locManger.requestWhenInUseAuthorization()


            case .authorizedWhenInUse, .authorizedAlways:

                locManger.desiredAccuracy = kCLLocationAccuracyBest

                locManger.startUpdatingLocation()

            case .restricted, .denied:

                print("Alert user to enable location severice ")


            @unknown default :
                print("Error .....")//fatalError()
            }
        }
    }
    
    
    
    // MARK: - Updating Current user Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            delegate?.didUpdateLocation(location)
        }
    }

}

