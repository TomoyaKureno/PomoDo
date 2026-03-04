import SwiftUI

struct TimePickerSheet: View {
    @Binding var focusSeconds: Int
    @Binding var breakSeconds: Int
    
    var onCancel: () -> Void
    var onSave: () -> Void
    
    enum Editing { case focus, breakTime }
    @State private var editing: Editing = .focus
    
    @State private var tempMinutes: Int = 25
    @State private var tempSeconds: Int = 0
    
    private let minuteRange = Array(0...180)
    private let secondRange = Array(0...59)
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button("Cancel", action: onCancel)
                    Spacer()
                    Button(editing == .breakTime ? "Done" : "Next") {
                        let total = (tempMinutes * 60) + tempSeconds
                        
                        if editing == .focus {
                            focusSeconds = max(1, total)
                            editing = .breakTime
                            loadFromBreak()
                        } else {
                            breakSeconds = max(1, total)
                            onSave()
                        }
                    }
                    .fontWeight(.semibold)
                }
                
                Text("Set \(editing == .focus ? "Focus" : "Break") Time")
                    .font(.headline)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 10)
            
            Divider()
            
            HStack(spacing: 0) {
                Picker("Minutes", selection: $tempMinutes) {
                    ForEach(minuteRange, id: \.self) { m in
                        Text("\(m) min").tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
                
                Picker("Seconds", selection: $tempSeconds) {
                    ForEach(secondRange, id: \.self) { s in
                        Text(String(format: "%02d sec", s)).tag(s)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .frame(height: 240)
        }
        .onAppear {
            editing = .focus
            loadFromFocus()
        }
        .presentationBackground(.ultraThinMaterial)
    }
    
    private func loadFromFocus() {
        tempMinutes = focusSeconds / 60
        tempSeconds = focusSeconds % 60
    }
    
    private func loadFromBreak() {
        tempMinutes = breakSeconds / 60
        tempSeconds = breakSeconds % 60
    }
}
