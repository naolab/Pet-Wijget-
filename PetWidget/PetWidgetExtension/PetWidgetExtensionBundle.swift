//
//  PetWidgetExtensionBundle.swift
//  PetWidgetExtension
//
//  Created by なお on 2025/10/11.
//

import WidgetKit
import SwiftUI

@main
struct PetWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        PetWidgetExtension()
        PetWidgetExtensionControl()
        PetWidgetExtensionLiveActivity()
    }
}
