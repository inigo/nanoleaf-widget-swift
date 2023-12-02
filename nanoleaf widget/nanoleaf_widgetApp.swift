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
                    
                    logger.log("Launching scene yet more: \(sceneName, privacy: .public)")
                    
//                    let ipAddressAndPort: String? = "192.168.5.121:16021"
//                    let authToken: String? = "p8rTNKJ0TaCLORJD12uWMHiVGs2Wnp9c"
//                    
                    var ipAddressAndPort: String? = UserDefaults.standard.object(forKey: "ipAddressAndPort") as? String

                    if (ipAddressAndPort==nil) {
                        ipAddressAndPort = "192.168.5.121:16021"
                        UserDefaults.standard.set(ipAddressAndPort, forKey: "ipAddressAndPort")
                    }

                    if let ipAddressAndPort = ipAddressAndPort {
                        logger.info("IP address and port is \(ipAddressAndPort, privacy: .public)")
                    } else {
                        logger.info("IP address and port is not set")
                    }


                    var authToken = UserDefaults.standard.object(forKey: "authToken") as? String
                    if (authToken==nil) {
                        authToken = "p8rTNKJ0TaCLORJD12uWMHiVGs2Wnp9c"
                        UserDefaults.standard.set(authToken, forKey: "authToken")
                    }

                    if let authToken = authToken {
                        logger.info("Auth token is \(authToken, privacy: .public)")
                    } else {
                        logger.info("Auth token is not set")
                    }
                    

         
                    Task {
                        var result: Data // Replace 'ResultType' with the actual type returned by changeScene
                        do {
                            result = try await changeScene(sceneName: sceneName, ipAddressAndPort: ipAddressAndPort ?? "192.168.5.121:16021", authToken: authToken ?? "p8rTNKJ0TaCLORJD12uWMHiVGs2Wnp9c")
                            // You can use 'result' here if needed
                        } catch {
                            result = Data()
                            // Log the error here
                            logger.error("An error occurred: \(error.localizedDescription, privacy: .public)")
                        }
                        NSApp.terminate(nil)
                        return result
                    }


                    
                }
            }
        }
    }
    
}

internal func showAlertDialog() {
    let alert = NSAlert()
    alert.messageText = "Not authorized to access Nanoleaf"
    alert.informativeText = "Please hold down the power button (the leftmost button) for 5 seconds to put your Nanoleaf into pairing mode"
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")

    alert.runModal()
}


internal func addSpacesToCamelCase(_ input: String) -> String {
    return input.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
}

internal func getAuthToken(ipAddressAndPort: String) async -> String? {
    do {
        let data = try await sendHttpRequest(urlString: "http://\(ipAddressAndPort)/api/v1/new", method: "POST")
        return extractAuthToken(from: data)
    } catch {
        print("Error \(error)")
        return nil
    }
}

internal func extractAuthToken(from: Data) -> String? {
    do {
        let json = try JSONSerialization.jsonObject(with: from, options: []) as! [String: String]
        if let authToken = json["auth_token"] {
            print("Auth Token: \(authToken)")
            return authToken
        } else {
            print("Auth token not found")
            return nil
        }
    } catch {
        print("Could not extract auth token from response")
        return nil
    }
}

internal func changeScene(sceneName: String, ipAddressAndPort: String, authToken: String) async throws -> Data {
    let urlString = "http://\(ipAddressAndPort)/api/v1/\(authToken)/effects"
    let method = "PUT"
    let bodyDictionary = [ "select": sceneName ]
    
    logger.info("Sending HTTP request to \(urlString, privacy: .public)")
    
    print("Sending request to "+urlString)
    return try await sendHttpRequest(urlString: urlString, method: method, bodyDictionary: bodyDictionary)
}

internal func sendHttpRequest(urlString: String, method: String, bodyDictionary: Dictionary<String, String>? = nil) async throws -> Data {
    guard let url = URL(string: urlString) else { fatalError("Invalid URL \(urlString)") }

    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let bodyDictionary = bodyDictionary {
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDictionary)
    }

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        logger.warning("Server response is \(data, privacy: .public)")
        throw URLError(.badServerResponse)
    }

    if httpResponse.statusCode >= 400 {
//        throw URLError(.init(rawValue: httpResponse.statusCode))
        logger.warning("Unexpected status code \(httpResponse.statusCode, privacy: .public) with text \(data, privacy: .public)")
        throw NSError(domain: "httpRequest", code: httpResponse.statusCode, userInfo: ["data": data])
    }

    return data
}

