//
//  SetupView.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/13/23.
//

import SwiftUI
import MapKit

struct SetupView: View {
    @Environment(ViewModel.self) private var viewModel
    
    @State var authStatusListener: AuthStatusListener = AuthStatusListener()
    var doneSetup: Binding<Bool>

    var body: some View {
        VStack(alignment: .center) {
            Text("Permission Required")
                .font(.headline)
                .padding()
            
            Text("Anchor Watch tracks your vessel's location to determine whether your vessel is within your intended anchoring radius. To work, the app requires the 'While Using' permission to access your location.")
            
            HStack {
                Button("Allow While Using") {
                    viewModel.requestWhenInUseAuthorization()
                }
                .disabled(authStatusListener.allowsWhileUsing())
                .buttonStyle(.bordered)
                .padding()
                
                Image(systemName: "checkmark.seal")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(authStatusListener.allowsWhileUsing() ? .green : .red)
            }
            
            Text("If you want the app to monitor your location from the background, then it also needs the 'Always Allow' permission.")
            HStack {
                Button("Always Allow") {
                    viewModel.requestAlwaysAuthorization()
                }
                .disabled(authStatusListener.allowAlways())
                .padding()
                .buttonStyle(.bordered)
                
                Image(systemName: "checkmark.seal")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(authStatusListener.allowAlways() ? .green : .red)

            }

            Text("You should keep your WiFi enabled while using this app, as turning it off disables your GPS.")
            
            HStack() {
                Spacer()
                Button("Done") {
                    doneSetup.wrappedValue = true
                    UserDefaults.standard.set(doneSetup.wrappedValue, forKey: "doneSetup")
                    viewModel.isTrackingLocation(isTracking: true)
                }
                .disabled(!authStatusListener.allowsWhileUsing())
                .padding()
                .buttonStyle(.bordered)
            }
        }
        .onAppear() {
            viewModel.requestAuthStatus()
        }
    }
}

@Observable
class AuthStatusListener {
    var authStatus: CLAuthorizationStatus = .notDetermined
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(authStatusDidChange), name: LocationNotifications.authStatus.asNotificationName(), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: LocationNotifications.authStatus.asNotificationName(), object: nil)
    }
    
    @objc func authStatusDidChange(notification: Notification) {
        let lasn: LocationAuthStatusNotification = notification.object as! LocationAuthStatusNotification
        authStatus = lasn.authStatus
    }
    
    func allowsWhileUsing() -> Bool {
        authStatus == CLAuthorizationStatus.authorizedWhenInUse || authStatus == CLAuthorizationStatus.authorizedAlways
    }
    
    func allowAlways() -> Bool {
        authStatus == CLAuthorizationStatus.authorizedAlways
    }
}

//#Preview {
//    SetupView()
//}
