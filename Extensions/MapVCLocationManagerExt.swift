//
//  MapVCLocationManagerExt.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 08/07/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleMaps

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.initLocation = [location.coordinate.latitude, location.coordinate.longitude]
        shareLocationButton.isEnabled = true
        
        if !panningAcrossMap {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
            locationManager.startUpdatingHeading()
        }
        
        
        if isSharingLocation {
            DataService.instance.uploadLocation(forUID: (Auth.auth().currentUser?.uid)!, withLatitude: location.coordinate.latitude, withLongitude: location.coordinate.longitude) { () in
            }
        }
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func focusMapToShowMarkers() {
        let myLocation = CLLocationCoordinate2D(latitude: self.initLocation[0], longitude: self.initLocation[1])
        var bounds = GMSCoordinateBounds(coordinate: myLocation, coordinate: myLocation)
        for marker in userMarkers.values {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(15))
        zoomLevel = 17.0
        self.mapView.animate(with: update)
        self.mapView.animate(toZoom: zoomLevel)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        zoomLevel = mapView.camera.zoom
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        panningAcrossMap = false
        focusMapToShowMarkers()
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let position = marker.position
        mapView.animate(toLocation: position)
        
        let opaqueWhite = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.85)
        customInfoWindow?.layer.backgroundColor = opaqueWhite.cgColor
        customInfoWindow?.layer.cornerRadius = 8
        customInfoWindow?.center = mapView.projection.point(for: position)
        for uid in userMarkers.keys {
            if userMarkers[uid] == marker {
                if uidNameDict.keys.contains(uid) {
                    customInfoWindow?.nameText.text = uidNameDict[uid]
                } else {
                    DataService.instance.getUserFullname(forUID: uid) { (returnedFullName) in
                        self.uidNameDict[uid] = returnedFullName
                        self.customInfoWindow?.nameText.text = returnedFullName
                    }
                }
            }
        }
        customInfoWindow?.location = position
        self.mapView.addSubview(customInfoWindow!)
        panningAcrossMap = true
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        customInfoWindow?.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let position = tappedMarker?.position
        customInfoWindow?.center = mapView.projection.point(for: position!)
        customInfoWindow?.center.y -= 140
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            panningAcrossMap = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if !panningAcrossMap {
            mapView.animate(toBearing: newHeading.trueHeading)
        }
        
    }
}
