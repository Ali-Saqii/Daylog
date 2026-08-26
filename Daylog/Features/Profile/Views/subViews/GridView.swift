//
//  GridView.swift
//  Daylog
//
//  Created by Mac mini on 17/08/2026.
//

import SwiftUI


struct GridView:View {
    let num: Int
    let title: String
    var body: some View {
        VStack(spacing: 0){
            Text("\(num)")
            Text(title)

        }.frame(maxWidth: .infinity,alignment: .center)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)

            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.orange,lineWidth: 2)
            }
    }
}
