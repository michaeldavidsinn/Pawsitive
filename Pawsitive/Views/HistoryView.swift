//
//  HistoryView.swift
//  Pawsitive
//
//  Created by Michael David Sin on 02/09/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.timestamp, order: .reverse) private var moodEntries: [MoodEntry]
    
    var body: some View {
        NavigationStack {
            Group {
                if moodEntries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "pawprint.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("No Scan History Yet")
                            .font(.system(.headline, design: .rounded))
                        Text("Scanned dog emotions will automatically appear here.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                } else {
                    List {
                        ForEach(moodEntries) { entry in
                            NavigationLink(destination: HistoryDetailView(entry: entry)) {
                                HStack(spacing: 16) {
                                    if let data = entry.imageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    } else {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                            .overlay(Image(systemName: "pawprint.fill").foregroundColor(.gray))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(entry.breed)
                                                .font(.system(.caption, design: .rounded))
                                                .bold()
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Theme.gradientStart.opacity(0.15))
                                                .foregroundColor(Theme.gradientStart)
                                                .clipShape(Capsule())
                                            
                                            Spacer()
                                            
                                            Text(entry.timestamp, style: .date)
                                                .font(.system(.caption2, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Text(entry.emotionLabel.capitalized)
                                            .font(.system(.headline, design: .rounded))
                                            .bold()
                                        
                                        Text(entry.adviceText)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Pet Mood Journal")
        }
    }
    
    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(moodEntries[index])
        }
        try? modelContext.save()
    }
}
