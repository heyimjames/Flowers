import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), flower: AIFlower.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), flower: loadDailyFlower() ?? AIFlower.sample)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Load the current daily flower
        let flower = loadDailyFlower() ?? AIFlower.sample
        let currentDate = Date()
        
        // Create an entry for now
        entries.append(SimpleEntry(date: currentDate, flower: flower))
        
        // Create an entry for midnight to refresh with new daily flower
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            let midnight = Calendar.current.startOfDay(for: tomorrow)
            entries.append(SimpleEntry(date: midnight, flower: flower))
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadDailyFlower() -> AIFlower? {
        let userDefaults = UserDefaults(suiteName: "group.OCTOBER.Flowers")
        guard let flowerData = userDefaults?.data(forKey: "dailyFlower"),
              let flower = try? JSONDecoder().decode(AIFlower.self, from: flowerData) else {
            return nil
        }
        return flower
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let flower: AIFlower
}

struct FlowersWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(flower: entry.flower)
        case .systemMedium:
            MediumWidgetView(flower: entry.flower)
        default:
            SmallWidgetView(flower: entry.flower)
        }
    }
}

struct SmallWidgetView: View {
    let flower: AIFlower
    
    var body: some View {
        ZStack {
            if let imageData = flower.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Placeholder gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.9, green: 0.7, blue: 0.9),
                        Color(red: 0.7, green: 0.5, blue: 0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            // Name overlay at bottom
            VStack {
                Spacer()
                
                Text(flower.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0.6), Color.black.opacity(0.3)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(maxWidth: .infinity)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MediumWidgetView: View {
    let flower: AIFlower
    
    var body: some View {
        HStack(spacing: 16) {
            // Flower image
            if let imageData = flower.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .cornerRadius(16)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.9, green: 0.7, blue: 0.9),
                                Color(red: 0.7, green: 0.5, blue: 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 8) {
                Text("Flower of the Day")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(flower.name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(flower.generatedDate, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Tap to see more")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct FlowersWidget: Widget {
    let kind: String = "FlowersWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlowersWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Flower")
        .description("See your beautiful AI-generated flower of the day")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FlowersWidget_Previews: PreviewProvider {
    static var previews: some View {
        FlowersWidgetEntryView(entry: SimpleEntry(date: Date(), flower: .sample))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        FlowersWidgetEntryView(entry: SimpleEntry(date: Date(), flower: .sample))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
} 