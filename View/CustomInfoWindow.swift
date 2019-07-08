//
//  CustomInfoWindow.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 05/07/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit
import GoogleMaps

class CustomInfoWindow: UIView {
    @IBOutlet weak var nameText: UILabel!
    var location: CLLocationCoordinate2D?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func loadView() -> CustomInfoWindow{
        let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
        return customInfoWindow
    }
    
    
    @IBAction func openGMapsBtnTapped(_ sender: Any) {
    }
}
