//
//  FlowersWidgetBundle.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import WidgetKit
import SwiftUI

@main
struct FlowersWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Recent Flower Widgets (shows most recent or pending flower)
        FlowersWidget()
        
        // Collection Widgets (shows flower collection grid/cycling)
        CollectionWidget()
        
        // Countdown Widget (shows timer to next flower with blurred background)
        CountdownWidget()
        
        // Keep existing widgets if needed
        FlowersWidgetControl()
        FlowersWidgetLiveActivity()
    }
}
