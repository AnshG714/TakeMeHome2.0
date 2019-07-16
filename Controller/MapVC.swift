//
//  MapVC.swift
//  TakeMeHome
//
//  Created by Ansh Godha on 14/06/19.
//  Copyright © 2019 Cornell University. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseAuth
//import GooglePlaces


class MapVC: UIViewController, UIGestureRecognizerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var tabBarItemMap: UITabBarItem!
    
    static var groupsArray = [Group]()
    var memberLocations = [UserLocation]()
    var userMarkers = [String:GMSMarker]()
    var uidNameDict = [String:String]()
    
    let groupListTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        return tv
    }()
    
    var selectedGroup: Group?
    var isSharingLocation = false
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var initLocation = [CLLocationDegrees]()
    var zoomLevel: Float = 15.0
    var tappedMarker: GMSMarker?
    var customInfoWindow: CustomInfoWindow?
    var panningAcrossMap = false
    
    let groupButton = UIButton()
    let shareLocationButton = UIButton()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configuring delegate methods and the location manager
        panningAcrossMap = false
        zoomLevel = 17.0
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        mapView.delegate = self
        mapView.settings.consumesGesturesInView = false
        
        //Setting up the share location button
        shareLocationButton.backgroundColor = .blue
        shareLocationButton.frame = CGRect(x: 0, y: (tabBarController?.tabBar.frame.minY)! - 50 - self.view.safeAreaInsets.bottom - 35, width: view.frame.width, height: 50)
        shareLocationButton.setTitle("Share Location", for: .normal)
        shareLocationButton.isEnabled = false
        shareLocationButton.isUserInteractionEnabled = true
        shareLocationButton.addTarget(self, action: #selector(locationBtnTapped), for: .touchUpInside)
        self.view.addSubview(shareLocationButton)
        
        
        //setting up the gorup selection buttom
        groupButton.backgroundColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        groupButton.frame = CGRect(x: 0.325*view.frame.size.width, y: 75, width: 0.35*view.frame.size.width, height: 50)
        if MapVC.groupsArray.count == 0 {
            groupButton.setTitle("View Groups", for: .normal)
        } else {
            groupButton.setTitle(MapVC.groupsArray[0].groupTitle, for: .normal)
        }
        
        groupButton.isEnabled = false
        groupButton.setTitleColor(.white, for: .normal)
        groupButton.addTarget(self, action: #selector(groupBtnTapped), for: .touchUpInside)
        groupButton.layer.cornerRadius = 5.0
        self.view.addSubview(groupButton)
        
        //configuring table view containing groups
        groupListTableView.backgroundColor = #colorLiteral(red: 0.559433639, green: 0.009766425937, blue: 0.9948194623, alpha: 0.8004334332)
        groupListTableView.layer.cornerRadius = 7.0
        groupListTableView.separatorStyle = .none
        groupListTableView.register(GroupTVMapVCCell.self, forCellReuseIdentifier: "groupListTableViewCell")
        
        if Auth.auth().currentUser != nil {
            DataService.instance.getGroups2 { (returnedGroupsArray) in
                print("retrieved")
                MapVC.groupsArray = returnedGroupsArray
                self.groupListTableView.reloadData()
                self.groupButton.isEnabled = true
            }
        }
        
        groupListTableView.delegate = self
        groupListTableView.dataSource = self
        
        self.tappedMarker = GMSMarker()
        self.customInfoWindow = CustomInfoWindow().loadView()
        
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
       
        DataService.instance.REF_LOCATIONS.observe(.value) { (snapshot) in
            if self.selectedGroup != nil {
                self.manageLocationsAndMarkers()
            }
            
        }
    }
    
    
    //next 2 methods are for animating the table view to select the group.
    let blackView = UIView()
    @objc func groupBtnTapped(_ sender: UIButton!) {
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissGroupTableView)))
        
        view.addSubview(blackView)
        view.addSubview(groupListTableView)
        
        let tableHeight = 250
        groupListTableView.frame = CGRect(x: 0.2*view.frame.size.width, y: self.groupButton.frame.maxY, width: 0.60*view.frame.size.width, height: 0)
        blackView.alpha = 0
        
        blackView.frame = view.frame
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
            self.blackView.alpha = 1
            self.groupListTableView.frame = CGRect(x: 0.2*self.view.frame.size.width, y: self.groupButton.frame.maxY, width: 0.60*self.view.frame.size.width, height: CGFloat(tableHeight))
        }, completion: nil)
        
    self.groupListTableView.reloadData()
        
    }
    
    @objc func dismissGroupTableView(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
            self.blackView.alpha = 0
            self.groupListTableView.frame = CGRect(x: 0.2*self.view.frame.size.width, y: self.groupButton.frame.maxY, width: 0.60*self.view.frame.size.width, height: 0)
        }, completion: nil)
        
        //self.groupListTableView.reloadData()
    }
    
    
    //methods to get member locations and add and update markers accordingly
    func manageLocationsAndMarkers(){

        for uid in (self.selectedGroup?.groupMembers)! {
            //print("inside for loop")
            DataService.instance.getMemberLocations(forUID: uid) { (returnedLocation) in
               // print("inside Firebase method")
                if returnedLocation != nil && uid != (Auth.auth().currentUser?.uid)! {
                   
                    if self.userMarkers[uid] != nil {
                        self.userMarkers[uid]?.position = CLLocationCoordinate2D(latitude: (returnedLocation?.latitude)!, longitude: (returnedLocation?.longitude)!)
                        
                    } else {
                        let position = CLLocationCoordinate2D(latitude: (returnedLocation?.latitude)!, longitude: (returnedLocation?.longitude)!)
                        let marker = GMSMarker(position: position)
                        marker.map = self.mapView
                        self.userMarkers[uid] = marker
                    }
                }
            }
        }
        //print("outside for loop")
    }
    
    @objc func locationBtnTapped(sender: UIButton!) {
        if isSharingLocation {
            isSharingLocation = false
            UIView.animate(withDuration: 0.3) {
                sender.backgroundColor = .blue
                sender.setTitle("Share Location", for: .normal)
            }
            DataService.instance.REF_LOCATIONS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["sharing" : false])
        } else {
            isSharingLocation = true
            UIView.animate(withDuration: 0.3) {
                sender.backgroundColor = .red
                sender.setTitle("Stop Sharing Location", for: .normal)
                DataService.instance.uploadLocation(forUID: (Auth.auth().currentUser?.uid)!, withLatitude: self.initLocation[0], withLongitude: self.initLocation[1]) { () in
                    DataService.instance.REF_LOCATIONS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["sharing": true])
                }
            }
        }
    }    
}

extension MapVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapVC.groupsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = groupListTableView.dequeueReusableCell(withIdentifier: "groupListTableViewCell") as? GroupTVMapVCCell {
            cell.groupNameLabel.text = MapVC.groupsArray[indexPath.row].groupTitle
            cell.backgroundColor = UIColor.clear
            cell.layer.borderColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            cell.layer.borderWidth = 2.0
            cell.layer.cornerRadius = 5.0
            //cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissGroupTableView(_:))))
            return cell
        } else {
            return GroupTVMapVCCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("selectedGroupChanged")
        let tappedGroup = MapVC.groupsArray[indexPath.row]
        self.selectedGroup = tappedGroup
        groupButton.setTitle(tappedGroup.groupTitle, for: .normal)
        if let cell = groupListTableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.green
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
                self.blackView.alpha = 0
                self.groupListTableView.frame = CGRect(x: 0.2*self.view.frame.size.width, y: self.groupButton.frame.maxY, width: 0.60*self.view.frame.size.width, height: 0)
            }, completion: nil)
        }
        
    }
    
    
    
    
}
