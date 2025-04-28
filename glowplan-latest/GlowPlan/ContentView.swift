//
//  ContentView.swift
//  GlowPlan
//
//  Created by Abdel Fekih on 2025-04-21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        OnboardingView()
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
