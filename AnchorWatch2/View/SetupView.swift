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
            Text("view.setup.title")
                .font(.headline)
                .padding()
            
            Text("view.setup.explain.while")
                .font(.callout)
                .padding()
            
            HStack {
                Button("view.setup.whileUsing") {
                    viewModel.requestWhenInUseAuthorization()
                }
                .disabled(authStatusListener.allowsWhileUsing())
                .buttonStyle(.bordered)
                .padding()
                
                Image(systemName: "checkmark.seal")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(authStatusListener.allowsWhileUsing() ? .green : .red)
            }
            
            Text("view.setup.explain.always")
                .font(.callout)
                .padding()
            
            HStack {
                Button("view.setup.alwaysAllow") {
                    viewModel.requestAlwaysAuthorization()
                }
                .disabled(authStatusListener.allowAlways())
                .padding()
                .buttonStyle(.bordered)
                
                Image(systemName: "checkmark.seal")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(authStatusListener.allowAlways() ? .green : .red)

            }

            Text("view.setup.warn.wifi")
                .font(.callout)
                .padding()
            
            HStack() {
                Spacer()
                Button("view.setup.done.button") {
                    doneSetup.wrappedValue = true
                    UserDefaults.standard.set(doneSetup.wrappedValue, forKey: "doneSetup")
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
