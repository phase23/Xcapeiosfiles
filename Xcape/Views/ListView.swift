//
//  ListView.swift
//  Xcape
//
//  Created by Wilson Jno-Baptiste on 1/25/24.
//

import SwiftUI
import CoreLocation
import Combine
import AVFoundation


struct ListView: View {
   // @State private var loadactivity = ""
    @State private var loadactivity: [String: String] = [:]
   // @State private var list = ""
    @State private var list: String? = nil // Variable to store cunq
    
    @State private var showList = false
    @State private var cordin = ""
    // private let locationViewModel = LocationViewModel()
    @State private var placeid = ""
    @State private var site = ""
    @State private var route = ""
    @ObservedObject var locationViewModel: LocationViewModel
    var body: some View {
        
        NavigationLink(destination: LoaditemsView(thislocation: cordin,thisplace:placeid,thisroute: route, thissite: site, locationViewModel: locationViewModel), isActive: $showList) {
            EmptyView()
        }
      
            
        VStack{
            Text("Select your activity")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .padding(.bottom,10)
                .padding(25)
            
            ScrollView {
                VStack {
                    ForEach(Array(loadactivity.keys).sorted(), id: \.self) { key in
                              if let activity = loadactivity[key] {
                                  Button(action: {
                                      print("Selected activity key: \(key), activity: \(activity)")
                                      let latt = locationViewModel.latitude
                                      let longg = locationViewModel.longitude
                                      print("prelosd: \(latt),\(longg)")
                                      cordin = "\(latt),\(longg)"
                                      list = key
                                      UserDefaults.standard.set(list, forKey: "list")
                                      showList = true
                                  }) {
                                      HStack {
                                          Image("beachmap32")   // Replace with your desired icon
                                              .foregroundColor(.yellow)    // Optional: Set the color of the icon
                                            Text(activity)
                                                  .frame(maxWidth: .infinity, alignment: .leading) // Aligns text to the left
                                                  .padding()
                                          }
                                      .background(Color.lightBlue)
                                      .foregroundColor(.black)
                                      .cornerRadius(10)
                                      .padding(4)
                                  }
                              }
                          }

                          // Manually adding extra buttons
                          Button(action: {
                              // Define action for this button
                              print("Extra Button 1 Tapped")
                          }) {
                              Text("Extra Button 1")
                                  .padding()
                                  .frame(maxWidth: .infinity)
                                  .background(Color.red)
                                  .foregroundColor(.white)
                                  .cornerRadius(10)
                                  .padding(4)
                          }

                          Button(action: {
                              // Define action for this button
                              print("Extra Button 2 Tapped")
                          }) {
                              Text("Extra Button 2")
                                  .padding()
                                  .frame(maxWidth: .infinity)
                                  .background(Color.orange)
                                  .foregroundColor(.white)
                                  .cornerRadius(10)
                                  .padding(4)
                          }
                    
                       }
                      }
                  }
                
                .onAppear {
                    //timerManager.start()
                    
                    parseJson()
                    
                   
                   print("loading")
                    
                    
                }
            
            
        }//end vstact1
        
     


func parseJson() {
    let jsonString =  doGetRequest()
    print("device: \(jsonString)")
    if let data = jsonString.data(using: .utf8) {
        do {
            loadactivity = try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}



func doGetRequest() -> String {
    guard let thisDevice = UIDevice.current.identifierForVendor?.uuidString else {
        return ""
    }
    
    let url = "https://xcape.ai/navigation/loadactivities.php"
    
    
    print("action url: \(url)")
    let session = URLSession.shared
    
    var responseLocation = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    guard let urlObj = URL(string: url) else {
        return ""
    }
    
    var request = URLRequest(url: urlObj)
    request.httpMethod = "POST"
    let body = "getdevice=\(thisDevice)"
    request.httpBody = body.data(using: .utf8)
    
    let task = session.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            semaphore.signal()
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response code: \(httpResponse.statusCode)")
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
}

struct Waypoint: Decodable {
    let latlng: String
    let speak: String
    let bearing: Double
    let triggerrange: Double
    var coordinate: CLLocationCoordinate2D {
        let latLon = latlng.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 }
        return CLLocationCoordinate2D(latitude: latLon[0], longitude: latLon[1])
    }
    enum CodingKeys: String, CodingKey {
        case latlng, speak, bearing, triggerrange
    }
    
}
extension Color {
    static let lightBlue = Color(red: 173 / 255, green: 216 / 255, blue: 230 / 255)
    static let lightGrey = Color(red: 211 / 255, green: 211 / 255, blue: 211 / 255)

}
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(locationViewModel: LocationViewModel())
    }
}
