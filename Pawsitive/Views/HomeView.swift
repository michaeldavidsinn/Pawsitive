//
//  HomeView.swift
//  Pawsitive
//
//  Created by Michael David Sin on 24/08/26.
//

import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.timestamp, order: .reverse) private var moodEntries: [MoodEntry]
    
    let onStart: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // 1. Hero Action Card
                    Button(action: onStart) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Decode Dog's Mood")
                                    .font(.system(.title2, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Text("Tap to analyze with AI")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(Theme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Theme.gradientStart.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Decode Dog's Mood")
                    .accessibilityHint("Tap to analyze with AI")
                    .accessibilityAddTraits(.isButton)
                    
                    // 2. Statistics/Insights
                    if !moodEntries.isEmpty {
                        let happyCount = moodEntries.filter { $0.emotionLabel.lowercased() == "happy" }.count
                        HStack(spacing: 16) {
                            StatCard(title: "Total Scans", value: "\(moodEntries.count)", icon: "pawprint.fill", color: .blue)
                            StatCard(title: "Happy Moods", value: "\(happyCount)", icon: "face.smiling.fill", color: .orange)
                        }
                        .padding(.horizontal)
                    }
                    
                    // 3. Recent Scans Carousel
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Scans")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if moodEntries.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary.opacity(0.5))
                                    .accessibilityHidden(true)
                                Text("No recent scans yet.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(moodEntries.prefix(5)) { entry in
                                        NavigationLink(destination: HistoryDetailView(entry: entry)) {
                                            RecentScanCard(entry: entry)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 4. Mood Analytics Chart
                    if !moodEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Analytics")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                                .padding(.horizontal)
                            
                            MoodChartView(entries: moodEntries)
                                .padding(.horizontal)
                        }
                    }
                    
                    // 5. Daily Tip
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Did You Know?")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                            .padding(.horizontal)
                        
                        DailyTipCard()
                            .padding(.horizontal)
                    }
                    
                }
                .padding(.top, 16)
                .padding(.bottom, 48) // Extra padding at the bottom for scrolling
            }
            .navigationTitle("Dashboard")
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Subviews

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
                Text(value)
                    .font(.system(.title2, design: .rounded))
                    .bold()
            }
            Text(title)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}

struct RecentScanCard: View {
    let entry: MoodEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let data = entry.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 130)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 130)
                    .overlay(Image(systemName: "pawprint.fill").foregroundColor(.gray))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.emotionLabel.capitalized)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(entry.timestamp, style: .relative)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(12)
        }
        .frame(width: 150)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.emotionLabel.capitalized) mood, \(entry.timestamp.formatted(date: .abbreviated, time: .shortened))")
    }
}

struct MoodChartView: View {
    let entries: [MoodEntry]
    
    var body: some View {
        let chartData = extractChartData()
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Emotion Distribution")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
            
            Chart {
                ForEach(chartData, id: \.emotion) { data in
                    BarMark(
                        x: .value("Count", data.count),
                        y: .value("Emotion", data.emotion.capitalized)
                    )
                    .foregroundStyle(by: .value("Emotion", data.emotion.capitalized))
                    .cornerRadius(4)
                }
            }
            .chartLegend(.hidden)
            .frame(height: 140)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Bar chart showing emotion distribution.")
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
    
    private func extractChartData() -> [(emotion: String, count: Int)] {
        var counts: [String: Int] = [:]
        for entry in entries {
            counts[entry.emotionLabel, default: 0] += 1
        }
        return counts.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }
    }
}

struct DailyTipCard: View {
    let tips = [
        "A wagging tail doesn't always mean a happy dog. Look at their overall body posture!",
        "Dogs can read human emotions. They often mirror the stress or happiness of their owners.",
        "Yawning in dogs can be a sign of stress or anxiety, not just tiredness.",
        "A relaxed dog will have soft eyes, a relaxed mouth, and natural ear positioning."
    ]
    
    @State private var randomTip = ""
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "lightbulb.max.fill")
                .font(.system(size: 32))
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Pet Fact")
                    .font(.system(.headline, design: .rounded))
                Text(randomTip)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pet Fact: \(randomTip)")
        .onAppear {
            if randomTip.isEmpty {
                randomTip = tips.randomElement() ?? tips[0]
            }
        }
    }
}

#Preview {
    HomeView(onStart: {})
}
