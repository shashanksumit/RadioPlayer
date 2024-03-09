//
//  RadioCollectionViewController.swift
//  videoPlayer
//
//  Created by Sproxil IN on 15/01/20.
//  Copyright © 2020 Sproxil IN. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer


class RadioCollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var radioChannelName: UILabel!
    @IBOutlet weak var bottomConstarint: NSLayoutConstraint!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playView: UIView!
    var session = AVAudioSession.sharedInstance()
    var player:AVPlayer?
    var fileUrl:URL?
    var isplaying = false
    var selectedChannel = 0
    var radioMenuArray = ImageAndLinkClass.dashboardImagesAndLinks//[[Any]]()
    //var indexArr:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //isModalInPresentation = true
        playView.isHidden = true
        collectionView.layoutIfNeeded()
        playView.layer.cornerRadius = 10.0
        playView.layer.shadowRadius = 5.0
        
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            updateTrackDetailsOnRemote()
        } catch {
            print("error.")
        }
        
    }
    
    func updateTrackDetailsOnRemote() {
        
        MPRemoteCommandCenter.shared().playCommand.addTarget {event in
            if self.player?.rate == 1.0{
                self.player?.pause()
                self.player = nil
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                    MPMediaItemPropertyTitle: self.radioChannelName.text ?? ""]
            }else{
                let data = self.radioMenuArray[self.selectedChannel]
                self.fileUrl = URL(string: data[1] as! String)
                self.radioChannelName.text = (data[2] as? String ?? "").uppercased()
                self.play(url: self.fileUrl! as NSURL)
                MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                    MPMediaItemPropertyTitle: self.radioChannelName.text ?? "",
                    MPNowPlayingInfoPropertyIsLiveStream: true]
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: data[0] as? UIImage ?? UIImage(resource: .radio))
            }
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {event in
            self.player?.pause()
            self.player = nil
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: self.radioChannelName.text ?? ""]
            return .success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {event in
            if self.selectedChannel == self.radioMenuArray.count - 1 {
                self.selectedChannel = 0
            } else {
                self.selectedChannel += 1
            }
            let data = self.radioMenuArray[self.selectedChannel]
            self.fileUrl = URL(string: data[1] as! String)
            self.radioChannelName.text = (data[2] as? String ?? "").capitalized
            self.play(url: self.fileUrl! as NSURL)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: self.radioChannelName.text ?? "",
                MPNowPlayingInfoPropertyIsLiveStream: true]
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: data[0] as? UIImage ?? UIImage(resource: .radio))
            return .success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {event in
            if self.selectedChannel == 0 {
                self.selectedChannel = self.radioMenuArray.count - 1
            } else {
                self.selectedChannel -= 1
            }
            let data = self.radioMenuArray[self.selectedChannel]
            self.fileUrl = URL(string: data[1] as! String)
            self.radioChannelName.text = (data[2] as? String ?? "").capitalized
            self.play(url: self.fileUrl! as NSURL)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: self.radioChannelName.text ?? "",
                MPNowPlayingInfoPropertyIsLiveStream: true]
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: data[0] as? UIImage ?? UIImage(resource: .radio))
            return .success
        }
    }
    
    func playViewShow(){
        playView.isHidden = false
        playPauseButton.setImage(UIImage(named: "stopImage"), for: .normal)
        bottomConstarint.constant = 0
        self.view.bringSubviewToFront(playView)
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        player?.pause()
        player = nil
    }
    
    func play(url:NSURL) {
        print("playing \(url)")
        player = AVPlayer()
        do {
            
            let playerItem = AVPlayerItem(url: url as URL)
            player =  AVPlayer(playerItem:playerItem)
            player?.cancelPendingPrerolls()
            player?.play()
            playViewShow()
        }
    }
    
    @IBAction func playPauseButton(_ sender: Any) {
        if isplaying {
            isplaying.toggle()
            player?.pause()
            player = nil
            playPauseButton.setImage(UIImage(named: "playImage"), for: .normal)
            playPauseButton.accessibilityLabel = "Stop"
            FileManager.default.clearTmpDirectory()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                
                UIView.transition(with: self.playView, duration: 1.0, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                    self.bottomConstarint.constant = 150
                    self.playView.isHidden = true
                }, completion: nil)
            }
            
        }else{
            isplaying.toggle()
            play(url: self.fileUrl! as NSURL)
            playPauseButton.setImage(UIImage(named: "stopImage"), for: .normal)
            playPauseButton.accessibilityLabel = "Play"
        }
    }
    
}

extension RadioCollectionViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        radioMenuArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellArray = radioMenuArray[indexPath.row]
        let eqCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let radioImage:UIImageView? = (eqCell.viewWithTag(1) as? UIImageView)
        radioImage?.image = cellArray[0] as? UIImage
        eqCell.layer.cornerRadius = 10
        return eqCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        collectionView.layoutIfNeeded()
        let padding: CGFloat = 10
        let collectionViewSize = UIScreen.main.bounds.size.width - padding
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playPauseButton.setImage(UIImage(named: "playImage"), for: .normal)
        player?.pause()
        player = nil
        selectedChannel = indexPath.row
        let data = self.radioMenuArray[indexPath.row]
        let fileUrl = URL(string: data[1] as! String)
        radioChannelName.text = (data[2] as? String ?? "").uppercased()
        radioChannelName.sizeToFit()
        radioChannelName.accessibilityLabel = "Station"
        self.fileUrl = fileUrl
        if !isplaying{
            playPauseButton(UIButton.self)
        }else{
            self.play(url: self.fileUrl! as NSURL)
        }
    }
}
extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
                print("File Path: ", file, fileUrl.path)
            }
        } catch {
           print("Temp Files Error")
        }
    }
}
