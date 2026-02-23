import SwiftUI

struct FilterDetailView: View {
    @Bindable var viewModel: CineMagicViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Filter Info
                    filterInfoCard

                    // Filter Parameters
                    parametersSection

                    // Custom Adjustments
                    customAdjustments

                    // All Filters Comparison
                    filtersComparison
                }
                .padding()
            }
            .navigationTitle("フィルター設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Filter Info

    private var filterInfoCard: some View {
        VStack(spacing: 12) {
            Text(viewModel.selectedFilter.emoji)
                .font(.system(size: 48))

            Text(viewModel.selectedFilter.rawValue)
                .font(.title2)
                .fontWeight(.bold)

            Text(viewModel.selectedFilter.directorName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.selectedFilter.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("代表作: \(viewModel.selectedFilter.representativeWork)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.selectedFilter.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Parameters

    private var parametersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "camera.filters")
                    .foregroundStyle(.orange)
                Text("フィルターパラメータ")
                    .font(.headline)
                    .fontWeight(.bold)
            }

            let params = viewModel.selectedFilter.parameters

            parameterRow(label: "明るさ", value: params.brightness, range: -0.2...0.2)
            parameterRow(label: "コントラスト", value: params.contrast, range: 0.5...2.0)
            parameterRow(label: "彩度", value: params.saturation, range: 0.0...2.0)
            parameterRow(label: "色温度", value: params.temperature, range: 3000...10000)
            parameterRow(label: "ビネット", value: params.vignetteIntensity, range: 0.0...1.5)
            parameterRow(label: "グレイン", value: params.grainAmount, range: 0.0...0.3)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func parameterRow(label: String, value: Double, range: ClosedRange<Double>) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geo in
                let normalized = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
                let barWidth = max(0, min(geo.size.width, geo.size.width * normalized))

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(viewModel.selectedFilter.color)
                        .frame(width: barWidth, height: 8)
                }
            }
            .frame(height: 8)

            Text(String(format: "%.2f", value))
                .font(.caption)
                .monospacedDigit()
                .frame(width: 50, alignment: .trailing)
        }
    }

    // MARK: - Custom Adjustments

    private var customAdjustments: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.blue)
                Text("カスタム調整")
                    .font(.headline)
                    .fontWeight(.bold)
            }

            VStack(spacing: 8) {
                adjustmentSlider(label: "明るさ", value: $viewModel.customBrightness, range: -0.5...0.5)
                adjustmentSlider(label: "コントラスト", value: $viewModel.customContrast, range: 0.5...2.0)
                adjustmentSlider(label: "彩度", value: $viewModel.customSaturation, range: 0.0...2.0)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func adjustmentSlider(label: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.2f", value.wrappedValue))
                    .font(.caption)
                    .monospacedDigit()
            }
            Slider(value: value, in: range)
                .tint(viewModel.selectedFilter.color)
        }
    }

    // MARK: - Filters Comparison

    private var filtersComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.3.group")
                    .foregroundStyle(.purple)
                Text("フィルター一覧")
                    .font(.headline)
                    .fontWeight(.bold)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                ForEach(CineFilter.allCases) { filter in
                    Button {
                        viewModel.selectFilter(filter)
                    } label: {
                        VStack(spacing: 8) {
                            Text(filter.emoji)
                                .font(.title)

                            Text(filter.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)

                            Text(filter.description)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            viewModel.selectedFilter == filter
                                ? filter.color.opacity(0.2)
                                : Color(.systemGray6)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    viewModel.selectedFilter == filter
                                        ? filter.color
                                        : .clear,
                                    lineWidth: 2
                                )
                        )
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    FilterDetailView(viewModel: CineMagicViewModel())
}
