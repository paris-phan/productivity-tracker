//
//  ContentView.swift
//  ProductivityTrackerIOS
//
//  Created by Paris Phan on 12/27/24.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @State private var authorizationStatus: String = "Not authorized"
    @State private var selection = FamilyActivitySelection()
    @StateObject private var activityManager = DeviceActivityManager.shared

    var body: some View {
        VStack {
            Image(systemName: "clock")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Screen Time Tracker")
                .font(.title)
                .padding()

            Text(authorizationStatus)
                .padding()

            Button(action: requestAuthorization) {
                Text("Request Authorization")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            FamilyActivityPicker(selection: $selection)
                .familyActivityPickerStyle(.navigationLink)
                .padding()
            
            Button(action: activityManager.startMonitoring) {
                Text("Start Monitoring")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            // Display collected data
            List(Array(activityManager.activityReport.keys), id: \.self) { app in
                HStack {
                    Text(app)
                    Spacer()
                    Text(formatTimeInterval(activityManager.activityReport[app] ?? 0))
                }
            }
        }
        .padding()
        .navigationTitle("Screen Time Tracker")
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        return "\(hours)h \(minutes)m"
    }

    func requestAuthorization() {
        AuthorizationCenter.shared.requestAuthorization { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    authorizationStatus = "Authorized"
                case .failure(let error):
                    authorizationStatus = "Authorization failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
