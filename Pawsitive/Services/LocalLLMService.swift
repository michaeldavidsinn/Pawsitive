//
//  LocalLLMService.swift
//  Pawsitive
//
//  Created by Michael David Sin on 26/08/26.
//

import Foundation
import LlamaSwift

actor LocalLLMService {
    
    static let shared = LocalLLMService()
    
    private(set) var isReady = false
    private var model: OpaquePointer?
    
    private init() {
        Task {
            await loadModel()
        }
    }
    
    func loadModel() async {
        guard let modelUrl = Bundle.main.url(forResource: "Llama-3.2-1B-Instruct-Q4_K_M", withExtension: "gguf") else {
            print("❌ GGUF Model file not found in main bundle.")
            return
        }
        
        llama_backend_init()
        
        let modelParams = llama_model_default_params()
        self.model = llama_load_model_from_file(modelUrl.path, modelParams)
        
        if self.model != nil {
            self.isReady = true
            print("✅ Local LLM (Llama) engine initialized successfully.")
        } else {
            print("❌ Failed to load Llama model into memory.")
        }
    }
    
    func generateAdvice(for label: String, confidence: Float, breed: String = "Pet") async -> (text: String, isOfflineMode: Bool) {
        guard isReady, let model = model else {
            return (text: "Model is not loaded into memory.", isOfflineMode: true)
        }
        
        let contextParams = llama_context_default_params()
        guard let context = llama_new_context_with_model(model, contextParams) else {
            return (text: "Error: Failed to allocate context memory.", isOfflineMode: true)
        }
        defer { llama_free(context) }
        
        let vocab = llama_model_get_vocab(model)
        
        let prompt = """
        <|begin_of_text|><|start_header_id|>system<|end_header_id|>
        
        You are an expert dog behaviorist speaking directly to a dog owner in a professional and warm tone.<|eot_id|><|start_header_id|>user<|end_header_id|>
        
        The owner's dog is a \(breed) currently showing a '\(label)' emotion with \(Int(confidence * 100))% confidence. 
        
        Provide highly practical advice on how the owner should react right now based on this emotion and breed. 
        
        Guidelines:
        - Give ONE immediate, actionable step the owner can do.
        - Refer to the pet affectionately as \(breed).
        - Dive straight into the natural advice without any robotic introductions.
        - Keep it very concise (maximum 2-3 sentences). Write in English.<|eot_id|><|start_header_id|>assistant<|end_header_id|>
        
        """
        
        var tokens = [llama_token](repeating: 0, count: 1024)
        let nTokens = llama_tokenize(vocab, prompt, Int32(prompt.utf8.count), &tokens, Int32(tokens.count), true, false)
        
        if nTokens < 0 {
            return (text: "Error: Prompt exceeded tokenization limit.", isOfflineMode: true)
        }
        
        var batch = llama_batch_get_one(&tokens, nTokens)
        if llama_decode(context, batch) != 0 {
            return (text: "Error: Failed to decode prompt.", isOfflineMode: true)
        }
        
        var resultText = ""
        var currentTokenId: llama_token = 0
        let maxOutputTokens = 100
        
        var chainParams = llama_sampler_chain_default_params()
        chainParams.no_perf = true
        let smpl = llama_sampler_chain_init(chainParams)
        
        llama_sampler_chain_add(smpl, llama_sampler_init_temp(0.7))
        llama_sampler_chain_add(smpl, llama_sampler_init_dist(UInt32.random(in: 0...100000)))
        
        let eosToken = llama_vocab_eos(vocab)
        
        for _ in 0..<maxOutputTokens {
            currentTokenId = llama_sampler_sample(smpl, context, batch.n_tokens - 1)
            
            if currentTokenId == eosToken {
                break
            }
            
            var buf = [CChar](repeating: 0, count: 32)
            llama_token_to_piece(vocab, currentTokenId, &buf, Int32(buf.count), 0, false)
            if let str = String(cString: buf, encoding: .utf8) {
                resultText += str
            }
            
            batch = llama_batch_get_one(&currentTokenId, 1)
            if llama_decode(context, batch) != 0 {
                break
            }
        }
        
        llama_sampler_free(smpl)
        
        let cleanedResult = resultText.trimmingCharacters(in: .whitespacesAndNewlines)
        return (text: cleanedResult, isOfflineMode: true)
    }
}
