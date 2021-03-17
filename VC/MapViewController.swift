//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/8/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAnnotations()
    }
    
    func updateAnnotations() {
        OTMClient.getStudentLocations(completion: handleUpdateResponse(locations:error:))
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
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let urlString = view.annotation?.subtitle, let urlToOpen = URL(string: urlString!), UIApplication.shared.canOpenURL(urlToOpen) {
                UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
            }
            else {
                showOpenFailure()
            }
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        OTMClient.logout(completion: {success, error in
            if(success) {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.showLogoutFailure(error: error)
            }
        })
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        updateAnnotations()
    }
    
    @IBAction func addLocation(_ sender: UIBarButtonItem) {
        let addVC = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController")as! AddLocationViewController
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    func handleUpdateResponse(locations: [StudentLocation]?, error: Error?) {
        if let error = error {
            showUpdateFailure(error: error)
        }
        if let studentLocations = locations {
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            OTMModel.locations = studentLocations
            var annotations = [MKPointAnnotation]()
            
            for studentLocation in studentLocations {
                
                let lat = CLLocationDegrees(studentLocation.latitude)
                let long = CLLocationDegrees(studentLocation.longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                annotation.title = "\(studentLocation.firstNameString) \(studentLocation.lastNameString)"
                annotation.subtitle = studentLocation.urlString
                
                annotations.append(annotation)
            }
            
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func showUpdateFailure(error: Error?) {
        let alertVC = UIAlertController(title: "Update Failed", message: error?.localizedDescription ?? "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showLogoutFailure(error: Error?) {
        let alertVC = UIAlertController(title: "Logout Failed", message: error?.localizedDescription ?? "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showOpenFailure() {
        let alertVC = UIAlertController(title: "Can't Open", message: "URL is not valid.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }

}
