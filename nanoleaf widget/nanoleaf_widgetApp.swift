//
//  nanoleaf_widgetApp.swift
//  nanoleaf widget
//
// Files are:
//      ~/Library/Preferences/net.surguy.nanoleaf-widget.plist
//              cd ~/Library/Preferences
//              defaults read net.surguy.nanoleaf-widget.plist ipAddressAndPort
//              defaults read net.surguy.nanoleaf-widget.plist authToken
//      ~/Library/Caches/net.surguy.nanoleaf-widget
//      ~/Library/Containers/net.surguy.nanoleaf-widget.scenes
//      ~/Library/Containers/net.surguy.nanoleaf-widget
//
//  Created by Inigo Surguy on 30/11/2023.
//

import SwiftUI
import os
import Foundation
import Combine
import Network


let logger = Logger(subsystem: "net.surguy.nanoleafwidget", category: "widgetview")

private var cancellables = Set<AnyCancellable>()

@main
struct nanoleaf_widgetApp: App {
    
    init() {
        ensureConnectionKnown()
    }
    
    
    func ensureConnectionKnown() {
        var ipAddressAndPort: String? = UserDefaults.standard.object(forKey: "ipAddressAndPort") as? String
        let authToken: String? = UserDefaults.standard.object(forKey: "authToken") as? String
                
        if ipAddressAndPort==nil {
            logger.log("No IP address found - searching now...")
            ipAddressAndPort = lookupAddress()
            logger.log("Retrieved IP address: \(ipAddressAndPort ?? "nil", privacy: .public)")
            UserDefaults.standard.set(ipAddressAndPort, forKey: "ipAddressAndPort")
        }
        
        if let safeIpAddressAndPort = ipAddressAndPort {
            logger.log("IP address is : \(safeIpAddressAndPort, privacy: .public)")
            if authToken==nil {
                Task {
                    logger.log("Looking up auth token")
                    var newAuthToken = await getAuthToken(ipAddressAndPort: safeIpAddressAndPort)
                    if let safeAuthToken = newAuthToken {
                        UserDefaults.standard.set(safeAuthToken, forKey: "authToken")
                    } else {
                        logger.warning("No auth token available - probably need to hold the power button to put light in pairing mode")
                        showAlertDialog() // Only doing this once to be less annoying - will repeat on next click
                        newAuthToken = await getAuthToken(ipAddressAndPort: safeIpAddressAndPort)
                        if let safeAuthToken = newAuthToken {
                            UserDefaults.standard.set(safeAuthToken, forKey: "authToken")
                        }
                    }
                }
            }
        }
    }
    
    func lookupAddress() -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var retrievedIpAddressAndPort: String? = nil

        class LocalExpectation: Expectation {
                let semaphore: DispatchSemaphore
                var setter: (String) -> Void

                init(semaphore: DispatchSemaphore, setter: @escaping (String) -> Void) {
                    self.semaphore = semaphore
                    self.setter = setter
                }

                func setIpAddressAndPort(ipAddressAndPort: String) {
                    setter(ipAddressAndPort)
                }
                
                func fulfill() {
                    semaphore.signal()
                }
            }
        
        let expectation = LocalExpectation(semaphore: semaphore) { newValue in
            retrievedIpAddressAndPort = newValue
        }
        let serviceDiscovery = ServiceDiscovery(expectation: expectation)
        serviceDiscovery.startBrowsing()
        
        DispatchQueue.global().async {
            if semaphore.wait(timeout: .now() + 10) == .timedOut {
                logger.log("Timeout reached")
            } else {
                logger.log("IP address and port set to: \(retrievedIpAddressAndPort ?? "nil", privacy: .public)")
                // Setting here, because this isn't passed back - probably because it is async
                UserDefaults.standard.set(retrievedIpAddressAndPort, forKey: "ipAddressAndPort")
            }
        }
        return retrievedIpAddressAndPort
    }

    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                if url.scheme == "nanoleafwidget" {
                    let urlValue = url.host()!
                    var sceneName = addSpacesToCamelCase(urlValue)
                    logger.log("Original value was \(urlValue, privacy: .public) from \(url.absoluteString, privacy: .public)")
                    print("Main app is launching "+sceneName)
                    
                    if (sceneName.isEmpty) { sceneName = "Jungle" }
                    
                    logger.log("Launching scene: \(sceneName, privacy: .public)")
                    
                    ensureConnectionKnown()

                    let ipAddressAndPort: String? = UserDefaults.standard.object(forKey: "ipAddressAndPort") as? String
                    if let ipAddressAndPort = ipAddressAndPort {
                        logger.info("IP address and port is \(ipAddressAndPort, privacy: .public)")
                    } else {
                        logger.info("IP address and port is not set")
                    }

                    let authToken = UserDefaults.standard.object(forKey: "authToken") as? String
                    if let authToken = authToken {
                        logger.info("Auth token is \(authToken, privacy: .public)")
                    } else {
                        logger.info("Auth token is not set")
                    }
                    
                    if let safeAuthToken = authToken, let safeIpAddressAndPort = ipAddressAndPort {
                        Task {
                            var result: Data
                            do {
                                result = try await changeScene(sceneName: sceneName, ipAddressAndPort: safeIpAddressAndPort, authToken: safeAuthToken)
                            } catch {
                                result = Data()
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


protocol Expectation {
    func fulfill()
    func setIpAddressAndPort(ipAddressAndPort: String)
}

class ServiceDiscovery {
    private var browser: NWBrowser?
    private var expectation: Expectation?
    
    init(expectation: Expectation? = nil) {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        self.expectation = expectation

        let browserDescriptor = NWBrowser.Descriptor.bonjour(type: "_nanoleafapi._tcp", domain: "local")
        self.browser = NWBrowser(for: browserDescriptor, using: parameters)
    }

    internal func startBrowsing() {
        self.browser?.start(queue: .main)
        self.browser?.browseResultsChangedHandler = { results, changes in
            if let result = results.first {
                self.resolveService(result)
            }
        }
    }
        
    func getConnectionParams() -> NWParameters {
        let options = NWProtocolTCP.Options()
        options.enableFastOpen = true
        options.connectionTimeout = 10
        
        let params = NWParameters(tls: nil, tcp: options)
        params.includePeerToPeer = true

        // There is both an ipv4 and an ipv6; this forces it to use ipv4. ipv6 does not appear to be accessible
        let ip = params.defaultProtocolStack.internetProtocol! as! NWProtocolIP.Options
        ip.version = .v4
        
        return params
    }
    
    func resolveService(_ result: NWBrowser.Result) {
        let connection = NWConnection(to: result.endpoint, using: getConnectionParams())

        connection.stateUpdateHandler = { state in
            if state == .ready {
                if let path = connection.currentPath, let endpoint = path.remoteEndpoint {
                    switch endpoint {
                        case .hostPort(let host, let port):
                        let ipAddress = host.debugDescription.components(separatedBy: "%").first ?? host.debugDescription
                        
                        var ipAddressAndPort = ""
                        switch host {
                        case .ipv6:
                            ipAddressAndPort = "[\(ipAddress)]:\(port)"
                        default:
                            ipAddressAndPort = "\(ipAddress):\(port)"
                        }

                        logger.log("IP address and port is \(ipAddressAndPort, privacy: .public)")
                        self.expectation?.setIpAddressAndPort(ipAddressAndPort: ipAddressAndPort)
                        default:
                            break
                    }
                }
                
                self.expectation?.fulfill()
            }
        }

        connection.start(queue: .main)
    }


}


