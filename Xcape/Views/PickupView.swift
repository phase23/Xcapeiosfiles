//
//  PickupView.swift
//  Xcape
//
//  Created by Wilson Jno-Baptiste on 1/27/24.
//

import SwiftUI
import MapKit
import AVFoundation
import Foundation
import Combine

struct PickupView: View {
        @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 18.193972099377174, longitude: -63.08687167724191), // Example coordinates (San Francisco)
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    )
    
    @State private var route: MKRoute?
    @State private var annotations: [MKPointAnnotation] = []
    @State private var bearing: CLLocationDirection = 0
    
    @State private var showList = false
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    let thislocation:String
    let thisplace:String
    let thisroute:String
    let thissite:String
    @State private var cordin = ""
    @State private var placeid = ""
    @State private var site = ""
    @State private var getroute = ""
 //  @State private var distanceAndTimeText: String = "Calculating..."
    @State var waypoints: [Waypoint] = []

    
    
   @StateObject var locationViewModels = LocationViewModel()
    @ObservedObject var locationViewModel: LocationViewModel
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {

         //let waypointJsonString = getwaymarkers()
        
        let components = thislocation.split(separator: ",").map { String($0) }
        let latitude = Double(components[0])
        let longitude = Double(components[1])
        
        
        let routeComponents = thisroute.split(separator: "/").map { String($0) }
        let cleanLatitude = routeComponents[0].filter("0123456789.-".contains)
        let cleanLongitude = routeComponents[1].filter("0123456789.-".contains)
    let routelatitude = Double(cleanLatitude)
    let routelongitude = Double(cleanLongitude )
   
        
       
        SatelliteMapView(region: $region, annotations: createAnnotations(latitude: locationViewModel.latitude, longitude: locationViewModel.longitude), route: route,bearing: $locationViewModels.currentBearing, locationViewModel: LocationViewModel(),latitude: locationViewModel.latitude,longitude: locationViewModel.longitude)

        
    /*
        SatelliteMapView(region: region, annotations: createAnnotations(latitude: latitude!, longitude: longitude!), route: route)

         */
        
      
        VStack {
            HStack{
                
                Button(action: {
                    
                     presentationMode.wrappedValue.dismiss()
                  
//                    showList = true
//                    
//                    
//                    let latt = locationViewModel.latitude
//                    let longg = locationViewModel.longitude
//                    cordin = "\(latt),\(longg)"
//                     
//              
//                    print("pickup rreturn: \(latt),\(longg)")
                    
                    
                }) { //start button click
                Text("Back")
                    .frame(width: 100, height: 50)
                    .background(Color.lightGrey)
                    .foregroundColor(.black)
                    .cornerRadius(8) //
                    
                    
                }//end button click
                .padding(.leading, 10)
            
                    
                    Text("Miles")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding() //
                    
             
                    
                    
          
                
                
                
            }//end hstack 1
         
        }
        
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .onReceive(locationViewModel.objectWillChange) { _ in
                if locationViewModel.latitude != 0.0 && locationViewModel.longitude != 0.0 {
                    region.center = CLLocationCoordinate2D(latitude: locationViewModel.latitude, longitude: locationViewModel.longitude)
                    
                    print("current: \(locationViewModel.latitude ) - \(locationViewModel.longitude) / End loc: \(latitude!) - \(longitude! )")
                    
                    let startCCoordinate = CLLocationCoordinate2D(latitude: locationViewModel.latitude, longitude:  locationViewModel.longitude)
                    
                    let endCCoordinate = CLLocationCoordinate2D(latitude: routelatitude!, longitude: routelongitude!)

                /*
                    calculateDistanceAndTime(from: startCCoordinate, to: endCCoordinate) { distance, travelTime in
                        let travelTimeInMinutes = travelTime / 60 // Convert time to minutes
                        let formattedTravelTime = String(format: "%.2f", travelTimeInMinutes)
                        
                        print("Distance: \(distance) miles, Estimated travel time: \(travelTimeInMinutes) minutes")
                        DispatchQueue.main.async {
                            self.distanceAndTimeText = "\(formattedTravelTime) min - \(String(format: "%.2f", distance)) mi"
                        }
                        
                    }
                 
                 distanceAndTimeText = estimateDrivingTimeAndDistance(lat1: locationViewModel.latitude, lon1: locationViewModel.longitude, lat2: routelatitude!, lon2: routelongitude!, averageSpeedInMPH: 30)
                
                  */
                    
                   
                    
                    
                }
            }
            //.onChange(of: locationViewModel.currentLocation) { _ in
            //                checkWaypointsAndUpdate()
            //            }
        
            .onDisappear {
                        UIApplication.shared.isIdleTimerDisabled = false
                    locationViewModels.stopTimer()
                locationViewModel.stopLocationUpdates()
                    }
        
            .onAppear {
                
                //speak(text: "Proceed to the route, please remember to keep left")
                SpeechManager.shared.speak(text: "Proceed to the route, please remember to keep left. Now navigating to \(thissite) ")
                
               // locationViewModel.loadWaypoints()
              //  locationViewModels.startTimer(loadlat:latitude!, loadlong:longitude! ,routelatitude: routelatitude!, routelongitude: routelongitude!)
                //listAvailableVoices()
                UIApplication.shared.isIdleTimerDisabled = true
                 
                
                print("location1: \(thislocation)")
                print("location2: \(thisroute)")
                print("place: \(thisplace)")
                
                
                //self.annotations = createAnnotations(latitude: locationViewModel.latitude, longitude: locationViewModel.longitude)
                
                region.center = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                
                print("loading location - Latitude: \(latitude!), Longitude: \(longitude!)")
                
                
                let startCoordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!) // Example start
                let endCoordinate = CLLocationCoordinate2D(latitude: routelatitude!, longitude: routelongitude!) // Example end
                
                
           /*
                calculateDistanceAndTime(from: startCoordinate, to: endCoordinate) { distance, travelTime in
                    let travelTimeInMinutes = travelTime / 60 // Convert time to minutes
                    let formattedTravelTime = String(format: "%.2f", travelTimeInMinutes)
                    print("Distance: \(distance) miles, Estimated travel time: \(travelTimeInMinutes) minutes")
                    DispatchQueue.main.async {
                        self.distanceAndTimeText = "\(formattedTravelTime) min - \(String(format: "%.2f", distance)) mi"
                    }
                    
                }//end calculate
            
            distanceAndTimeText = loadestimateDrivingTimeAndDistance(lat1: latitude!, lon1: longitude!, lat2: routelatitude!, lon2: routelongitude!, averageSpeedInMPH: 30)
            
            
             */
                
                
             /*
                let startAnnotation = MKPointAnnotation()
                startAnnotation.coordinate = startCoordinate
                startAnnotation.title = "Start"
                
                let endAnnotation = MKPointAnnotation()
                endAnnotation.coordinate = endCoordinate
                endAnnotation.title = "End"
                
                annotations = [startAnnotation, endAnnotation]
               */
                
                calculateRoute(from: startCoordinate, to: endCoordinate) { newRoute in
                    if let newRoute = newRoute {
                        print("Route calculated")
                        self.route = newRoute // Set the route here
                        
                    } else {
                        print("Failed to calculate route")
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    

    
    func checkWaypointsAndUpdate() {
        guard let currentLocation = locationViewModel.currentLocation else { return }
        
        for (index, waypoint) in waypoints.enumerated().reversed() {
            let waypointLocation = CLLocation(latitude: waypoint.coordinate.latitude, longitude: waypoint.coordinate.longitude)
            let distance = currentLocation.distance(from: waypointLocation)
            let bearingDifference = abs(locationViewModel.currentBearing - waypoint.bearing)
            
            if distance <= waypoint.triggerrange,
               bearingDifference <= 20 || (360 - bearingDifference) <= 20 {
               
                speechSynthesizer.speak(AVSpeechUtterance(string: waypoint.speak))
                waypoints.remove(at: index)
            }
        }
    }
 

  

    
    
   

    func calculateDistanceAndTime(from startCoordinate: CLLocationCoordinate2D,
                                  to endCoordinate: CLLocationCoordinate2D,
                                  completion: @escaping (Double, TimeInterval) -> Void) {
        
        print("Start point: \(startCoordinate.latitude), \(startCoordinate.longitude)")
        print("End point: \(endCoordinate.latitude), \(endCoordinate.longitude)")

        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
        request.transportType = .automobile // You can change this for different transportation types

        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let route = response?.routes.first else {
                print("Error or no route found: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let distanceInMeters = route.distance // Distance in meters
            let distanceInMiles = distanceInMeters / 1609.34 // Convert to miles
            let travelTimeInSeconds = route.expectedTravelTime // Travel time in seconds
  
            print("****MILES****: \(distanceInMiles)")
         
            completion(distanceInMiles, travelTimeInSeconds)
        }
    }

    
    func calculateRoute(from startCoordinate: CLLocationCoordinate2D, to endCoordinate: CLLocationCoordinate2D, completion: @escaping (MKRoute?) -> Void) {
        let startPlacemark = MKPlacemark(coordinate: startCoordinate)
        let endPlacemark = MKPlacemark(coordinate: endCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startPlacemark)
        request.destination = MKMapItem(placemark: endPlacemark)
        request.transportType = .automobile // For driving directions
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                completion(nil)
                return
            }
            completion(route)
        }
    }
    /*
    func createAnnotations() -> [MKPointAnnotation] {
        print("Creating annotations...")
        
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = CLLocationCoordinate2D(latitude: 18.193972099377174, longitude: -63.08687167724191)
        startAnnotation.title = "Start"
        print("Start annotation created at \(startAnnotation.coordinate.latitude), \(startAnnotation.coordinate.longitude)")

        
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = CLLocationCoordinate2D(latitude: 18.216293088322242, longitude: -63.05352554035603)
        endAnnotation.title = "End"
        print("End annotation created at \(endAnnotation.coordinate.latitude), \(endAnnotation.coordinate.longitude)")

        
        return [startAnnotation, endAnnotation]
    }

  */
    
    /*
    func createAnnotations(latitude: Double, longitude: Double) -> [MKPointAnnotation] {
        print("Creating annotations...")
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = "Location"
        print("Annotation created at \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")
        return [annotation]
    }
     */


    
    func getwaymarkers() -> String {
        let url = "https://xcape.ai/navigation/loadwaymarkers.php"
        // let url = "https://punchclock.ai/capturePin.php"

       // print("action url: \(url)")
        let session = URLSession.shared

        var responseLocation = ""
        let semaphore = DispatchSemaphore(value: 0)

        guard let urlObj = URL(string: url) else {
            return ""
        }

        var request = URLRequest(url: urlObj)
        request.httpMethod = "POST"
        let body = "getdevice=thisDevice"
        request.httpBody = body.data(using: .utf8)

        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                semaphore.signal()
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                //print("Response code: \(httpResponse.statusCode)")
            }

            if let data = data {
                if let resp = String(data: data, encoding: .utf8) {
                    responseLocation = resp
                    print("respBody:main \(responseLocation)")
                }
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()

        return responseLocation
    }
    
    
    
    func createAnnotations(latitude: Double?, longitude: Double?) -> [MKPointAnnotation] {
        guard let latitude = latitude, let longitude = longitude else {
            print("Invalid coordinates: latitude or longitude is nil")
            return []
        }

        print("Creating annotations with latitude: \(latitude), longitude: \(longitude)")
        
        print("Creating annotations...")
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = "Location"
        print("Annotation created at \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")

        return [annotation]
        
    }
 
    func speaker(text: String) {
        print("speaking: \(text)")
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US") // You can choose the language
        speechSynthesizer.speak(speechUtterance)
    }
    
    
    func speak(text: String ) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)

        defer {
            disableAVSession()
        }
    }

    private func disableAVSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't disable.")
        }
    }
    
    
    
    func listAvailableVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            print("Voice Identifier: \(voice.identifier), Language: \(voice.language)")
        }
    }

  
    
    
}//end
    

    
    

struct PickupView_Previews: PreviewProvider {
    static var previews: some View {
        PickupView(thislocation: "String",thisplace: "String",thisroute: "String", thissite: "String", locationViewModel: LocationViewModel())
    }
}
