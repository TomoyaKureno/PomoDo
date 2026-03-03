import SwiftUI

struct RecapView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    let summary: RecapSummary

    // MARK: - Formatting Helpers

    private var formattedFocusTime: String {
        formatDuration(summary.totalFocusDuration)
    }

    private var formattedBreakTime: String {
        formatDuration(summary.totalBreakDuration)
    }

    private var formattedTotalTime: String {
        formatDuration(summary.totalDuration)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: summary.completedAt)
    }

    private var statusMessage: String {
        summary.isCompleted ? "All cycles completed!" : "Session ended early"
    }

    private var motivationalMessage: String {
        summary.isCompleted
            ? "Great work! Consistency builds mastery."
            : "Every session counts. Keep going!"
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60

        if hrs > 0 {
            return String(format: "%02d:%02d:%02d", hrs, mins, secs)
        }
        return String(format: "%02d:%02d", mins, secs)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    statusSection
                    statsSection
                    dateSection
                    motivationSection
                    backToHomeButton
                }
                .padding()
            }
        }
        .navigationTitle("Recap")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 4) {
            Image(systemName: summary.isCompleted ? "checkmark.seal.fill" : "clock.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white)

            Text("Session Recap")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.top, 16)
    }

    private var statusSection: some View {
        Text(statusMessage)
            .font(.title3.weight(.semibold))
            .foregroundStyle(summary.isCompleted ? .green : .orange)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
    }

    private var statsSection: some View {
        VStack(spacing: 16) {
            statRow(label: "Cycles", value: "\(summary.totalCycles)", icon: "arrow.trianglehead.2.counterclockwise")
            Divider().overlay(.white.opacity(0.2))
            statRow(label: "Focus Time", value: formattedFocusTime, icon: "eye.fill")
            Divider().overlay(.white.opacity(0.2))
            statRow(label: "Break Time", value: formattedBreakTime, icon: "cup.and.saucer.fill")
            Divider().overlay(.white.opacity(0.2))
            statRow(label: "Total Time", value: formattedTotalTime, icon: "timer")
        }
        .padding()
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    }

    private func statRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 28)

            Text(label)
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))

            Spacer()

            Text(value)
                .font(.title3.weight(.semibold).monospacedDigit())
                .foregroundStyle(.white)
        }
    }

    private var dateSection: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundStyle(.white.opacity(0.7))
            Text(formattedDate)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var motivationSection: some View {
        Text(motivationalMessage)
            .font(.callout.italic())
            .foregroundStyle(.white.opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.bottom, 8)
    }
    
    private var backToHomeButton: some View {
        Button {
            coordinator.popToRoot()
        } label: {
            Text("Back to Home")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    RecapView(
        summary: RecapSummary(
            totalCycles: 4,
            totalFocusDuration: 6000,
            totalBreakDuration: 1500,
            totalDuration: 7500,
            completedAt: Date(),
            isCompleted: true
        )
    )
}
