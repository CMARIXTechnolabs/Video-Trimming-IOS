# Video Trimming - iOS
<a target="_blank" href="LICENSE"><img src="https://img.shields.io/badge/licence-MIT-brightgreen.svg" alt="license : MIT"></a>
<a target="_blank" href="https://www.cmarix.com/ios-app-development-company-india.html"><img src="https://img.shields.io/badge/platform-iOS-blue.svg" alt="platform : iOS"></a>

## Core Features ##
 - Video can be trimmed/shortened and played on the same screen
 - Video can be trimmed by selecting the starting point and ending point
 - Seekbar moves as per selected video for trimming
 - After trimming, trimmed video can be played automatically 

## How it works ##
 - User can select video from gallery
 - Set the selected video in the trimming screen
 - Trim the video by dragging starting point and end point
 - View trimmed video on the trimming screen
 - Save video, it will automatically play in next screen

## Purpose of this code ##
 - Whenever it is required to crop thr video, this code can help you
 - Whenever you are having a limiation of video recording such as allow users to record video for 1 min, this code can help you

## Requirements ##
 - iOS 11+ 


## When you can use this code ##

 - When you are developing a Social or standalone video sharing app, this code will help you to provide functinality of trimming video and sharing video with user friendly operations.

## Code Snippet ##

**Step 1**: Select video from Gallery using imagePickerController()

    @IBAction func btnClickSelectVideo(_ sender: UIButton)
    {
        let myImagePickerController        = UIImagePickerController()
        myImagePickerController.sourceType = .photoLibrary
        myImagePickerController.mediaTypes = [(kUTTypeMovie) as String]
        myImagePickerController.delegate   = self
        myImagePickerController.isEditing  = false
        self.present(myImagePickerController, animated: true, completion: nil)
        
    }
    
    // Image picker to get video url
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
        }
**Step 2**: Set video URL in AVPlayerItem 

	// set video url in AVPlayerItem
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
        
 
**Step 3**: To play video tapOnvideoPlayerView() method is used
  

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


**Step 4**: To create seekbar createImageFrames() is used

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
    


 **Step 5**: createrangSlider() is used to move seekbar as per input from client  
 

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
    

 **Step 5**: To synchronize video frames with time setTimeFrames() is used
 


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

 **Step 6**: cropVideo() method is used to save trimmed video

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

## Let us know! ##
We’d be really happy if you sent us links to your projects where you use our component. Just send an email to [biz@cmarix.com](mailto:biz@cmarix.com "biz@cmarix.com") and do let us know if you have any questions or suggestion regarding video trimming in iOS.

P.S. We’re going to publish more awesomeness examples on third party libaries, coding standards, plugins etc, in all the technology. Stay tuned!

## License ##

	MIT License
	
	Copyright © 2019 CMARIX TechnoLabs
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
