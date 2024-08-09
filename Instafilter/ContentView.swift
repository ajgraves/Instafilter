//
//  ContentView.swift
//  Instafilter
//
//  Created by Aaron Graves on 8/8/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No snippets", systemImage: "swift")
        } description: {
            Text("You don't have any saved snippets yet.")
        } actions: {
            Button("Create snippet") {
                //Create a snippet
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ContentView()
}
