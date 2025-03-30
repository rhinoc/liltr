import Foundation
import SwiftUI
import Vision

// https://github.com/amebalabs/TRex/blob/main/TRex%20Core/TRex.swift
// https://developer.apple.com/documentation/vision/recognizing_text_in_images
class OCRManager {
    public static let shared = OCRManager()

    private var _task: Process?
    private var _taskId: String?

    private func resetTask() {
        _task?.terminate()
        _taskId = nil
        _task = nil
    }

    func capture() -> NSImage? {
        resetTask()

        let taskId = UUID().uuidString
        let tempPath = NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), "capture_\(taskId).png"])!.path()
        _taskId = taskId
        _task = Process()
        _task?.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        _task?.arguments = ["-i", tempPath]

        do {
            try _task?.run()
        } catch {
            debugPrint("[OCRManager]", error)
            resetTask()
            return nil
        }

        _task?.waitUntilExit()
        if _taskId != taskId {
            return nil
        }
        resetTask()
        return NSImage(contentsOfFile: tempPath)
    }

    private func _recoginizeTextHandler(request: VNRequest, error _: Error?, cb: @escaping (String) -> Void) {
        guard let observations =
            request.results as? [VNRecognizedTextObservation]
        else {
            return
        }
        if observations.isEmpty {
            debugPrint("[OCR Manager] observations result is empty")
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            observation.topCandidates(1).first?.string
        }

        cb(recognizedStrings.joined(separator: "\n"))
    }

    func ocr(image: CGImage, cb: @escaping (String) -> Void) {
        let requestHandler = VNImageRequestHandler(cgImage: image)
        let request = VNRecognizeTextRequest { request, error in
            self._recoginizeTextHandler(request: request, error: error, cb: cb)
        }
        request.automaticallyDetectsLanguage = true
        do {
            try requestHandler.perform([request])
        } catch {
            debugPrint("[OCR Manager] Unable to perform the requests: \(error)")
        }
    }

    func captureWithOCR(cb: @escaping (String) -> Void) {
        let image = capture()
        if image != nil {
            ocr(image: image!.cgImage(forProposedRect: nil, context: nil, hints: nil)!, cb: cb)
        }
    }
}
