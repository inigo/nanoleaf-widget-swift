//
//  nanoleaf_widgetApp.swift
//  nanoleaf widget
//
//  Created by Inigo Surguy on 30/11/2023.
//

import SwiftUI
import os
import Foundation
import Combine


let logger = Logger(subsystem: "net.surguy.nanoleafwidget", category: "widgetview")

private var cancellables = Set<AnyCancellable>()

@main
struct nanoleaf_widgetApp: App {

    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                if url.scheme == "nanoleafwidget" {
                    let urlValue = url.host()!
                    var sceneName = addSpacesToCamelCase(urlValue)
                    logger.log("Original value was \(urlValue, privacy: .public) from \(url.absoluteString, privacy: .public)")
                    print("Main app is launching "+sceneName)
                    
                    if (sceneName.isEmpty) { sceneName = "Jungle" }
                    
                    logger.log("Launching the scene \(sceneName, privacy: .public)")
                    changeScene(scene: sceneName)
                    NSApp.terminate(nil)
                }
            }
        }
    }
    
}

internal func changeScene(scene: String) {
    print("Change scene happening")
    logger.log("In changeScene and launching scene \(scene, privacy: .public)")
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/Users/inigosurguy/Code/nanoleaf-widget/main.py")
    process.arguments = [scene]
    
    let pipe = Pipe()
    process.standardOutput = pipe
    
    do {
        try process.run()
        process.waitUntilExit()
        
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: outputData, encoding: .utf8) {
            print("Script output: \(output)")
            logger.info("Script output: \(output, privacy: .public)")
        } else {
            logger.info("Failed to convert output data to string.")
            print("Failed to convert output data to string.")
        }
    } catch {
        logger.warning("An error occurred: \(error, privacy: .public)")
    }

}

internal func addSpacesToCamelCase(_ input: String) -> String {
    return input.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
}

internal func getAuthCode(ipAddressAndPort: String) async -> String? {
    do {
        let data = try await otherSendHttpRequest(urlString: "http://\(ipAddressAndPort)/api/v1/new", method: "POST")
        return extractAuthToken(from: data)
    } catch {
        print("Error \(error)")
        return nil
    }
}

internal func extractAuthToken(from: Data) -> String? {
    do {
        let json = try JSONSerialization.jsonObject(with: from, options: []) as! [String: String]
        // Extract the token
        if let authToken = json["auth_token"] {
            print("Auth Token: \(authToken)")
            return authToken
            // Use the token as needed
        } else {
            print("Auth token not found")
            return nil
        }
    } catch {
        print("Could not extract auth token from response")
        return nil
    }
}

//internal func sendSceneChangeRequest(sceneName: String, ipAddressAndPort: String, authToken: String) -> Future<Data, Error> {
//    let urlString = "http://\(ipAddressAndPort)/api/v1/\(authToken)/effects"
//    let method = "PUT"
//    let bodyDictionary = [ "select": sceneName ]
//    
//    print("Sending request to "+urlString)
//    return sendHttpRequest(urlString: urlString, method: method, bodyDictionary: bodyDictionary)
//}


internal func otherSendSceneChangeRequest(sceneName: String, ipAddressAndPort: String, authToken: String) async throws -> Data {
    let urlString = "http://\(ipAddressAndPort)/api/v1/\(authToken)/effects"
    let method = "PUT"
    let bodyDictionary = [ "select": sceneName ]
    
    print("Sending request to "+urlString)
    return try await otherSendHttpRequest(urlString: urlString, method: method, bodyDictionary: bodyDictionary)
}

//internal func sendHttpRequest(urlString: String, method: String, bodyDictionary: Dictionary<String, String>? = nil) -> Future<Data, Error> {
//    
//    guard let url = URL(string: urlString) else { fatalError("Invalid URL \(urlString)") }
//
//    var request = URLRequest(url: url)
//    request.httpMethod = method
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    if (bodyDictionary != nil) {
//        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDictionary!)
//    }
//
//    return Future<Data, Error> { promise in
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                promise(.failure(error))
//            } else if let data = data {
//                let httpResponse = response as! HTTPURLResponse
//                if  (httpResponse.statusCode >= 400) {
//                    // Could I reasonably create a URLError not an NSError?
//                    let error = NSError(domain: "httpRequest", code: httpResponse.statusCode, userInfo: ["data": data])
//                    promise(.failure(error))
//                } else {
//                    promise(.success(data))
//                }
//            } else {
//                promise(.failure(URLError(.badServerResponse)))
//            }
//        }
//        
//        task.resume()
//    }
//}

internal func otherSendHttpRequest(urlString: String, method: String, bodyDictionary: Dictionary<String, String>? = nil) async throws -> Data {
    guard let url = URL(string: urlString) else { fatalError("Invalid URL \(urlString)") }

    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let bodyDictionary = bodyDictionary {
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDictionary)
    }

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }

    if httpResponse.statusCode >= 400 {
//        throw URLError(.init(rawValue: httpResponse.statusCode))
        throw NSError(domain: "httpRequest", code: httpResponse.statusCode, userInfo: ["data": data])
    }

    return data
}

