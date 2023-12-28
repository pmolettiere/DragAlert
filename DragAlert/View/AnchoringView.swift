//
//  AnchoringView.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/6/23.
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

struct AnchoringView: View {
    @Environment(ViewModel.self) private var viewModel
    @State var model: AnchoringViewModel
    
    @MainActor
    init(model: AnchoringViewModel, state: EditState) {
        _model = State( initialValue: model )
        model.willEdit = state
        //print("AnchoringView.init()")
    }
    
    enum TabState : Int {
        case relative = 0, current
    }
    
    var body: some View {
        TabView(selection: $model.selectedTab) {
            RelativeView(model: model)
                .tag(TabState.relative)
                .tabItem {
                    Label("view.anchoring.relative", systemImage: "location.north.line.fill")
                }
                .padding()
            CurrentView(model: model)
                .tag(TabState.current)
                .tabItem {
                    Label("view.anchoring.current", systemImage: "location.fill")
                }
                .padding()
        }
        .onAppear() {
            LocationDelegate.instance.isTrackingHeading = true
            print("AnchoringView.onAppear()")
        }
        .onDisappear() {
            //LocationDelegate.instance.isTrackingHeading = false
            print("AnchoringView.onDisappear()")
        }
    }
        
    struct RelativeView: View {
        @Environment(ViewModel.self) private var viewModel
        var model: AnchoringViewModel
        
        init(model: AnchoringViewModel) {
            self.model = model
            //print("AnchoringView.RelativeView.init()")
        }
        
        var body: some View {
            @Bindable var m = model
            VStack {
                VesselLocationMap(model: model)
                
                Spacer()
                
                DistanceEditor("view.anchoring.rodeLength", measurement: $m.rodeLengthMeters, maxMeters: m.vessel.totalRodeMeters )
                DistanceEditor("view.anchoring.distance", measurement: $m.distanceFromAnchorMeters, maxMeters: m.vessel.maxDistanceFromAnchor )
                
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.setAppView( .map )
                    } label: {
                        Image(systemName: "escape")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    Button {
                        model.setAnchorAtRelativeBearing()
                        viewModel.setAppView( .map )
                        print("AnchoringView.RelativeView.button complete")
                    } label: {
                        AnchorView(color: model.relativeLocationWouldAlarm() ? Color.gray : Color.blue, size: CGFloat(45))
                    }
                    .disabled(model.relativeLocationWouldAlarm())
                    Spacer()
                }
            }
            .onAppear(perform: {
                model.track(location: true, heading: true)
                print("AnchoringView.RelativeView.onAppear()")
            })
            .onDisappear(perform: {
                // model.track()
                print("AnchoringView.RelativeView.onDisappear()")
            })
        }
    }
    
    struct CurrentView: View {
        @Environment(ViewModel.self) private var viewModel
        var model: AnchoringViewModel

        var body: some View {
            @Bindable var m = model
            VStack {
                VesselLocationMap(model: model)
                
                Spacer()
                
                DistanceEditor("view.anchoring.rodeLength", measurement: $m.rodeLengthMeters, maxMeters: m.vessel.totalRodeMeters )
                    .padding()

                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.setAppView( .map )
                    } label: {
                        Image(systemName: "escape")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    
                    Button() {
                        model.setAnchorAtCurrentPosition()
                        viewModel.setAppView( .map )
                        print("AnchoringView.CurrentView.button complete")
                    } label: {
                        AnchorView(color: Color.blue, size: CGFloat(45))
                    }
                    Spacer()
                }
            }
            .onAppear(perform: {
                model.track(location: true, heading: true)
                print("AnchoringView.CurrentView.onAppear()")
            })
            .onDisappear(perform: {
                // model.track()
                print("AnchoringView.CurrentView.onDisappear()")
            })
        }
    }
    
    enum EditState {
        case new, edit
    }
}

