//
//  FlowersWidgetLiveActivity.swift
//  FlowersWidget
//
//  Created by James Frewin on 24/07/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FlowersWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FlowersWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlowersWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FlowersWidgetAttributes {
    fileprivate static var preview: FlowersWidgetAttributes {
        FlowersWidgetAttributes(name: "World")
    }
}

extension FlowersWidgetAttributes.ContentState {
    fileprivate static var smiley: FlowersWidgetAttributes.ContentState {
        FlowersWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FlowersWidgetAttributes.ContentState {
         FlowersWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FlowersWidgetAttributes.preview) {
   FlowersWidgetLiveActivity()
} contentStates: {
    FlowersWidgetAttributes.ContentState.smiley
    FlowersWidgetAttributes.ContentState.starEyes
}
