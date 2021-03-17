//
//  LoadingButton.swift
//  OnTheMap
//
//  Created by Paul Smith on 3/7/21.
//

import UIKit

class LoadingButton: UIButton {
    
    var activityIndicator: UIActivityIndicatorView!
    var originalText: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
        tintColor = UIColor.white
        setTitleColor(UIColor.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 20)
        backgroundColor = UIColor.primaryDark
        
        createActivityIndicator()
        originalText = self.titleLabel?.text ?? ""
        showLoading(isLoading: false)
    }
    
    func showLoading(isLoading: Bool) {
        isEnabled = !isLoading
        self.setTitle(isLoading ? "" : originalText, for: .normal)
        if(isLoading) {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
    }

    func createActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .lightGray
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
    }

    func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
    
}
