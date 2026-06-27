//
//  HabitFlowWidgetBundle.swift
//  HabitFlowWidget
//
//  Created by Lokendra Gharti on 19/06/2026.
//

import WidgetKit
import SwiftUI

@main
struct HabitFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitFlowWidget()
        HabitFlowWidgetControl()
        HabitFlowWidgetLiveActivity()
    }
}
