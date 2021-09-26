//
//  TrackDetailView.swift
//  MusicApp
//
//  Created by Дмитрий Осипенко on 30.08.21.
//

import UIKit
import SDWebImage
import AVKit

protocol TrackMovingDelegate: AnyObject {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell?
    
}

class TrackDetailView: UIView {
    
    @IBOutlet weak var miniPlayPaauseButton: UIButton!
    @IBOutlet weak var miniTrackTitleLable: UILabel!
    @IBOutlet weak var miniTrackImageView: UIImageView!
    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLable: UILabel!
    @IBOutlet weak var durationLable: UILabel!
    @IBOutlet weak var trackTitleLable: UILabel!
    @IBOutlet weak var autorTitleLable: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var miniGoForwardButton: UIButton!
    @IBOutlet weak var maximazedStackView: UIStackView!
    
    let player: AVPlayer = {
       let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    weak var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MainTabBatControllerDelegate?
    
    //MARK: - awakeFromNib
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 5
        miniPlayPaauseButton.imageEdgeInsets = .init(top: 11, left: 11, bottom: 11, right: 11)
        setupGestures()
        
    }
    
    //MARK: - Setup
    
    func set(viewModel: SearchViewModel.Cell) {
        miniTrackTitleLable.text = viewModel.trackName
        trackTitleLable.text = viewModel.trackName
        autorTitleLable.text = viewModel.artistName
        playTrack(previewUrl: viewModel.previewUrl)
        monitorStartTime()
        observePlayerCurrentTime()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPaauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let url = URL(string: string600 ?? "") else {return}
        miniTrackImageView.sd_setImage(with: url, completed: nil)
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    private func setupGestures() {
        miniTrackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximazed)))
        miniTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismisPan)))
    }

    
    private func playTrack(previewUrl: String?) {
        guard let url = URL(string: previewUrl ?? "") else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    //MARK: - Min and Max gestures
    
    @objc func handleTapMaximazed() {
        self.tabBarDelegate?.maximazedTrackDetailController(viewModel: nil)
    }
    @objc func handlePan(gestures: UIPanGestureRecognizer) {
        switch gestures.state {
        case .began:
            print("began")
        case .changed:
            handlePanGestures(gestures: gestures)
        case .ended:
            handlePanEnded(gesture: gestures)

        @unknown default:
            print("unknown default")
        }
    }
    
    func handlePanGestures(gestures: UIPanGestureRecognizer) {
        let translation = gestures.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximazedStackView.alpha = -translation.y / 200
    }
    
    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let valocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = .identity
            if translation.y < 200 || valocity.y < -500 {
                self.tabBarDelegate?.maximazedTrackDetailController(viewModel: nil)
            }else {
                self.miniTrackView.alpha = 1
                self.maximazedStackView.alpha = 0
            }
        }, completion: nil)
    }
    
    @objc func handleDismisPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: superview)
            maximazedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.maximazedStackView.transform = .identity
                if translation.y > 50 {
                    self.tabBarDelegate?.minimazedTrackDetailController()
                }
            }, completion: nil)
        @unknown default:
            print("unknown default")
        }
    }
    
    //MARK: - TimeSetup
    
    func monitorStartTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enLargeImageView()
        }
    }
    
    private func observePlayerCurrentTime() {
        let intervar = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: intervar, queue: .main) {[weak self] time in
            self?.currentTimeLable.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLable.text = currentDurationText
            self?.updateCurrentTimeSlider()
        }
    }
    
    
    private func updateCurrentTimeSlider() {
        let currentTimeSecond = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let persentage = currentTimeSecond / durationSeconds
        self.currentTimeSlider.value = Float(persentage)
    }
    
    
    
    //MARK: - Animations
    
    func enLargeImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.trackImageView.transform = .identity
        }, completion: nil)
    }
    
    func reduseLargeImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            let scale: CGFloat = 0.8
            self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
    
    //MARK: - IBAction
    @IBAction func handleCurrentTimeSlider(_ sender: Any) {
        let persentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeUnSeconds = Float64(persentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeUnSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
    
    @IBAction func dragDownButtonTapped(_ sender: Any) {
        tabBarDelegate?.minimazedTrackDetailController()
//        self.removeFromSuperview()
    }
    @IBAction func previouseTrack(_ sender: Any) {
        let cellViewModel = delegate?.moveBackForPreviousTrack()
         guard let cellInfo = cellViewModel else {return}
         self.set(viewModel: cellInfo)
    }
    
    @IBAction func nextTrack(_ sender: Any) {
       let cellViewModel = delegate?.moveForwardForPreviousTrack()
        guard let cellInfo = cellViewModel else {return}
        self.set(viewModel: cellInfo)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayPaauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enLargeImageView()
        }else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayPaauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            reduseLargeImageView()
        }
    }
}
