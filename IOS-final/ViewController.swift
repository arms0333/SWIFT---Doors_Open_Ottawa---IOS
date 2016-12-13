//
//  ViewController.swift
//  IOS-final
//
//  Created by Cody Armstrong on 2016-12-02.
//  Copyright © 2016 arms0333@algonquinlive.com. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var viewAddress: UILabel!
    @IBOutlet weak var viewDescription: UITextView!
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var buildingMap: MKMapView!
    
    var buildingID: Int?
    var jsonObject: [String:AnyObject]?

// 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let username = "arms0333"
        let password = "password"
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = URL(string: "https://doors-open-ottawa-hurdleg.mybluemix.net/buildings/" + buildingID!.description)!
        var request = URLRequest(url: url)
        //request.httpMethod = "POST"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let mySession :  URLSession = URLSession.shared
        
        let buildingTask = mySession.dataTask(with: request, completionHandler: buildingRequestTask )
        
        // Tell the JSON data task to run
        buildingTask.resume()
        
        // create the request
        let urlImage = URL(string: "https://doors-open-ottawa-hurdleg.mybluemix.net/buildings/" + buildingID!.description + "/image")!
        var requestImage = URLRequest(url: urlImage)
        //request.httpMethod = "POST"
        requestImage.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        //let mySessionImage :  URLSession = URLSession.shared
        
        let imageTask = mySession.dataTask(with: requestImage, completionHandler: imageRequestTask )
        
        // Tell the JSON data task to run
        imageTask.resume()

    }
    
    // Define a function that will handle the image request which will need to recieve the data send back, the response status, and an error object to handle any errors returned
    func imageRequestTask (_ serverData: Data?, serverResponse: URLResponse?, serverError: Error?) -> Void{
        
        // If the error object has been set then an error occured
        if serverError != nil {
            // Send en empty string as the data, and the error to the callback function
            print("ERROR is " + serverError!.localizedDescription)
        }else{
            // Else take the image data recieved from the server and process it
            // Because this callback is run on a secondary thread you must make any ui updates on the main thread by calling the dispatch_async method like so
            DispatchQueue.main.async {
                // Set the ImageView's image by converting the data object into a UIImage
                self.viewImage.image =  UIImage(data: serverData!)
            }
        }
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
            // Send the response string data, and nil for the error tot he callback
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
                    jsonObject = try JSONSerialization.jsonObject(with: myData, options: []) as? [String:AnyObject]
                    
                } catch let convertError as NSError {
                    // If it fails catch the error info
                    print(convertError.description)
                }
            }
            
            // Because this callback is run on a secondary thread you must make any ui updates on the main thread by calling the dispatch_async method like so
            DispatchQueue.main.async
                {
                    self.viewAddress.text = self.jsonObject!["address"] as? String
                    self.viewDescription.text = ""
                    self.viewTitle.text = self.jsonObject!["name"] as? String
                    let arr = self.jsonObject!["open_hours"] as? [[String:String]]
                    for d in arr! {
                        
                        self.viewDescription.text.append(d["date"]! + "\n")
                        
                    }
                       self.viewDescription.text.append( (self.jsonObject!["description"] as? String)! )
                    
                        let geocodedAddresses = CLGeocoder()
                        geocodedAddresses.geocodeAddressString(self.viewAddress.text!, completionHandler: self.placeMarkerHandler )
                    
            }
        }
    }


// map stuff
    func placeMarkerHandler (_ placeMarkers: [CLPlacemark]?, error: Error?) {
        if let firstMarker = placeMarkers?[0] {
            let marker = MKPlacemark(placemark: firstMarker)
            self.buildingMap?.addAnnotation(marker)
            let myRegion = MKCoordinateRegionMakeWithDistance(marker.coordinate, 500, 500)
            self.buildingMap?.setRegion(myRegion, animated: false)
        }

}
}
