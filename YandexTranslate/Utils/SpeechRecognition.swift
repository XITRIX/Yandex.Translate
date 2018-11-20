//
//  SpeechRecognition.swift
//  YandexTranslate
//
//  Created by Daniil Vinogradov on 20/11/2018.
//  Copyright © 2018 NoNameDude. All rights reserved.
//

import Speech

class SpeechRecognition {
    
    static var recognitionTask: SFSpeechRecognitionTask?
    static var audioEngine: AVAudioEngine?
    
    static func recordAndRecognizeSpeech(language: TranslateAPI.Language, completion: @escaping (String?, Error?)->()) {
        let request = SFSpeechAudioBufferRecognitionRequest()
        let speechRecognizer = SFSpeechRecognizer(locale: language.locale)
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecogniser = SFSpeechRecognizer() else { return }
        if !myRecogniser.isAvailable { return }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            completion(result?.bestTranscription.formattedString, error)
        })
    }
    
    static func stopRecognition() {
        audioEngine?.stop()
        recognitionTask?.cancel()
        
        audioEngine = nil
        recognitionTask = nil
    }
    
    static func isRecognising() -> Bool {
        if audioEngine != nil,
            recognitionTask != nil {
            return true
        }
        return false
    }
}
