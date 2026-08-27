//
//  SLMAdviceGenerator.swift
//  Pawsitive
//
//  Created by Michael David Sin on 26/08/26.
//

import Foundation
import CoreML
import Tokenizers
import Hub

actor SLMAdviceGenerator {
    private var tokenizer: Tokenizer?
    private var model: MLModel?
    private(set) var isReady = false

    init() {
        Task {
            await setupEngine()
        }
    }

    private func setupEngine() async {
        do {
            self.tokenizer = try await AutoTokenizer.from(pretrained: "HuggingFaceTB/SmolLM2-135M-Instruct")
            
            guard let modelURL = Bundle.main.url(forResource: "SmolLM2-135M-Instruct-4bit", withExtension: "mlmodelc") else {
                print("❌ File model .mlmodelc tidak ditemukan di Bundle App.")
                return
            }
            
            let config = MLModelConfiguration()
            config.computeUnits = .all
            self.model = try MLModel(contentsOf: modelURL, configuration: config)
            
            self.isReady = true
            print("✅ SLM Engine & Tokenizer Berhasil Di-load!")
        } catch {
            print("❌ Gagal Inisialisasi SLM Engine: \(error.localizedDescription)")
        }
    }

    /// Tes Pokok untuk Uji Coba Generasi Teks Terisolasi
    func testGenerate(prompt: String) async -> String {
        guard isReady, let tokenizer = tokenizer else {
            return "Engine belum siap..."
        }
        let inputTokens = tokenizer.encode(text: prompt)
        print("Input Token Count: \(inputTokens.count)")

        return tokenizer.decode(tokens: inputTokens)
    }
}
