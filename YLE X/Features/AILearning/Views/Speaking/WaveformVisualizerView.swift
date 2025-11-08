//
//  WaveformVisualizerView.swift
//  YLE X
//
//  Created on November 7, 2025.
//  Phase 4: Real-time Audio Waveform Visualization
//

import SwiftUI

struct WaveformVisualizerView: View {
    let samples: [Float]
    let color: Color
    let lineWidth: CGFloat
    let animationDuration: Double

    init(
        samples: [Float],
        color: Color = .appPrimary,
        lineWidth: CGFloat = 2,
        animationDuration: Double = 0.1
    ) {
        self.samples = samples
        self.color = color
        self.lineWidth = lineWidth
        self.animationDuration = animationDuration
    }

    var body: some View {
        Canvas { context, size in
            let path = createWaveformPath(samples: samples, size: size)

            context.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [color, color.opacity(0.6)]),
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: size.height)
                ),
                lineWidth: lineWidth
            )

            // Fill area under waveform
            var fillPath = path
            fillPath.addLine(to: CGPoint(x: size.width, y: size.height / 2))
            fillPath.addLine(to: CGPoint(x: 0, y: size.height / 2))
            fillPath.closeSubpath()

            context.fill(
                fillPath,
                with: .linearGradient(
                    Gradient(colors: [color.opacity(0.3), color.opacity(0.1)]),
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: size.height)
                )
            )
        }
        .frame(height: 80)
        .animation(.easeInOut(duration: animationDuration), value: samples)
    }

    private func createWaveformPath(samples: [Float], size: CGSize) -> Path {
        var path = Path()

        guard !samples.isEmpty else {
            // Draw center line if no samples
            path.move(to: CGPoint(x: 0, y: size.height / 2))
            path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
            return path
        }

        let midY = size.height / 2
        let maxAmplitude = size.height / 2 - 10 // Leave some padding

        let stepX = size.width / CGFloat(samples.count)

        for (index, sample) in samples.enumerated() {
            let x = CGFloat(index) * stepX
            let amplitude = CGFloat(sample) * maxAmplitude

            let y = midY + amplitude * (index % 2 == 0 ? -1 : 1) // Alternate up/down

            if index == 0 {
                path.move(to: CGPoint(x: x, y: midY))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}

// MARK: - Bar Style Waveform

struct BarWaveformView: View {
    let samples: [Float]
    let color: Color
    let barCount: Int

    init(
        samples: [Float],
        color: Color = .appPrimary,
        barCount: Int = 50
    ) {
        self.samples = samples
        self.color = color
        self.barCount = barCount
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<barCount, id: \.self) { index in
                    let value = getValue(at: index)
                    let barHeight = max(2, geometry.size.height * CGFloat(value))

                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: max(1, geometry.size.width / CGFloat(barCount) - 2), height: barHeight)
                        .animation(.spring(response: 0.2), value: value)
                }
            }
            .frame(maxHeight: geometry.size.height, alignment: .center)
        }
        .frame(height: 60)
    }

    private func getValue(at index: Int) -> Float {
        guard !samples.isEmpty else { return 0.1 }

        let samplesPerBar = max(1, samples.count / barCount)
        let startIndex = index * samplesPerBar
        let endIndex = min(startIndex + samplesPerBar, samples.count)

        if startIndex >= samples.count {
            return 0.1
        }

        let barSamples = Array(samples[startIndex..<endIndex])
        let average = barSamples.reduce(0, +) / Float(barSamples.count)

        return max(0.1, average) // Minimum 10% height
    }
}

// MARK: - Circular Waveform

struct CircularWaveformView: View {
    let samples: [Float]
    let color: Color

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - 20

            guard !samples.isEmpty else { return }

            let angleStep = (2 * .pi) / Double(samples.count)

            for (index, sample) in samples.enumerated() {
                let angle = Double(index) * angleStep
                let amplitude = CGFloat(sample) * 30

                let innerRadius = radius - amplitude / 2
                let outerRadius = radius + amplitude / 2

                let startPoint = CGPoint(
                    x: center.x + innerRadius * CGFloat(cos(angle)),
                    y: center.y + innerRadius * CGFloat(sin(angle))
                )

                let endPoint = CGPoint(
                    x: center.x + outerRadius * CGFloat(cos(angle)),
                    y: center.y + outerRadius * CGFloat(sin(angle))
                )

                var path = Path()
                path.move(to: startPoint)
                path.addLine(to: endPoint)

                context.stroke(
                    path,
                    with: .color(color),
                    lineWidth: 2
                )
            }
        }
        .frame(width: 200, height: 200)
        .animation(.easeInOut(duration: 0.1), value: samples)
    }
}

// MARK: - Preview

#Preview("Linear Waveform") {
    VStack(spacing: AppSpacing.lg) {
        WaveformVisualizerView(
            samples: (0..<100).map { _ in Float.random(in: 0...1) },
            color: .appPrimary
        )

        WaveformVisualizerView(
            samples: (0..<100).map { _ in Float.random(in: 0...0.5) },
            color: .appAccent
        )
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Bar Waveform") {
    BarWaveformView(
        samples: (0..<100).map { _ in Float.random(in: 0...1) },
        color: .appPrimary
    )
    .padding()
    .background(Color.appBackground)
}

#Preview("Circular Waveform") {
    CircularWaveformView(
        samples: (0..<60).map { _ in Float.random(in: 0...1) },
        color: .appPrimary
    )
    .padding()
    .background(Color.appBackground)
}
