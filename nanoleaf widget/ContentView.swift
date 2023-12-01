//
//  ContentView.swift
//  nanoleaf widget
//
//  Created by Inigo Surguy on 30/11/2023.
//
//https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Nanoleaf thingie!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
