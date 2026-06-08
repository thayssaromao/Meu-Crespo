//
//  MeuCrespoWidgetLiveActivity.swift
//  MeuCrespoWidget
//
//  Created by Thayssa Romão on 08/06/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MeuCrespoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MeuCrespoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeuCrespoWidgetAttributes.self) { context in
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

extension MeuCrespoWidgetAttributes {
    fileprivate static var preview: MeuCrespoWidgetAttributes {
        MeuCrespoWidgetAttributes(name: "World")
    }
}

extension MeuCrespoWidgetAttributes.ContentState {
    fileprivate static var smiley: MeuCrespoWidgetAttributes.ContentState {
        MeuCrespoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MeuCrespoWidgetAttributes.ContentState {
         MeuCrespoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MeuCrespoWidgetAttributes.preview) {
   MeuCrespoWidgetLiveActivity()
} contentStates: {
    MeuCrespoWidgetAttributes.ContentState.smiley
    MeuCrespoWidgetAttributes.ContentState.starEyes
}
