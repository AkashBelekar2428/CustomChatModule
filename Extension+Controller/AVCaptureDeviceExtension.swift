//
//  AVCaptureDeviceExtension.swift
//  Peeks
//
//  Created by Matheus Ruschel on 2017-02-07.
//  Copyright © 2017 Riavera. All rights reserved.
//

import AVFoundation
import UIKit

extension AVCaptureDevice {
    
    class func cameraIsAllowed() -> Bool {
        
        let isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        if isCameraAvailable {
            
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            if status == AVAuthorizationStatus.denied || status ==  AVAuthorizationStatus.notDetermined {
                return false
            }
        }
        return true
        
    }
}
