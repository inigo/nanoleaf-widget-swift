//
//  nanoleaf_widgetApp.swift
//  nanoleaf widget
//
//  Created by Inigo Surguy on 30/11/2023.
//

import SwiftUI
import os
import Foundation


let logger = Logger(subsystem: "net.surguy.nanoleafwidget", category: "widgetview")

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
//    process.executableURL = URL(fileURLWithPath: "/Users/inigosurguy/Code/nanoleaf-widget/main.py")which more
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
