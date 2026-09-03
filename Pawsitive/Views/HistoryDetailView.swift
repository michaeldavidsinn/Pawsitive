//
//  HistoryDetailView.swift
//  Pawsitive
//
//  Created by Michael David Sin on 03/09/26.
//

import SwiftUI
import SwiftData

struct HistoryDetailView: View {
    let entry: MoodEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 1. Photo Section
                if let data = entry.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .overlay {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                        }
                }
                
                // 2. Header Information
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(entry.breed, systemImage: "pawprint.fill")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.gradientStart.opacity(0.12))
                            .foregroundColor(Theme.gradientStart)
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text(entry.timestamp, style: .date)
                            Text("•")
                            Text(entry.timestamp, style: .time)
                        }
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.secondary)
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(entry.emotionLabel.capitalized)
                            .font(.system(.title, design: .rounded))
                            .bold()
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.caption)
                            Text("\(Int(entry.confidence * 100))% confidence")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 4)
                
                Divider()
                
                // 3. AI Pet Care Advice Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Theme.gradientStart)
                        
                        Text("AI Care Advice")
                            .font(.system(.headline, design: .rounded))
                            .bold()
                    }
                    
                    Text(entry.adviceText)
                        .font(.system(.body, design: .rounded))
                        .lineSpacing(6)
                        .foregroundColor(.primary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(16)
        }
        .navigationTitle("Scan Details")
        .navigationBarTitleDisplayMode(.inline)
        // 👇 Tombol Hapus Native di Pojok Kanan Atas
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        // 👇 Native Action Sheet / Alert untuk Konfirmasi
        .alert("Delete Scan History?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteCurrentEntry()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This scan record will be permanently deleted from your local storage.")
        }
    }
    
    private func deleteCurrentEntry() {
        modelContext.delete(entry)
        try? modelContext.save()
        dismiss() // Kembali ke HistoryView otomatis setelah menghapus
    }
}
