//
//  TableViewController.swift
//  IOS-final
//
//  Created by Cody Armstrong on 2016-12-02.
//  Copyright © 2016 arms0333@algonquinlive.com. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController
{
    //variable to hold all the dictionary information
    var jsonObject: [String:[[String:AnyObject]]]?
    
    // loads this view first
    override func viewDidLoad()
    {
        // load the view
        super.viewDidLoad()
        //starts the authentication
        let username = "arms0333"
        let password = "password"
        // formats the string
        let loginString = String(format: "%@:%@", username, password)
        //encodes in utf8
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = URL(string: "https://doors-open-ottawa-hurdleg.mybluemix.net/buildings")!
        var request = URLRequest(url: url)
    
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        //???
        let mySession :  URLSession = URLSession.shared
        
        let buildingTask = mySession.dataTask(with: request, completionHandler: buildingRequestTask )
        
                // Tell the JSON data task to run
                buildingTask.resume()
        
        }
        
        // Define a function that will handle the JSON data request which will need to recieve the data send back, the response status, and an error object to handle any errors returned
        func buildingRequestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void
        {
            // If the error object has been set then an error occured
            if serverError != nil
            {
                // Send en empty string as the data, and the error to the callback function
                self.buildingCallback("", error: serverError?.localizedDescription)
            }else{
                // If no error was generated then the server responce has been recieved
                // Stringify the response data
                let result = NSString(data: serverData!, encoding: String.Encoding.utf8.rawValue)!
                // Send the response string data, and nil for the error to the callback
                self.buildingCallback(result as String, error: nil)
            }
        }
        
        
        // Define the JSON data callback function to be triggered when the JSON data response is received
        func buildingCallback(_ responseString: String, error: String?)
        {
            // If the server request generated an error then handle it
            if error != nil
            {
                print("ERROR is " + error!)
            }else{
                // Else take the data recieved from the server and process it
                print("DATA is " + responseString)
                
                // Take the response string and turn it back into raw data
                if let myData: Data = responseString.data(using: String.Encoding.utf8)
                {
                    do {
                        // Try to convert response data into a dictionary to be saved into the optional dictionary
                        jsonObject = try JSONSerialization.jsonObject(with: myData, options: []) as? [String:[[String:AnyObject]]]
                        
                    } catch let convertError as NSError {
                        // If it fails catch the error info
                        print(convertError.description)
                    }
                }
                
                // Because this callback is run on a secondary thread you must make any ui updates on the main thread by calling the dispatch_async method like so
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
        }
        }
    // initailize how many rows will be in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int
    {// optional binding
        if let jsonD = jsonObject{
            let jsonArr = jsonD["buildings"]
            return jsonArr!.count
        }else{
            return 0
        }
    }
// return each cell with a different building
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jsonCell", for: indexPath)
        
        // optional binding
        if let jsonD = jsonObject
        {
            let jsonArr = jsonD["buildings"]
            
            if let theDictionary = jsonArr?[indexPath.row]
            {
                cell.textLabel?.text = theDictionary["name"] as! String?
            }
            
        }
        return cell
    }
    // transition to the new view with the specific building ID
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "secondView"
        {
            let infoVC  = segue.destination as? ViewController
            
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell)
                else
            {
                return
            }
            infoVC?.buildingID = indexPath.row
        }
    }
}
