//
//  ViewController.swift
//  VideoTriming
//
//  Created by CTPLMac7 on 02/01/19.
//  Copyright © 2019 CTPLMac7. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import CoreMedia
import AssetsLibrary
import Photos

class ViewController: UIViewController {
    
    var isPlaying = true
    var isSliderEnd = true
    var playbackTimeCheckerTimer: Timer! = nil
    let playerObserver: Any? = nil
    
    let exportSession: AVAssetExportSession! = nil
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    var asset: AVAsset!
    
    var url:NSURL! = nil
    var startTime: CGFloat = 0.0
    var stopTime: CGFloat  = 0.0
    var thumbTime: CMTime!
    var thumbtimeSeconds: Int!
    
    var videoPlaybackPosition: CGFloat = 0.0
    var cache:NSCache<AnyObject, AnyObject>!
    var rangSlider: RangeSlider! = nil
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var frameContainerView: UIView!
    @IBOutlet weak var imageFrameView: UIView!
    
    var startTimestr = ""
    var endTimestr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadViews()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        if let assets = asset
        {
        thumbTime = asset.duration
        thumbtimeSeconds      = Int(CMTimeGetSeconds(thumbTime))
        
        self.viewAfterVideoIsPicked()
        
        let item:AVPlayerItem = AVPlayerItem(asset: asset)
        player                = AVPlayer(playerItem: item)
        playerLayer           = AVPlayerLayer(player: player)
        playerLayer.frame     = videoPlayerView.bounds
        
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.actionAtItemEnd   = AVPlayer.ActionAtItemEnd.none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnvideoPlayerView))
        self.videoPlayerView.addGestureRecognizer(tap)
        self.tapOnvideoPlayerView(tap: tap)
        
        videoPlayerView.layer.addSublayer(playerLayer)
        player.play()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //Loading Views
    func loadViews()
    {
        //Whole layout view
        
        saveButton.layer.cornerRadius   = 5.0
        
        //Hiding buttons and view on load
        saveButton.isHidden         = false
        frameContainerView.isHidden = true
        
        
        imageFrameView.layer.cornerRadius = 5.0
        imageFrameView.layer.borderWidth  = 1.0
        imageFrameView.layer.borderColor  = UIColor.white.cgColor
        imageFrameView.layer.masksToBounds = true
        
        player = AVPlayer()
        
        
        //Allocating NsCahe for temp storage
        self.cache = NSCache()
    }
    
    
    //Action for crop video
    @IBAction func cropVideo(_ sender: Any)
    {
        let start = Float(startTimestr)
        let end   = Float(endTimestr)
        self.cropVideo(sourceURL1: url, startTime: start!, endTime: end!)
    }
    
}

//Subclass of VideoMainViewController
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    
    func viewAfterVideoIsPicked()
    {
        //Rmoving player if alredy exists
        if(playerLayer != nil)
        {
            playerLayer.removeFromSuperlayer()
        }
        
        self.createImageFrames()
        
        //unhide buttons and view after video selection
        saveButton.isHidden         = false
        frameContainerView.isHidden = false
        
        
        isSliderEnd = true
        startTimestr = "\(0.0)"
        endTimestr   = "\(thumbtimeSeconds!)"
        self.createrangSlider()
    }
    
    //Tap action on video player
    @objc func tapOnvideoPlayerView(tap: UITapGestureRecognizer)
    {
        if isPlaying
        {
            self.player.play()
        }
        else
        {
            self.player.pause()
        }
        isPlaying = !isPlaying
    }
    
    
    
    //MARK: CreatingFrameImages
    func createImageFrames()
    {
        //creating assets
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero;
        assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero;
        
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = asset.duration
        let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
        let maxLength         = "\(thumbtimeSeconds)" as NSString
        
        let thumbAvg  = thumbtimeSeconds/6
        var startTime = 1
        var startXPosition:CGFloat = 0.0
        
        //loop for 6 number of frames
        for _ in 0...5
        {
            
            let imageButton = UIButton()
            let xPositionForEach = CGFloat(self.imageFrameView.frame.width)/6
            imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(self.imageFrameView.frame.height))
            do {
                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                imageButton.setImage(image, for: .normal)
            }
            catch
                _ as NSError
            {
                print("Image generation failed with error (error)")
            }
            
            startXPosition = startXPosition + xPositionForEach
            startTime = startTime + thumbAvg
            imageButton.isUserInteractionEnabled = false
            imageFrameView.addSubview(imageButton)
        }
        
    }
    
    //Create range slider
    func createrangSlider()
    {
        //Remove slider if already present
        let subViews = self.frameContainerView.subviews
        for subview in subViews{
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        
        rangSlider = RangeSlider(frame: frameContainerView.bounds)
        frameContainerView.addSubview(rangSlider)
        rangSlider.tag = 1000
        
        //Range slider action
        rangSlider.addTarget(self, action: #selector(ViewController.rangSliderValueChanged(_:)), for: .valueChanged)
        
        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.rangSlider.trackHighlightTintColor = UIColor.clear
            self.rangSlider.curvaceousness = 1.0
        }
        
    }
    
    //MARK: rangSlider Delegate
    @objc func rangSliderValueChanged(_ rangSlider: RangeSlider) {
//        self.player.pause()
        
        if(isSliderEnd == true)
        {
            rangSlider.minimumValue = 0.0
            rangSlider.maximumValue = Double(thumbtimeSeconds)
            
            rangSlider.upperValue = Double(thumbtimeSeconds)
            isSliderEnd = !isSliderEnd
            
        }
        
        startTimestr = "\(rangSlider.lowerValue)"
        endTimestr   = "\(rangSlider.upperValue)"
        
        print(rangSlider.lowerLayerSelected)
        if(rangSlider.lowerLayerSelected)
        {
            self.seekVideo(toPos: CGFloat(rangSlider.lowerValue))
            
        }
        else
        {
            self.seekVideo(toPos: CGFloat(rangSlider.upperValue))
            
        }
        
        print(startTime)
    }
    //Seek video when slide
    func seekVideo(toPos pos: CGFloat) {
        self.videoPlaybackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: self.player.currentTime().timescale)
        self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if(pos == CGFloat(thumbtimeSeconds))
        {
            self.player.pause()
        }
    }
    
    //Trim Video Function
    func cropVideo(sourceURL1: NSURL, startTime:Float, endTime:Float)
    {
        let manager                 = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        guard let mediaType         = "mp4" as? String else {return}
        guard (sourceURL1 as? NSURL) != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String
        {
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")
            
            let start = startTime
            let end = endTime
            print(documentDirectory)
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                //let name = hostent.newName()
                outputURL = outputURL.appendingPathComponent("1.mp4")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                    self.saveToCameraRoll(URL: outputURL as NSURL!)
                case .failed:
                    print("failed \(exportSession.error)")
                    
                case .cancelled:
                    print("cancelled \(String(describing: exportSession.error))")
                    
                default: break
                }}}}
    
    //Save Video to Photos Library
    func saveToCameraRoll(URL: NSURL!) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL as URL)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: "Cropped video was saved successfully", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }}}
}

