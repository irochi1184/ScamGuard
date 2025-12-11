import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    summaryCard
                    toggleSection
                    riskEventSection
                    advisorySection
                    blockedListSection
                }
                .padding()
            }
            .navigationTitle("ScamGuard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.refreshPoliceList) {
                        Label("更新", systemImage: "arrow.clockwise")
                    }
                    .accessibilityLabel("警察庁リストを更新")
                }
            }
            .task {
                viewModel.refreshPoliceList()
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI・警察庁推奨リスト連携")
                .font(.headline)
            Text("リスク検知件数: \(viewModel.detectedRiskCount)")
                .font(.title2.weight(.bold))
            Button("検知カウンターをリセット") {
                viewModel.resetCounters()
            }
            .buttonStyle(.bordered)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var toggleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ブロック・警告設定")
                .font(.headline)
            Toggle("国際番号（+から始まる番号）を遮断", isOn: $viewModel.internationalBlockEnabled)
            Toggle("警察庁リストの番号を遮断", isOn: $viewModel.isIncomingBlockEnabled)
            Toggle("詐欺と疑われる発信を警告", isOn: $viewModel.isOutgoingBlockEnabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    private var riskEventSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI検知ログ")
                .font(.headline)

            if viewModel.recentRiskEvents.isEmpty {
                Text("検知されたリスクイベントはまだありません。")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.recentRiskEvents) { event in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.message)
                            .font(.subheadline)
                        Text(event.formattedTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var advisorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最新の防犯情報")
                .font(.headline)
            if let advisory = viewModel.latestAdvisory {
                Text(advisory)
            } else {
                Text("防犯情報を取得中...")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var blockedListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("遮断予定リスト")
                    .font(.headline)
                Spacer()
                Button(action: viewModel.refreshPoliceList) {
                    Label("更新", systemImage: "arrow.clockwise")
                }
                .labelStyle(.iconOnly)
            }

            ForEach(viewModel.blockedNumbers) { number in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(number.displayName)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(number.source.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(number.number)
                        .font(.body.monospaced())
                    Text(number.reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            }

            if viewModel.blockedNumbers.isEmpty {
                Text("警察庁推奨リストを取得して遮断対象を表示します。")
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel())
}
