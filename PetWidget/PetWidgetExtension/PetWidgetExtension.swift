//
//  PetWidgetExtension.swift
//  PetWidgetExtension
//
//  Created by なお on 2025/10/11.
//

import WidgetKit
import SwiftUI

struct PetWidgetExtension: Widget {
    let kind: String = "PetWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetWidgetTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                MediumWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MediumWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("ペットウィジェット")
        .description("ペットの写真と時刻を表示します")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    PetWidgetExtension()
} timeline: {
    let samplePet = Pet(
        name: "ポチ",
        birthDate: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
        species: .dog,
        photoData: nil
    )

    PetWidgetEntry(date: .now, pet: samplePet, errorMessage: nil)
    PetWidgetEntry(date: .now, pet: nil, errorMessage: "ペットが登録されていません")
}
