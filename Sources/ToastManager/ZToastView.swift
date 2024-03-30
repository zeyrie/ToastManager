//
//  ZToastView.swift
//  
//
//  Created by Abilash S on 30/03/24.
//

import SwiftUI

public struct ZToastView<Content: View>: View {
    
    var content: Content
    
    var backgroundColor: Color
    
    init(backgroundColor: Color, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    public var body: some View {
        VStack{
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                content
            }
            .padding()
            .frame(maxWidth: 400, alignment: .leading)
            .background(backgroundColor)
            .cornerRadius(10)
            .padding([.horizontal, .bottom])
            
        }
    }
    
}

#Preview {
    Color(.black)
        .toast(isPresenting: .constant(true), duration: 3, tapToDismiss: true, animateFromSide: true, backgroundColor: .purple, offsetY: 2, content: {
            Text("Hello")
        }, onTap: {
            
        }, completion: {
            
        })
}
