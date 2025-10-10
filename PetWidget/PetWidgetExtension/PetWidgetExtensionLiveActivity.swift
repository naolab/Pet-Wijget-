//
//  PetWidgetExtensionLiveActivity.swift
//  PetWidgetExtension
//
//  Created by なお on 2025/10/11.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PetWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PetWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetWidgetExtensionAttributes.self) { context in
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

extension PetWidgetExtensionAttributes {
    fileprivate static var preview: PetWidgetExtensionAttributes {
        PetWidgetExtensionAttributes(name: "World")
    }
}

extension PetWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: PetWidgetExtensionAttributes.ContentState {
        PetWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PetWidgetExtensionAttributes.ContentState {
         PetWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PetWidgetExtensionAttributes.preview) {
   PetWidgetExtensionLiveActivity()
} contentStates: {
    PetWidgetExtensionAttributes.ContentState.smiley
    PetWidgetExtensionAttributes.ContentState.starEyes
}
