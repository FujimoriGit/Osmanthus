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
            // カスタム Slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // スライダーの背景
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)

                    // 現在位置を示す進捗バー
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: CGFloat(sliderValue / duration) * geometry.size.width, height: 4)
                        .cornerRadius(2)

                    // スライダーのドラッグハンドル
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                        .offset(x: CGFloat(sliderValue / duration) * geometry.size.width - 10)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let newValue = min(max(0, value.location.x / geometry.size.width * duration), duration)
                                    sliderValue = newValue
                                    pauseAudio()
                                    isDragging = true
                                }
                                .onEnded { _ in
                                    seekAudio(to: sliderValue)
                                    playAudio()
                                    isDragging = false
                                }
                        )
                }
            }
            .frame(height: 30)
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