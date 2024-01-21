//
//  WelcomeMenu.swift
//  COMSC Map
//
//  Created by Fahad Al Khusaibi on 30/07/2023.
//

import UIKit

class WelcomeMenu: UIViewController {
    
    var appCoordinator: AppCoordinator?
    var configuration = UserConfiguration()
    @IBOutlet weak var automaticIconCheck: UIImageView!
    @IBOutlet weak var kphCheck: UIImageView!
    @IBOutlet weak var mphCheck: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var leftTrafficBtn: UIButton!
    @IBOutlet weak var rightTrafficBtn: UIButton!
    @IBOutlet weak var DistanceSelectionMenu: UIView!
    @IBOutlet weak var DrivingSelectionMenu: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func trafficBtnTap(_ sender: UIButton) {
        
        nextButton.isHidden = false
        resetDistainceSelection()
        
        switch sender.restorationIdentifier {
            
            case "RightTraffic":
                setSelection(buttonin: rightTrafficBtn)
                configuration.orientation = .right
            
            case "LeftTraffic":
                setSelection(buttonin: leftTrafficBtn)
                configuration.orientation = .left
            default:
                break
        }
    }
        
    @IBAction func distanceUnitsBtnTap(_ sender: UIButton) {
        
        resetAllIcons()
        
        let fillCheckMark = "checkmark.circle.fill"
        
        switch sender.restorationIdentifier {
            
            case "automatic":
                setIcon(for: automaticIconCheck, with: fillCheckMark)
                configuration.unit = .automatic
            case "kph":
                setIcon(for: kphCheck, with: fillCheckMark)
                configuration.unit = .kph
            case "mph":
                setIcon(for: mphCheck, with: fillCheckMark)
                configuration.unit = .mph
            default:
                break
            }
    }
    
    @IBAction func NextButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            if sender.restorationIdentifier == "next" {
                //Unit Selection VIEW
                if self.DistanceSelectionMenu.isHidden {
                    self.animateMenuTransition(from: self.DrivingSelectionMenu, to: self.DistanceSelectionMenu, with: sender)
                    self.backButton.isHidden = false
                    self.nextButton.setTitle("Finish", for: .normal)
                } else {
                    //Configtation Process VIEW
                    self.animateMenuTransition(from: self.DistanceSelectionMenu, with: sender)
                    
                    self.backButton.isHidden = true
                    
                    self.nextButton.isHidden = true
                    
                    SpinnerManager.shared.startSpinner(in: self.view)
                    
                    // Store user confiration in core data
                    CoreDataManager.shared.storeObject(unit: self.configuration.unit, orientation: self.configuration.orientation)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
                        SpinnerManager.shared.stopSpinner()
                        

                        let mapViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MapViewController") as! MapViewController
                        
                        mapViewController.configuration = self.configuration

                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            sceneDelegate.window?.rootViewController = mapViewController
                        }
                    }
                }
                
            } else if sender.restorationIdentifier == "back" {
                self.animateMenuTransition(from: self.DistanceSelectionMenu, to: self.DrivingSelectionMenu, with: sender)
                self.nextButton.setTitle("Next", for: .normal)
                self.backButton.isHidden = true
            }
        }
    }
    

    func setSelection(buttonin: UIButton) {
        
        buttonin.layer.borderWidth = 3
        buttonin.layer.borderColor =  UIColor.black.cgColor
        
    }
    
    func resetDistainceSelection() {
        
        let unSelectedColor = UIColor.clear.cgColor
        leftTrafficBtn.layer.borderColor = unSelectedColor
        rightTrafficBtn.layer.borderColor = unSelectedColor
        
    }
    
    func resetAllIcons() {
        setIcon(for: automaticIconCheck, with: "circle")
        setIcon(for: kphCheck, with: "circle")
        setIcon(for: mphCheck, with: "circle")
    }

    func setIcon(for imageView: UIImageView, with systemName: String) {
        imageView.image = UIImage(systemName: systemName)
    }
    
    func animateMenuTransition(from oldMenu: UIView, to newMenu: UIView? = nil, with sender: UIButton) {
        oldMenu.isHidden = true
        oldMenu.frame.origin.x = (sender.restorationIdentifier == "next") ? -oldMenu.frame.width : oldMenu.frame.width
        
        if let newMenu =  newMenu {
            newMenu.isHidden = false
            newMenu.frame.origin.x = 0
        }
    }
}
