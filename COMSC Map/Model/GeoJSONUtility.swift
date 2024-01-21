//
//  GeoJSONUtility.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 20/09/2023.
//

//import Foundation
import MapKit.MKGeoJSONSerialization

class GeoJSONReader {

    func readGeoJSONFile(named fileName: String) -> [MKGeoJSONObject]? {

        if let path = Bundle.main.path(forResource: fileName, ofType: "geojson") {
            do {

                let data = try Data(contentsOf: URL(fileURLWithPath: path))

                let geojson = try MKGeoJSONDecoder().decode(data)
                
                return geojson

            } catch {
                print("Error reading GeoJSON File: \(error)")
                return nil
            }
        } else {
            print("GeoJSON file not found:")
            return nil
        }
    }

}





