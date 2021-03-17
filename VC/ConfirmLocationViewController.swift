//
//  ConfirmLocationViewController.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/8/21.
//

import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: LoadingButton!
    
    var locationRequest : LocationRequest!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        zoomIn()
    }
    
    func zoomIn() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        let lat = CLLocationDegrees(locationRequest.latitude)
        let long = CLLocationDegrees(locationRequest.longitude)

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = locationRequest.mapString

        self.mapView.addAnnotation(annotation)
        self.mapView.centerCoordinate = annotation.coordinate

        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate,
            latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - MKMapViewDelegate

    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func confirmLocation(_ sender: Any) {
        self.finishButton.showLoading(isLoading: true)
        OTMClient.postStudentLocation(location: locationRequest, completion: handleConfirmRequest(success:error:))
    }
    
    func handleConfirmRequest(success: Bool, error: Error?) {
        if(success) {
            finishButton.showLoading(isLoading: false)
            self.navigationController?.popToRootViewController(animated: true)
        }
        else {
            showConfirmFailure(error: error)
        }
    }
    
    func showConfirmFailure(error: Error?) {
        let alertVC = UIAlertController(title: "Add Location Failed", message: error?.localizedDescription ?? "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in self.finishButton.showLoading(isLoading: false)}))
        self.present(alertVC, animated: true, completion: nil)
    }
    
}
