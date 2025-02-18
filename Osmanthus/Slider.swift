import SwiftUI
import AVFoundation

struct AudioSliderView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var sliderValue: Double = 0
    @State private var duration: Double = 1
    @State private var isDragging = false
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Slider(value: $sliderValue, in: 0...duration, onEditingChanged: { editing in
                if editing {
                    pauseAudio()
                } else {
                    seekAudio(to: sliderValue)
                    playAudio()
                }
            })
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let width = UIScreen.main.bounds.width - 32 // スライダーの幅（適宜調整）
                        let newValue = (value.location.x / width) * duration
                        sliderValue = min(max(newValue, 0), duration)
                        seekAudio(to: sliderValue)
                    }
            )
            .padding()

            Button(action: {
                if let player = audioPlayer, player.isPlaying {
                    pauseAudio()
                } else {
                    playAudio()
                }
            }) {
                Text(audioPlayer?.isPlaying == true ? "Pause" : "Play")
            }
        }
        .onAppear {
            setupAudio()
        }
    }

    // オーディオのセットアップ
    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "sample", withExtension: "mp3") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayer = player
            duration = player.duration
            startTimer()
        } catch {
            print("Error loading audio: \(error)")
        }
    }

    // 再生処理
    private func playAudio() {
        audioPlayer?.play()
        startTimer()
    }

    // 一時停止処理
    private func pauseAudio() {
        audioPlayer?.pause()
        stopTimer()
    }

    // 指定位置へシーク
    private func seekAudio(to time: Double) {
        audioPlayer?.currentTime = time
        sliderValue = time
    }

    // 再生位置を監視するタイマー
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = audioPlayer, !isDragging else { return }
            sliderValue = player.currentTime
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}