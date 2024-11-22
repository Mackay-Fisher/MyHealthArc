//
//  CombinedGoalsAndStreaksView.swift
//  myHealthArc-new-frontend
//
//  Created by Mackay Fisher on 11/21/24.
//


import SwiftUI

struct CombinedView: View {
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(spacing: 20) {
                    
                    StreaksView()
                    GoalsView()
                    //This is just to fit all of teh goal views as thgis page is already a scroll view I rmeoved it form teh goal view page its self
                        .frame(minHeight: 1200)
                }
            }
        }
    }
}

// MARK: - Preview
struct CombinedView_Previews: PreviewProvider {
    static var previews: some View {
        CombinedView()
            .preferredColorScheme(.light)

        CombinedView()
            .preferredColorScheme(.dark)
    }
}
