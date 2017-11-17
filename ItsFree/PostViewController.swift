//
//  PostViewController.swift
//  ItsFree
//
//  Created by Sanjay Shah on 2017-11-17.
//  Copyright © 2017 Sanjay Shah. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    var categoryPickerData: [String] = [String]()
    @IBOutlet weak var qualitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tagButtonView: UIView!
    @IBOutlet weak var itemMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        descriptionTextField.delegate = self
        


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    
    
    
}
