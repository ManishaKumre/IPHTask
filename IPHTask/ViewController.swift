//
//  ViewController.swift
//  IPHTask
//
//  Created by Manisha Kumre on 03/05/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var audioVisualizerView: UIView!
    @IBOutlet weak var playbtn: UIButton!
    //    var audioPlayer:AVAudioPlayer?
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var visualizerLines = [CAShapeLayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressbar.progress = 0
        setupAudioVisualizer()
        setupAudioPlayer()
        
        setupProgressBarGesture()
        }

        func setupProgressBarGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProgressBarTap(_:)))
            progressbar.addGestureRecognizer(tapGesture)
            progressbar.isUserInteractionEnabled = true
        }

        @objc func handleProgressBarTap(_ gesture: UITapGestureRecognizer) {
            let tapPoint = gesture.location(in: progressbar)
            let progress = tapPoint.x / progressbar.bounds.width
            guard let player = audioPlayer else { return }
            let seekTime = TimeInterval(progress) * player.duration
            player.currentTime = seekTime
            updateProgressBar()
        }
    
    
    func setupAudioVisualizer() {
        // Configure the appearance of the audio visualizer view
        audioVisualizerView.backgroundColor = .clear
    }
    
    func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: "sunlit-whistle-200168", withExtension: "mp3") else {
            fatalError("Audio file not found")
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.isMeteringEnabled = true
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }
    
    @IBAction func PlaybtnTap(_ sender: Any) {
        
        if let player = audioPlayer {
               if player.isPlaying {
                   player.pause()
                   timer?.invalidate()
                   playbtn.setImage(UIImage(systemName: "play.fill"), for: .normal) // Use system play image
               } else {
                   player.play()
                   timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                       self?.updateAudioVisualizer()
                       self?.updateProgressBar()
                   }
                   playbtn.setImage(UIImage(systemName: "pause.fill"), for: .normal) // Use system pause image
               }
           }
        
        
    }


func updateAudioVisualizer() {
    guard let audioPlayer = audioPlayer else { return }
    audioPlayer.updateMeters()
    
    let numberOfLines = 20 // Define the number of lines in the visualizer
    let lineWidth = CGFloat(3) // Adjust the width of the lines
    
    for index in 0..<numberOfLines {
        let power = audioPlayer.averagePower(forChannel: 0)
        let normalizedValue = pow(10, power / 20)
        let lineHeight = min(CGFloat(normalizedValue) * audioVisualizerView.bounds.height * 1.5, audioVisualizerView.bounds.height)
        
        let linePath = UIBezierPath()
        let startX = CGFloat(index) * (lineWidth + 5) + lineWidth / 2.0 // Adjust spacing between lines
        
        // Calculate the y-coordinate based on the sine wave pattern for both the top and bottom halves
        let angle = CGFloat(index) / CGFloat(numberOfLines - 1) * CGFloat.pi // Adjusted to cover the full range from 0 to pi
        let yOffset = sin(angle) * lineHeight * 0.5 // Adjust the amplitude of the wave
        let yCoordinateTop = audioVisualizerView.bounds.height / 2 + yOffset
        let yCoordinateBottom = audioVisualizerView.bounds.height / 2 - yOffset
        
        // Alternate lines between top and bottom
        let yCoordinate = index % 2 == 0 ? yCoordinateTop : yCoordinateBottom
        
        linePath.move(to: CGPoint(x: startX, y: audioVisualizerView.bounds.height))
        linePath.addLine(to: CGPoint(x: startX, y: yCoordinate))
        
        if index < visualizerLines.count {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.05)
            visualizerLines[index].path = linePath.cgPath
            CATransaction.commit()
        } else {
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = UIColor.green.cgColor // Customize color as needed
            lineLayer.lineWidth = lineWidth
            lineLayer.lineCap = .square
            audioVisualizerView.layer.addSublayer(lineLayer)
            visualizerLines.append(lineLayer)
        }
    }


}


    func updateProgressBar() {
        guard let player = audioPlayer else { return }
        let currentTime = player.currentTime
        let duration = player.duration
        
        // Update progress bar
        progressbar.progress = Float(currentTime / duration)
        
        // Calculate current and total time in minutes and seconds
        let currentMinutes = Int(currentTime / 60)
        let currentSeconds = Int(currentTime.truncatingRemainder(dividingBy: 60))
        let durationMinutes = Int(duration / 60)
        let durationSeconds = Int(duration.truncatingRemainder(dividingBy: 60))
        
        // Update time label with formatted string
        timeLabel.text = String(format: "%02d:%02d / %02d:%02d", currentMinutes, currentSeconds, durationMinutes, durationSeconds)
    }
  
}




