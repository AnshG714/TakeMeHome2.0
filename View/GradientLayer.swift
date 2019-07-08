//
//  GradientLayer.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 11/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit

extension UIView {
    func createGradientLayer(withColours colours: [CGColor], changeLocations locations: [NSNumber]?) {
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.colors = colours
        layer.locations = locations
        self.layer.insertSublayer(layer, at: 0)
    }
}

