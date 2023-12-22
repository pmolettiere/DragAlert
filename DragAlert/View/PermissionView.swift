//
//  SetupView.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/13/23.
//
//    Copyright (C) <2023>  <Peter Molettiere>
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI
import MapKit

struct PermissionView: View {
    @Environment(ViewModel.self) private var viewModel

    @State var authStatusListener: AuthStatusListener = AuthStatusListener()

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
                    UserDefaults.standard.set(true, forKey: "doneSetup")
                    viewModel.setAppView( .setup )
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
