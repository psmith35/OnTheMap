//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/8/21.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: CustomTextField!
    @IBOutlet weak var urlTextField: CustomTextField!
    @IBOutlet weak var addLocationButton: LoadingButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if locationTextField.isEditing || urlTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height / 2.0
    }

    @IBAction func addLocation(_ sender: Any) {
        if urlTextField.hasText {
            setAddingLocation(true)
            let mapString = locationTextField.text ?? ""
            CLGeocoder().geocodeAddressString(mapString, completionHandler: handleAddResponse(placemark:error:))
        }
        else {
            let alertVC = UIAlertController(title: "URL Required", message: "Please include a URL.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in self.setAddingLocation(false)}))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func handleAddResponse(placemark: [CLPlacemark]?, error: Error?) {
        if
            let placemark = placemark,
            let location = placemark.first?.location
        {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let locationRequest: LocationRequest  = LocationRequest(uniqueKey: OTMClient.Auth.accountKey, firstName: OTMModel.user.firstName, lastName: OTMModel.user.lastName, mapString: self.locationTextField.text ?? "", mediaURL: self.urlTextField.text ?? "", latitude: latitude, longitude: longitude)
            
            setAddingLocation(false)
            let confirmVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmLocationViewController")as! ConfirmLocationViewController
            confirmVC.locationRequest = locationRequest
            self.navigationController?.pushViewController(confirmVC, animated: true)

        }
        else {
            self.showAddFailure(error: error)
        }
    }
    
    func showAddFailure(error: Error?) {
        let alertVC = UIAlertController(title: "Request Location Failed", message: error?.localizedDescription ?? "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in self.setAddingLocation(false)}))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func setAddingLocation(_ adding: Bool) {
        locationTextField.enableTextField(isEnabled: !adding)
        urlTextField.enableTextField(isEnabled: !adding)
        addLocationButton.showLoading(isLoading: adding)
    }
    
    func wipeAddInfo() {
        self.locationTextField.text = ""
        self.urlTextField.text = ""
    }
    
}
