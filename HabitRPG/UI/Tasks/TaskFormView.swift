//
//  TaskFormView.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.06.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct TaskFormView: View {
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.title).foregroundColor(.white).font(.body).padding(.leading, 8)
                        TextField("", text: .constant("Test"))
                            .padding(8)
                            .foregroundColor(.white)
                            .background(Color(UIColor.purple200))
                            .cornerRadius(12)
                    }.padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }.background(Color(UIColor.purple300).cornerRadius(12).edgesIgnoringSafeArea(.bottom))
            }
        }
    }
}

class TaskFormController: UIHostingController<TaskFormView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: TaskFormView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

struct TaskFormView_Previews: PreviewProvider {
    static var previews: some View {
        TaskFormView()
    }
}
