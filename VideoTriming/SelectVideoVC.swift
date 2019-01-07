//
//  SelectVideoVC.swift
//  VideoTriming
//
//  Created by CTPLMac7 on 03/01/19.
//  Copyright © 2019 CTPLMac7. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import CoreMedia
import AssetsLibrary
import Photos

class SelectVideoVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        // Do any additional setup after loading the view.
    }
    
    func setNavigationBar()
    {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }

    
    @IBAction func btnClickSelectVideo(_ sender: UIButton)
    {
        let myImagePickerController        = UIImagePickerController()
        myImagePickerController.sourceType = .photoLibrary
        myImagePickerController.mediaTypes = [(kUTTypeMovie) as String]
        myImagePickerController.delegate   = self
        myImagePickerController.isEditing  = false
        self.present(myImagePickerController, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true, completion: nil)
        
        let url = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let asset   = AVURLAsset.init(url: url! as URL)
        
        let mainstoryBoard = UIStoryboard(name:"Main", bundle: nil)
        let viewcontroller = mainstoryBoard.instantiateViewController(withIdentifier:"ViewController") as! ViewController
        viewcontroller.url = url
        viewcontroller.asset = asset
        self.navigationController?.pushViewController(viewcontroller, animated: true)
        
        
    }
    
    @IBAction func btnClickRecordVideo(_ sender: UIButton)
    {
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
