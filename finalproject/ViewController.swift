//
//  ViewController.swift
//  finalproject
//
//  Created by Jacob Gonzales on 8/6/20.
//  Copyright © 2020 Jacob Gonzales. All rights reserved.
//

import UIKit
import SQLite3

struct Meal{
    var id: Int?
    var name: String = "N/A"
    var calories: String = "N/A"
    var location: String = "N/A"
    var type: String = "N/A"
    var rating: String = "N/A"
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EditProtocol, AddProtocol{

    //MARK: Properties
    var meals: [Meal]! = []
    var mealBeingEdited: Int!
    @IBOutlet weak var myTableView: UITableView!
    var db: OpaquePointer?
    var backgroundColor: String?
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue"{
            let view = segue.destination as! AddViewController
            view.delegate = self
            view.backgroundColor = backgroundColor
        }
        else if segue.identifier == "editSegue"{
            let view = segue.destination as! EditViewController
            view.delegate = self
            
            mealBeingEdited = myTableView.indexPathForSelectedRow?.row
            
            view.backgroundColor = backgroundColor
            
            view.selectedMeal = meals[mealBeingEdited].name
            view.selectedCalories = meals[mealBeingEdited].calories
            view.selectedLocation = meals[mealBeingEdited].location
            view.selectedType = meals[mealBeingEdited].type
            view.selectedRating = meals[mealBeingEdited].rating
        }
    }
    
    //MARK: Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .destructive, title: "Delete") { (action:UIContextualAction, UIView, actionPerformed:(Bool) -> Void) in
            
            self.meals.remove(at: indexPath.row)
            self.myTableView.deleteRows(at: [indexPath], with: .fade)
            
            self.myTableView.reloadData()
            
            actionPerformed(true)
        }
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    
    //MARK: Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myTableView.backgroundColor = UIColor.clear
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //Populate Cells
        let meal = meals[indexPath.row]
        
        cell.textLabel?.text = meal.name
        cell.detailTextLabel?.text = "Calories: \(meal.calories )\nLocation: \(meal.location)\nType: \(meal.type)\nRating (Out of 10): \(meal.rating)"
        cell.accessoryType = .disclosureIndicator
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.\
        
        //MARK: SETTINGS SETUP
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        
        
        // MARK: SQL SETUP
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(saveToDatabase(_:)), name: UIApplication.willResignActiveNotification, object: nil)

        //the database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("MealsDatabase.sqlite")
        
        //opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                   print("error opening database")
        }
        
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Meals (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, calories VARCHAR, location VARCHAR, type VARCHAR, rating VARCHAR)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        //SELECT Query
        let queryString = "SELECT * FROM Meals"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let calories = String(cString: sqlite3_column_text(stmt, 2))
            let location = String(cString: sqlite3_column_text(stmt, 3))
            let type = String(cString: sqlite3_column_text(stmt, 4))
            let rating = String(cString: sqlite3_column_text(stmt, 5))
            //adding values to list
            meals.append(Meal(id: Int(id), name: String(describing: name), calories: String(describing: calories), location: String(describing: location), type: String(describing: type), rating: String(describing: rating)))
        }
        
    }
    
    //MARK: Protocols
    func addMeal(_ meal: Meal){
        meals.append(meal)
        myTableView.reloadData()
    }
    
    func editMeal(_ meal: Meal){
        meals[mealBeingEdited].name = meal.name
        meals[mealBeingEdited].calories = meal.calories
        meals[mealBeingEdited].location = meal.location
        meals[mealBeingEdited].type = meal.type
        meals[mealBeingEdited].rating = meal.rating
        myTableView.reloadData()
    }
    
    //MARK: Settings
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    @objc func defaultsChanged(){
        if UserDefaults.standard.bool(forKey: "EnableDarkMode") {
            self.view.backgroundColor = UIColor.darkGray
            self.backgroundColor = "gray"
        }
        else {
            self.view.backgroundColor = UIColor.white
            self.backgroundColor = "white"
        }
    }
    
    //MARK: SQLite
    @objc func saveToDatabase(_ notification:Notification){
        //creating a statement
        var stmt: OpaquePointer?
        
        //the database file
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("MealsDatabase.sqlite")
        
        //opening the database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                   print("error opening database")
        }
        
        //DELETE Query
        let queryStringDelete = "DELETE FROM Meals"
        
        //creating table
        if sqlite3_exec(db, queryStringDelete, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error deleting table: \(errmsg)")
        }
        
        //the insert query
        let queryString = "INSERT INTO Meals (name, calories, location, type, rating) VALUES (?,?,?,?,?)"
        
        for meal in meals {
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            let name = meal.name as NSString
            let calories = meal.calories as NSString
            let location = meal.location as NSString
            let type = meal.type as NSString
            let rating = meal.rating as NSString
            
            //binding the parameters
            if sqlite3_bind_text(stmt, 1, name.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 2, calories.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, location.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 4, type.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 5, rating.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting meal: \(errmsg)")
                return
            }
        }
        
     sqlite3_close(stmt)
    }
}
