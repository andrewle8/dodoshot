import Foundation

// MARK: - OCR Post-Processor

/// Cleans up OCR-extracted text using a local Ollama model.
/// Opt-in feature that requires Ollama running at localhost:11434.
class OCRPostProcessor {
    static let shared = OCRPostProcessor()

    private init() {}

    // MARK: - Public API

    /// Clean up OCR text using local Ollama model.
    /// Falls back to original text if Ollama is unavailable or times out.
    func cleanup(text: String, detectedType: DetectedContentType, completion: @escaping (String) -> Void) {
        let prompt = buildPrompt(for: text, type: detectedType)

        Task {
            do {
                let cleaned = try await callOllama(prompt: prompt, model: preferredModel())
                DispatchQueue.main.async { completion(cleaned) }
            } catch {
                // Fallback to original text if Ollama fails
                DispatchQueue.main.async { completion(text) }
            }
        }
    }

    /// Async version for use in async contexts.
    func cleanup(text: String, detectedType: DetectedContentType) async -> String {
        let prompt = buildPrompt(for: text, type: detectedType)
        do {
            return try await callOllama(prompt: prompt, model: preferredModel())
        } catch {
            return text
        }
    }

    /// Check if Ollama is running and reachable.
    func isOllamaAvailable() async -> Bool {
        let url = URL(string: "http://localhost:11434/api/tags")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 3
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    /// Fetch available model names from Ollama.
    func availableModels() async -> [String] {
        let url = URL(string: "http://localhost:11434/api/tags")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 3
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return [] }
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let models = json["models"] as? [[String: Any]] else { return [] }
            return models.compactMap { $0["name"] as? String }.sorted()
        } catch {
            return []
        }
    }

    // MARK: - Private

    private func preferredModel() -> String {
        SettingsManager.shared.settings.ocrCleanupModel
    }

    private func buildPrompt(for text: String, type: DetectedContentType) -> String {
        switch type {
        case .code:
            return """
            Fix this OCR-extracted code. Correct spacing, indentation, and obvious OCR errors (like 0/O confusion, l/1 confusion). Output ONLY the corrected code, nothing else:

            \(text)
            """
        case .table:
            return """
            This is OCR-extracted tabular data. Convert it to a clean markdown table. Fix any spacing issues or misaligned columns. Output ONLY the markdown table:

            \(text)
            """
        case .errorLog:
            return """
            Clean up this OCR-extracted error/log output. Fix line breaks, spacing, and obvious OCR errors. Preserve the original structure. Output ONLY the cleaned text:

            \(text)
            """
        case .list:
            return """
            Clean up this OCR-extracted list. Fix formatting, ensure consistent bullet/number style, fix spacing. Output as a clean markdown list. Output ONLY the list:

            \(text)
            """
        case .prose:
            return """
            Clean up this OCR-extracted text. Fix broken words, bad line breaks, spacing issues. Reflow into proper paragraphs. If it contains markdown-like content (headers, lists, links), format as proper markdown. Output ONLY the cleaned text:

            \(text)
            """
        }
    }

    private func callOllama(prompt: String, model: String) async throws -> String {
        let url = URL(string: "http://localhost:11434/api/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": false,
            "options": [
                "temperature": 0.1,
                "num_predict": 4096
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OCRPostProcessorError.ollamaUnavailable
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseText = json["response"] as? String else {
            throw OCRPostProcessorError.invalidResponse
        }

        return responseText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Errors

    enum OCRPostProcessorError: LocalizedError {
        case ollamaUnavailable
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .ollamaUnavailable:
                return "Ollama is not running at localhost:11434"
            case .invalidResponse:
                return "Invalid response from Ollama"
            }
        }
    }
}
