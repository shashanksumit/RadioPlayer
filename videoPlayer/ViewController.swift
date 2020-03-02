//
//  ViewController.swift
//  videoPlayer
//
//  Created by Sproxil IN on 13/01/20.
//  Copyright © 2020 Sproxil IN. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "RadioCollectionViewController")
            controller?.modalPresentationStyle = .fullScreen
            self.present(controller!, animated: true, completion: nil)
        }
    }

}

