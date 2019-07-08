//
//  File.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 24/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import Foundation
import GoogleMaps

struct UserLocation {
    
    private var _uid: String
    private var _lat: CLLocationDegrees
    private var _long: CLLocationDegrees
    
    var uid: String {
        return _uid
    }
    
    var latitude: CLLocationDegrees {
        return _lat
    }
    
    var longitude: CLLocationDegrees {
        return _long
    }
    
    init(userUID uid: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self._uid = uid
        self._lat = latitude
        self._long = longitude
    }
    
}
