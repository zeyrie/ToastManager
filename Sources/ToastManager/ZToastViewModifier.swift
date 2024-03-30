//
//  ZToastViewModifier.swift
//  
//
//  Created by Abilash S on 30/03/24.
//

import SwiftUI
import Combine

public struct ZToastViewModifier<Toast: View>: ViewModifier {
    
    @Binding var isPresenting: Bool
    
    @State var duration: Double = 2
    
    @State var tapToDismiss: Bool = true
    
    var offsetY: CGFloat = 0
    
    var toast: ZToastView<Toast>
    
    var onTap: (() -> ())? = nil
    var completion: (() -> ())? = nil
    
    var slideThrough: Bool
    
    @State private var workItem: DispatchWorkItem?
    
    @State private var hostRect: CGRect = .zero
    @State private var alertRect: CGRect = .zero
    
    private var screen: CGRect {
#if os(iOS)
        return UIScreen.main.bounds
#else
        return NSScreen.main?.frame ?? .zero
#endif
    }
    
    private var offset: CGFloat{
        return -hostRect.midY + alertRect.height
    }
    
    @ViewBuilder
    public func main() -> some View{
        if isPresenting{
            toast
                .onTapGesture {
                    onTap?()
                    if tapToDismiss{
                        withAnimation(Animation.spring()){
                            self.workItem?.cancel()
                            isPresenting = false
                            self.workItem = nil
                        }
                    }
                }
                .onDisappear(perform: {
                    completion?()
                })
                .transition(slideThrough ? AnyTransition.slide.combined(with: .opacity) : AnyTransition.move(edge: .bottom))
        }
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        
        content
            .overlay(
                ZStack{
                    main()
                        .offset(y: offsetY)
                }
                    .animation(Animation.spring(), value: isPresenting)
            )
            .valueChanged(value: isPresenting, onChange: { (presented) in
                if presented{
                    onAppearAction()
                }
            })
    }
    
    private func onAppearAction(){
        guard workItem == nil else {
            return
        }
        
        if duration > 0{
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                withAnimation(Animation.spring()){
                    isPresenting = false
                    workItem = nil
                }
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
        }
    }
}

extension View {
    
    public func toast(isPresenting: Binding<Bool>, duration: Double = 2, tapToDismiss: Bool = true, animateFromSide: Bool, backgroundColor: Color, offsetY: CGFloat = 0, content: () -> some View, onTap: (() -> ())? = nil, completion: (() -> ())? = nil) -> some View{
        modifier(ZToastViewModifier(isPresenting: isPresenting, duration: duration, tapToDismiss: tapToDismiss, offsetY: offsetY, toast: ZToastView(backgroundColor: backgroundColor, content: content), onTap: onTap, completion: completion, slideThrough: animateFromSide))
    }
    
    @ViewBuilder fileprivate func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
}
