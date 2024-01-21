//
//  MarkerManager.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 29/08/2023.
//

import Foundation
import MapboxMaps



class MarkerManager{
    
    enum MarkerType: String {
        case red_pin = "red_pin"
        case none = ""
    }
    
    static let share = MarkerManager()

        
    func placeAnnotations(on mapview: MapView, with coordinate:CLLocationCoordinate2D, markerType:MarkerType){


        // Initialize a point annotation with a geometry ("coordinate" in this case)
        var pointAnnotation = PointAnnotation(coordinate: coordinate)

        // Make the annotation show a red pin
        pointAnnotation.image = .init(image: UIImage(named: markerType.rawValue)!, name: markerType.rawValue)
        pointAnnotation.iconAnchor = .bottom
 
        // Create the `PointAnnotationManager` which will be responsible for handling this annotation
        let pointAnnotationManager = mapview.annotations.makePointAnnotationManager(id: markerType.rawValue)

        // Add the annotation to the manager in order to render it on the map.
        pointAnnotationManager.annotations = [pointAnnotation]
        

    }
    
    func removePlaceAnnotations(on mapview: MapView) {
        
        for id in mapview.annotations.annotationManagersById {
            
            mapview.annotations.removeAnnotationManager(withId:id.key)
        }
        
    }
}
