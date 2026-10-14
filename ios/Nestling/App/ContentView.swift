import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showingProfile = false
    @State private var eventKind: EventKind?
    @State private var showingResetAlert = false

    private var todayEvents: [CareEvent] {
        store.events.filter { Calendar.current.isDateInToday($0.occurredAt) }.sorted { $0.occurredAt > $1.occurredAt }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    welcomeCard
                    predictionCard
                    quickLog
                    timeline
                    footer
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Nestling")
            .toolbar { Button("Profile") { showingProfile = true } }
            .sheet(isPresented: $showingProfile) { ProfileSheet(profile: store.profile) { name, birthdate in store.saveProfile(name: name, birthdate: birthdate) } }
            .sheet(item: $eventKind) { kind in EventSheet(kind: kind) { date, duration, detail, note in store.add(kind: kind, occurredAt: date, durationMinutes: duration, detail: detail, note: note) } }
            .alert("Erase all local prototype data?", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) { store.reset() }
                Button("Cancel", role: .cancel) { }
            } message: { Text("This removes this prototype’s profile and event history from this device.") }
        }
        .tint(.teal)
    }

    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(store.profile.map { "\(RestPredictor.ageInMonths(birthdate: $0.birthdate)) MONTHS OLD" } ?? "LOCAL-ONLY")
                .font(.caption.weight(.bold)).foregroundStyle(.secondary)
            Text(store.profile.map { "A little more ease for \($0.name)." } ?? "A gentler way to keep track.")
                .font(.title2.weight(.semibold))
            Text(store.profile == nil ? "Add a baby profile to begin your first day together." : "Quick logs stay on this device. Nothing is sent anywhere.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(20).background(Color.teal.opacity(0.13), in: RoundedRectangle(cornerRadius: 22))
    }

    private var predictionCard: some View {
        let estimate = RestPredictor.estimate(events: store.events, profile: store.profile)
        return VStack(alignment: .leading, spacing: 10) {
            HStack { Text("NEXT REST WINDOW").font(.caption.weight(.bold)); Spacer(); Text(estimate?.confidence ?? "Waiting").font(.caption.weight(.bold)) }
            Text(estimate?.suggestedTime.formatted(date: .omitted, time: .shortened) ?? "--:--").font(.system(size: 42, weight: .semibold, design: .rounded))
            Text(estimate?.reason ?? "Log a sleep to see an informational estimate based on entries saved on this device.")
            Divider().overlay(.white.opacity(0.3))
            Text("This is not medical advice and cannot predict how your baby will sleep. Follow your own care plan and seek professional guidance when needed.").font(.footnote)
        }
        .foregroundStyle(.white).frame(maxWidth: .infinity, alignment: .leading).padding(20).background(Color.teal, in: RoundedRectangle(cornerRadius: 22))
    }

    private var quickLog: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("QUICK LOG").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            Text("What happened?").font(.headline)
            HStack(spacing: 10) { ForEach(EventKind.allCases) { kind in Button { eventKind = kind } label: { Label(kind.title, systemImage: kind.symbol).font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity).frame(height: 72).background(color(for: kind), in: RoundedRectangle(cornerRadius: 16)) } } }
        }.padding(20).background(.background, in: RoundedRectangle(cornerRadius: 22))
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack { VStack(alignment: .leading) { Text("DAY AT A GLANCE").font(.caption.weight(.bold)).foregroundStyle(.secondary); Text("Today's timeline").font(.headline) }; Spacer(); Button("Try sample day") { store.addSampleDay() }.font(.subheadline.weight(.semibold)) }
            if todayEvents.isEmpty { Text("Your first log will show up here. Try a feed, sleep, or diaper entry.").foregroundStyle(.secondary).padding(.vertical, 10) }
            ForEach(todayEvents) { event in HStack(alignment: .top, spacing: 14) { Text(event.occurredAt.formatted(date: .omitted, time: .shortened)).font(.caption.weight(.bold)).frame(width: 54, alignment: .leading); VStack(alignment: .leading, spacing: 3) { Text(event.kind.title).fontWeight(.semibold); Text(eventDescription(event)).font(.footnote).foregroundStyle(.secondary) } }.padding(.vertical, 8) }
        }.frame(maxWidth: .infinity, alignment: .leading).padding(20).background(.background, in: RoundedRectangle(cornerRadius: 22))
    }

    private var footer: some View { HStack { Text("Saved only on this device").font(.footnote).foregroundStyle(.secondary); Spacer(); Button("Reset", role: .destructive) { showingResetAlert = true }.font(.footnote.weight(.semibold)) }.padding(.horizontal, 6) }
    private func color(for kind: EventKind) -> Color { switch kind { case .feed: .orange.opacity(0.22); case .sleep: .teal.opacity(0.18); case .diaper: .purple.opacity(0.16) } }
    private func eventDescription(_ event: CareEvent) -> String { [event.detail, event.durationMinutes.map { "\($0) min" }, event.note.isEmpty ? nil : event.note].compactMap { $0 }.joined(separator: " · ") }
}

private struct ProfileSheet: View {
    let profile: BabyProfile?; let save: (String, Date) -> Void
    @Environment(\.dismiss) private var dismiss; @State private var name = ""; @State private var birthdate = Date()
    var body: some View { NavigationStack { Form { TextField("Baby's name", text: $name); DatePicker("Date of birth", selection: $birthdate, displayedComponents: .date) }.navigationTitle("Baby profile").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Save") { save(name, birthdate); dismiss() }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }; ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }.onAppear { name = profile?.name ?? ""; birthdate = profile?.birthdate ?? Date() } } }
}

private struct EventSheet: View {
    let kind: EventKind; let save: (Date, Int?, String, String) -> Void
    @Environment(\.dismiss) private var dismiss; @State private var occurredAt = Date(); @State private var duration = 45; @State private var detail = ""; @State private var note = ""
    private var options: [String] { switch kind { case .feed: ["Breastfeed", "Bottle", "Solid food"]; case .sleep: ["Nap", "Night sleep"]; case .diaper: ["Wet", "Soiled", "Both"] } }
    var body: some View { NavigationStack { Form { DatePicker("When", selection: $occurredAt); if kind == .sleep { Stepper("Duration: \(duration) min", value: $duration, in: 1...720) }; Picker("Details", selection: $detail) { ForEach(options, id: \.self) { Text($0) } }; TextField("Note (optional)", text: $note) }.navigationTitle("Log a \(kind.title.lowercased())").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Save") { save(occurredAt, kind == .sleep ? duration : nil, detail, note); dismiss() } }; ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }.onAppear { detail = options[0] } } }
}
