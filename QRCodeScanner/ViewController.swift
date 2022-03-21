//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Alina Sokolova on 14.03.22.
//

import UIKit
import AVFoundation

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
}

class ViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    

    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var messageLabel: UILabel!
   
    
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR-code is detected"
            messageLabel.isUserInteractionEnabled = true
            let tapgestures = UITapGestureRecognizer(target: self, action: #selector(cliclLabelWnenNoQR))
            tapgestures.numberOfTapsRequired = 1
            messageLabel.addGestureRecognizer(tapgestures)
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObj = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObj!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                messageLabel.isUserInteractionEnabled = true
                let tapgetures = UITapGestureRecognizer(target: self, action: #selector(clickLabel))
                tapgetures.numberOfTapsRequired = 1
                messageLabel.addGestureRecognizer(tapgetures)
                
            }
            
        }

    }
    
    @objc func cliclLabelWnenNoQR() {
        let alert = UIAlertController(title: "QR-код не найден", message: "Пожалуйста, наведите камеру на QR-код", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func clickLabel() {
        let alert = UIAlertController(title: "QR-код",
                                      message: messageLabel.text,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Перейти",
                                      style: .default, handler: { (action) in
            if let url = URL(string: self.messageLabel.text!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Копировать", style: .default, handler: { (action) in
            UIPasteboard.general.string = self.messageLabel.text
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//       image = UIImage(named: "safari")!
//        imageSafari.image = image
//        view.addSubview(imageSafari)
        
        // получить заднюю камеру для захвата видео
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
            
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //установить устройство ввода в сеансе камеры
            captureSession.addInput(input)
            // Инициализируй AVCaptureMetadataOutput объект и установи его в качестве устройства вывода для сеанса захвата
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            // установи делегат и использeq очередь отправки по умолчанию для выполнения обратного вызова
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            // Инициализируй слой предварительного просмотра видео и добавь его в качестве подслоя к слою представления viewPreview
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Начать захват видео
            captureSession.startRunning()
            // переместить метку сообщения и верхнюю панель на передний план
            view.bringSubviewToFront(messageLabel)
            view.bringSubviewToFront(topBar)
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.red.cgColor

                qrCodeFrameView.layer.borderWidth = 3
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
           
        } catch {
            // если появляется ошибка, проще распечатать и не продолжать больше
            print(error)
            return
        }
    }
}

