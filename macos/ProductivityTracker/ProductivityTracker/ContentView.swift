//
//  ContentView.swift
//  ProductivityTracker
//
//  Created by Paris Phan on 12/27/24.
//
import SwiftUI

struct ContentView: View {
    @ObservedObject var logger = ActivityLogger.shared

    var body: some View {
        VStack {
            Text("Productivity Tracker")
                .font(.largeTitle)
                .padding()

            List(logger.logs, id: \.self) { log in
                Text(log)
            }
            .frame(height: 300)
            .border(Color.gray)

            Button("Start Tracking") {
                logger.startLogging()
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
