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
    
    struct LinkItem: Hashable {
        let emoji: String
        let name: String
    }
    
    func scenesToDestinations(sceneText: String)->[LinkItem] {
        let scenes = sceneText.split(separator: ",", omittingEmptySubsequences: true)
        return scenes.map{ s in s.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter{ s in !s.isEmpty }
            .map{ s in LinkItem(emoji: String(s.first!), name: s.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)) }
    }
    
    func getDestinationsFromConfig()->[LinkItem] {
        var sceneText: String = entry.configuration.scenes
        if (sceneText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            sceneText = "🏖 Cocoa Beach, 🌲 Jungle, 🔥 Blaze, 💖 Date Night, 🌟 Starlight, 🎁 Merry Christmas"
        }
        return scenesToDestinations(sceneText: sceneText)
    }

    var body: some View {
        let destinations = getDestinationsFromConfig()

        VStack(spacing: 5) {
            ForEach(0..<3) { rowIndex in // 3 rows
                HStack(spacing: 15) {
                    ForEach(0..<2) { columnIndex in // 2 columns
                        let offset = rowIndex * 2 + columnIndex
                        if offset < destinations.count {
                            let d = destinations[offset]
                            Link(destination: URL(string: "nanoleafwidget://\(d.name.replacingOccurrences(of: " ", with: ""))")!) {
                                Text(d.emoji).font(.system(size: 40))
                            }.help(d.name)
                        }
                    }
                }
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
