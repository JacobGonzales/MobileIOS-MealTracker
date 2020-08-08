//
//  AddViewController.swift
//  finalproject
//
//  Created by Jacob Gonzales on 8/7/20.
//  Copyright © 2020 Jacob Gonzales. All rights reserved.
//

import UIKit

protocol AddProtocol {
    func addMeal(_ meal: Meal)
}

class AddViewController: UIViewController{

    //MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var ratingTextField: UITextField!
    
    var backgroundColor:String?
    
    var delegate: AddProtocol?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if backgroundColor == "white"{
            view.backgroundColor = UIColor.white
            
            nameTextField.backgroundColor = UIColor.white
            caloriesTextField.backgroundColor = UIColor.white
            locationTextField.backgroundColor = UIColor.white
            typeTextField.backgroundColor = UIColor.white
            ratingTextField.backgroundColor = UIColor.white
            
            nameTextField.textColor = UIColor.black
            caloriesTextField.textColor = UIColor.black
            locationTextField.textColor = UIColor.black
            typeTextField.textColor = UIColor.black
            ratingTextField.textColor = UIColor.black
            
            nameLabel.textColor = UIColor.black
            caloriesLabel.textColor = UIColor.black
            locationLabel.textColor = UIColor.black
            typeLabel.textColor = UIColor.black
            ratingLabel.textColor = UIColor.black
        }
        else if backgroundColor == "gray"{
            view.backgroundColor = UIColor.darkGray
            
            nameTextField.backgroundColor = UIColor.darkGray
            caloriesTextField.backgroundColor = UIColor.darkGray
            locationTextField.backgroundColor = UIColor.darkGray
            typeTextField.backgroundColor = UIColor.darkGray
            ratingTextField.backgroundColor = UIColor.darkGray
            
            nameTextField.textColor = UIColor.white
            caloriesTextField.textColor = UIColor.white
            locationTextField.textColor = UIColor.white
            typeTextField.textColor = UIColor.white
            ratingTextField.textColor = UIColor.white
            
            nameLabel.textColor = UIColor.white
            caloriesLabel.textColor = UIColor.white
            locationLabel.textColor = UIColor.white
            typeLabel.textColor = UIColor.white
            ratingLabel.textColor = UIColor.white
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItem))
        self.navigationItem.rightBarButtonItem = save
        
        view.backgroundColor = UIColor.clear
    }
    
    @objc func saveItem() {
    //set up and call the function specified by the protocol
    self.nameTextField.resignFirstResponder()
    self.caloriesTextField.resignFirstResponder()
    self.locationTextField.resignFirstResponder()
    self.typeTextField.resignFirstResponder()
    self.ratingTextField.resignFirstResponder()
    
    let meal = Meal(name: self.nameTextField.text ?? "N/A", calories: self.caloriesTextField.text ?? "N/A", location: self.locationTextField.text ?? "N/A", type: self.typeTextField.text ?? "N/A", rating: self.ratingTextField.text ?? "N/A")
    
    delegate?.addMeal(meal)
        
    self.navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
