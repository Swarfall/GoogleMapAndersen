//
//  MapViewController.swift
//  MapAndersen
//
//  Created by admin on 31.10.2019.
//  Copyright © 2019 Viacheslav Savitsky. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var locationModel = LocationModel()
    var currentLong: CLLocationDegrees = 0
    var currentLat: CLLocationDegrees = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        putDataPlaces()
    }


}

extension MapViewController: GMSMapViewDelegate, CLLocationManagerDelegate {

    func putDataPlaces() {
        updateDataMarkerLocation(lat: 50.4389, long: 30.4965)
        updateDataMarkerLocation(lat: 46.4390, long: 30.7690)
    }
    
    func setCurrentLocation() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func setMarker(long: CLLocationDegrees, lat: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.icon = UIImage(named: "marker")
        marker.position.latitude = lat
        marker.position.longitude = long
        marker.map = mapView
    }
    
    func updateDataMarkerLocation(lat: Double, long: Double) {
          setMarker(long: long, lat: lat)
          setCurrentLocation()
      }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let camera = GMSCameraPosition.camera(withLatitude:(50.4389), longitude: (30.4965), zoom: 10)
        self.mapView.animate(to: camera)
        self.currentLat = self.locationManager.location?.coordinate.latitude ?? 0
        self.currentLong = self.locationManager.location?.coordinate.longitude ?? 0
        self.locationManager.stopUpdatingLocation()
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
        guard let address = response?.firstResult(), let lines = address.lines else { return }
        
        self.locationLabel.text = lines.joined(separator: "\n")

        UIView.animate(withDuration: 0.25) {
          self.view.layoutIfNeeded()
        }
      }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        draw(src: CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong), dst: coordinate)
            print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    func draw(src: CLLocationCoordinate2D, dst: CLLocationCoordinate2D){

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(src.latitude),\(src.longitude)&destination=\(dst.latitude),\(dst.longitude)&sensor=false&mode=walking&key=AIzaSyCtmTSeBoiNuABFitnJ9Bm7URumBCxYxCs")!

        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {

                        let preRoutes = json["routes"] as! NSArray
                        let routes = preRoutes[0] as! NSDictionary
                        let routeOverviewPolyline:NSDictionary = routes.value(forKey: "overview_polyline") as! NSDictionary
                        let polyString = routeOverviewPolyline.object(forKey: "points") as! String

                        DispatchQueue.main.async(execute: {
                            let path = GMSPath(fromEncodedPath: polyString)
                            let polyline = GMSPolyline(path: path)
                            polyline.strokeWidth = 5.0
                            polyline.strokeColor = UIColor.blue
                            polyline.map = self.mapView
                        })
                    }

                } catch {
                    print("parsing error")
                }
            }
        })
        task.resume()
    }
}
