//
//  TestViewController.swift
//  Japanese-Translator
//
//  Created by Mar Cabrera on 19/03/2021.
//

import UIKit
import AVFoundation
import Vision
import SwiftyTesseract

class CameraViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!

    var session = AVCaptureSession()
    var requests = [VNRequest]()
    var detectedTextImage: UIImage?
    var takePhoto = false

    override func viewDidLoad() {
        super.viewDidLoad()

        checkCameraAuthorizationStatus()
    }

    private func checkCameraAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video ) {
        case .authorized:
            return
        case .denied:
            return
        case .notDetermined:
            return
        case .restricted:
            return
        default:
            return
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        startLiveVideo()
        startTextDetection() // Vision Framework recognition
    }

    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }

    // Not sure if this is necessary but we'll see
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning() // Everytime the user changes between the tab bar the session needs to stop or the app will crash
        session = AVCaptureSession()
    }

    // MARK: - Methods
    /**
     Method that captures video from an AVCaptureSession and shows it in screen
     */
    func startLiveVideo() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) // Defined as video because a live stream is needed

        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice!) else {
            return
        }
        let deviceOutput = AVCaptureVideoDataOutput()

        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))

        deviceOutput.alwaysDiscardsLateVideoFrames = true

        session.addInput(deviceInput)
        session.addOutput(deviceOutput)

        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        imageLayer.frame = view.layer.frame
        imageView.layer.addSublayer(imageLayer)

        session.startRunning()
    }

    @IBAction func didTakePhoto(_ sender: Any) {
        takePhoto = true
    }



    /**
     Method that starts text detection with Vision Framework
     */
    func startTextDetection() {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler) // Request that only looks for rectangles with some text in them
        textRequest.reportCharacterBoxes = true
        self.requests = [textRequest]
    }

    /**
     Handles the request for text detection and also implements text recognition with Tesseract
     - parameters:
     - request: a Vision request
     - error: error that can be thrown
     */
    private func detectTextHandler(request: VNRequest, error: Error?) {
        // Variable that contains all the results of the request
        guard let observations = request.results, !observations.isEmpty else {
            print("No result")
            return
        }
        // Replace with Vision Text Recognition -> Possibly it doesn't have to go there

        let result = observations.map({$0 as? VNTextObservation})

        // Asynchronous call
        DispatchQueue.main.async {
            self.imageView.layer.sublayers?.removeSubrange(1...) // Removes the bottommost layer in imageView
            for region in result {
                guard let boxRegion = region else { // Checks if a region exists within the results from the obsevation
                    continue
                }

                self.hightlightWord(box: boxRegion)
           //     self.startTesseractTextRecognition()
            }
        }
    }

    private func startTesseractTextRecognition() {
        let swiftyTesseract = SwiftyTesseract(language: RecognitionLanguage.japanese)

        if let image = detectedTextImage {
            let scaledImage = image.scaledImage(1000) ?? image

            swiftyTesseract.performOCR(on: scaledImage) { recognizedString in
                guard let text = recognizedString else { return }
                print(text)
            }
        }
    }

    /**
     Method that defines the boxes for each word
     - Parameters:
     - box: Information about regions of text detected by an image analysis request.
     */
    func hightlightWord(box: VNTextObservation) {
        // Variable that is a combination of all the characterBoxes that the request has found
        guard let boxes = box.characterBoxes else {
            return
        }

        var maxX: CGFloat = 9999.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 9999.0
        var minY: CGFloat = 0.0

        for char in boxes {
            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
        }

        // Definition of some points on the view to help position the boxes
        let xCord = maxX * imageView.frame.size.width
        let yCord = (1 - minY) * imageView.frame.size.height
        let width = (minX - maxX) * imageView.frame.size.width
        let height = (minY - maxY) * imageView.frame.size.height

        // Creation of CALayer to apply it to the imageView
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor

        imageView.layer.addSublayer(outline)

    }

}

// MARK: - VisionViewController Extension

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    /**
     Function that takes the video output and converts it to a CMSampleBuffer
     */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        detectedTextImage = pixelBuffer.uiImage

        var requestOptions: [VNImageOption: Any] = [:]

        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: camData]
        }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)

        do {
            try imageRequestHandler.perform(self.requests)

        } catch {
            print(error)
        }

        if takePhoto {
            takePhoto = false
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToCameraVC", sender: nil)
                self.session.stopRunning()
            }
        }
    }
}
