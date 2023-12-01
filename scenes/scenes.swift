//
//  scenes.swift
//  scenes
//
//  Created by Inigo Surguy on 30/11/2023.
//

import WidgetKit
import SwiftUI
import os

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct scenesEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        let destinations = ["Jungle", "Cocoa Beach", "Blaze", "Date Night", "Starlight"]
        
        VStack(spacing: 5) {
            ForEach(destinations, id: \.self) { destination in
                Link(destination, destination: URL(string: "nanoleafwidget://\(destination.replacingOccurrences(of: " ", with: ""))")!)
            }
        }
    }
}

struct scenes: Widget {
    let kind: String = "scenes"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            scenesEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
