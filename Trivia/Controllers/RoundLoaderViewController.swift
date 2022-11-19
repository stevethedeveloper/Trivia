//
//  SpinnerViewController.swift
//  Trivia
//
//  Created by Stephen Walton on 11/17/22.
//

import UIKit

class RoundLoaderViewController: UIViewController {
//    var spinner = UIActivityIndicatorView(style: .large)
    var text: String = ""
    
    override func loadView() {
        let loadingImageLabel = UILabel()
        let loadingTextLabel = UILabel()

        view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 1.0)
        
        loadingImageLabel.text = text
        loadingImageLabel.font = loadingImageLabel.font.withSize(200)
        loadingImageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingImageLabel)
        
        loadingTextLabel.text = "Loading..."
        loadingTextLabel.font = loadingTextLabel.font.withSize(30)
        loadingTextLabel.textColor = UIColor.systemGray
        loadingTextLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingTextLabel)

        
        NSLayoutConstraint.activate([
            loadingImageLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            loadingImageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingImageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingTextLabel.topAnchor.constraint(equalTo: loadingImageLabel.bottomAnchor),
            loadingTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
