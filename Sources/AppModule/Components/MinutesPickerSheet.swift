import SwiftUI

import SwiftUI

struct MinutesPickerSheet: View {
    @Binding var focusMinutes: Int
    @Binding var breakMinutes: Int
    
    var onCancel: () -> Void
    var onSave: () -> Void
    
    enum Editing { case focus, breakTime }
    @State private var editing: Editing = .focus
    @State private var tempMinutes: Int = 25
    
    private let range = Array(0...180)
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button("Cancel", action: onCancel)
                    Spacer()
                    Button(editing == .breakTime ? "Done" : "Next") {
                        if editing == .focus {
                            focusMinutes = tempMinutes
                            editing = .breakTime
                            tempMinutes = breakMinutes
                        } else {
                            breakMinutes = tempMinutes
                            onSave()
                        }
                    }
                    .fontWeight(.semibold)
                }
                
                Text("Set \(editing == .focus ? "Focus" : "Break") Minutes")
                    .font(.headline)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 10)
            
            Divider()
            
            Picker("", selection: $tempMinutes) {
                ForEach(range, id: \.self) { m in
                    Text("\(m) min").tag(m)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 240)
            .clipped()
        }
        .onAppear {
            editing = .focus
            tempMinutes = focusMinutes
        }
        .presentationBackground(.ultraThinMaterial)
    }
}
