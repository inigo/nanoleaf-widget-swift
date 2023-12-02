//
//  AppIntent.swift
//  scenes
//
//  Created by Inigo Surguy on 30/11/2023.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Nanoleaf scene changer widget.")

    @Parameter(title: "Scene names (comma-separated, first character will be the icon)", default: "🌲 Jungle, 🏖 Cocoa Beach, 🔥 Blaze, 💖 Date Night, 🌟 Starlight, 🎁 Merry Christmas")
    var scenes: String
}
