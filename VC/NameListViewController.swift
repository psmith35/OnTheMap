//
//  NameListViewController.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/8/21.
//

import UIKit

private let tableCellIndentifier = "LocationCell"

class NameListViewController: UITableViewController {
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateList()
    }
    
    func updateList() {
        OTMClient.getStudentLocations(completion: handleUpdateResponse(locations:error:))
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OTMModel.locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIndentifier)!
        let studentLocation = OTMModel.locations[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        cell.textLabel?.text = "\(studentLocation.firstNameString) \(studentLocation.lastNameString)"
        cell.detailTextLabel?.text = studentLocation.urlString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = OTMModel.locations[(indexPath as NSIndexPath).row].urlString
        if let urlToOpen = URL(string: urlString), UIApplication.shared.canOpenURL(urlToOpen) {
            UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
        }
        else {
            showOpenFailure()
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        OTMClient.logout(completion: {success, error in
            if(success) {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.showLogoutFailure(error: error)
            }
        })
    }
    
    @IBAction func refresh(_ sender: Any) {
        updateList()
    }
    
    @IBAction func addLocation(_ sender: Any) {
        let addVC = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController")as! AddLocationViewController
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    func handleUpdateResponse(locations: [StudentLocation]?, error: Error?) {
        if let error = error {
            showUpdateFailure(error: error)
        }
        if let locations = locations {
            OTMModel.locations = locations
            self.tableView!.reloadData()
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
