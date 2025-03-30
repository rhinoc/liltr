import AVFoundation
import Foundation

class SpeechManager {
    private static let speechSynthesizer = AVSpeechSynthesizer()

    private static func getVoiceScore(voice: AVSpeechSynthesisVoice, language: Language) -> Int {
        var score = 1
        if voice.language == language.code {
            score += 10
        }
        if voice.quality == .premium {
            score += 8
        } else if voice.quality == .enhanced {
            score += 5
        }

        return score
    }

    static func stop(at boundary: AVSpeechBoundary = .immediate) {
        speechSynthesizer.stopSpeaking(at: boundary)
    }

    static func start(_ string: String, _ language: Language) {
        if string.isEmpty {
            return
        }

        if speechSynthesizer.isSpeaking {
            stop()
        } else {
            let speechUtterance = AVSpeechUtterance(string: string)
//            speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.5
//            speechUtterance.voice = getVoiceByLanguage(language)
            speechUtterance.voice = AVSpeechSynthesisVoice(language: language.code)
            debugPrint("[SpeechManager.start]", speechUtterance.voice?.identifier)
            speechSynthesizer.speak(speechUtterance)
        }
    }

    static func getVoiceByLanguage(_ language: Language) -> AVSpeechSynthesisVoice? {
        var resultScore = 0
        var result: AVSpeechSynthesisVoice?
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            if voice.language == language.code || LanguageManager.getShortCode(voice.language) == language.shortCode {
                let score = getVoiceScore(voice: voice, language: language)
                if score > resultScore {
                    result = voice
                    resultScore = score
                }
            }
        }
        return result
    }
}
