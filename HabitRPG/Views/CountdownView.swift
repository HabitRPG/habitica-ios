//
//  CountdownView.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.01.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct CountdownView: View {
    var endDate: Date
    var stringBuilder: (String) -> String
    @State var tick = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private func buildString(_: Int) -> String {
        // need to have tick as parameter to get SwiftUI to rebuild the String
        return stringBuilder(endDate.getShortRemainingString())
    }
    
    var body: some View {
        Text(buildString(tick))
            .onReceive(timer) {_ in
                if endDate > Date() {
                    self.tick += 1
                } else {
                    self.onTerminated()
                }
       }
    }

    func onTerminated() {
        timer.upstream.connect().cancel()
    }
}
