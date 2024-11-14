//
//  ContentView.swift
//  GreetingsApp
//
//  Created by Mohamed Fuad on 11/12/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.gray,.yellow.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            

            VStack {
                HStack {
                    VStack(alignment: .leading,spacing: 5) {
                        Text("Welcome")
                            .font(.largeTitle)
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                  
                        
                        Text("Currency")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                    }
                    .padding(20)
                    Spacer()
                }
                
                CurrencyBoxView()
               
                Spacer()
            }
  
            
        }
    }
}

#Preview {
    ContentView()
}
