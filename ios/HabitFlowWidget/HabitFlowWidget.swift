import WidgetKit
import SwiftUI

// ── Data model (mirrors your Flutter JSON) ────────────────────────────────────

struct HabitEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let done: Int
    let total: Int
    let moodEmoji: String
    let habits: [HabitItem]
}

struct HabitItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let done: Int
    let target: Int
    let complete: Bool
}

// ── Timeline provider ─────────────────────────────────────────────────────────

struct HabitFlowProvider: TimelineProvider {
    let appGroup = "group.com.yourcompany.habitflow"

    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: .now, streak: 5, done: 3, total: 4,
                   moodEmoji: "🙂", habits: [])
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (HabitEntry) -> Void) {
        completion(load())
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<HabitEntry>) -> Void) {
        let entry    = load()
        // Refresh every 30 minutes (Flutter also triggers on data change)
        let nextDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextDate)))
    }

    private func load() -> HabitEntry {
        let defaults = UserDefaults(suiteName: appGroup)
        guard
            let json   = defaults?.string(forKey: "habitflow_data"),
            let data   = json.data(using: .utf8),
            let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return HabitEntry(date: .now, streak: 0, done: 0,
                              total: 0, moodEmoji: "", habits: [])
        }

        let rawHabits = parsed["habits"] as? [[String: Any]] ?? []
        let habits = rawHabits.map {
            HabitItem(
                name:     $0["name"]     as? String ?? "",
                icon:     $0["icon"]     as? String ?? "",
                done:     $0["done"]     as? Int    ?? 0,
                target:   $0["target"]   as? Int    ?? 1,
                complete: $0["complete"] as? Bool   ?? false
            )
        }

        return HabitEntry(
            date:      .now,
            streak:    parsed["streak"]     as? Int    ?? 0,
            done:      parsed["done"]       as? Int    ?? 0,
            total:     parsed["total"]      as? Int    ?? 0,
            moodEmoji: parsed["mood_emoji"] as? String ?? "",
            habits:    habits
        )
    }
}

// ── Small widget (streak + today progress) ────────────────────────────────────

struct SmallWidgetView: View {
    let entry: HabitEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("🔥").font(.title2)
                Spacer()
                if !entry.moodEmoji.isEmpty {
                    Text(entry.moodEmoji).font(.title3)
                }
            }
            Text("\(entry.streak)")
                .font(.system(size: 36, weight: .black))
                .foregroundColor(.green)
            Text("day streak")
                .font(.caption2)
                .foregroundColor(.secondary)
            Spacer()
            ProgressView(value: entry.total > 0
                         ? Double(entry.done) / Double(entry.total) : 0)
                .tint(.green)
            Text("\(entry.done)/\(entry.total) done")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(UIColor.systemBackground))
        .widgetURL(URL(string: "habitflow://home"))
    }
}

// ── Medium widget (habit list) ────────────────────────────────────────────────

struct MediumWidgetView: View {
    let entry: HabitEntry
    var body: some View {
        HStack(spacing: 12) {
            // Left: streak
            VStack(alignment: .leading, spacing: 2) {
                Text("🔥 \(entry.streak)")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.green)
                Text("day streak").font(.caption2).foregroundColor(.secondary)
                Spacer()
                Text("\(entry.done)/\(entry.total)")
                    .font(.headline).fontWeight(.bold)
                Text("today").font(.caption2).foregroundColor(.secondary)
            }
            .frame(width: 80)

            Divider()

            // Right: habits
            VStack(alignment: .leading, spacing: 6) {
                ForEach(entry.habits.prefix(4)) { h in
                    HStack(spacing: 6) {
                        Text(h.icon).font(.body)
                        Text(h.name)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: h.complete
                              ? "checkmark.circle.fill"
                              : "circle")
                            .foregroundColor(h.complete ? .green : .secondary)
                            .font(.caption)
                    }
                }
                Spacer()
            }
        }
        .padding(14)
        .widgetURL(URL(string: "habitflow://home"))
    }
}

// ── Widget entry point ────────────────────────────────────────────────────────

struct HabitFlowWidget: Widget {
    let kind = "HabitFlowWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitFlowProvider()) { entry in
            GeometryReader { geo in
                if geo.size.width < 170 {
                    SmallWidgetView(entry: entry)
                } else {
                    MediumWidgetView(entry: entry)
                }
            }
        }
        .configurationDisplayName("HabitFlow")
        .description("Today's habits and streak at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}