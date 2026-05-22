import SwiftUI
import UVBurnTimerCore

/// WI-loop31-2 — Location Rationale Onboarding (LANE 1 #4).
///
/// Privacy-rationale sheet presented AFTER the Fitzpatrick skin-type
/// picker and BEFORE any call to
/// `CLLocationManager.requestWhenInUseAuthorization()`. Closes the only
/// LANE 1 surface from `.squad/files/user-flow-onboarding-main-spec.md`
/// that wasn't on `main`.
///
/// HIG-aligned:
///   • `.isHeader` trait on the title so VoiceOver announces it as a
///     heading and AX5 reflow groups subsequent body text under it.
///   • `@ScaledMetric` 44 pt CTA floor so the Continue button stays
///     tappable under Dynamic Type AX5.
///   • Continue CTA lives in `.safeAreaInset(.bottom)` per spec.
///   • SF Symbol `lock.shield` carries an explicit
///     `.accessibilityLabel` ("Privacy") so VoiceOver does not read
///     the raw symbol name.
///   • Decorative fade-in is gated on `accessibilityReduceMotion` so
///     vestibular-sensitive users see an instant render — satisfies
///     the AST `reduce_motion_unguarded_animation` rule.
///   • Two accessibility identifiers exposed for XCUI:
///     `LocationRationaleHeader` (title) and
///     `LocationRationaleContinueButton` (CTA).
struct LocationRationaleOnboardingView: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @ScaledMetric private var minTap: CGFloat = 44
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 56
    @State private var hasAppeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: heroIconSize, weight: .regular))
                        .foregroundStyle(.tint)
                        .accessibilityLabel("Privacy")
                        .padding(.top, 8)

                    Text(ProductCopy.locationRationaleTitle)
                        .font(.title2.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("LocationRationaleHeader")

                    Text(ProductCopy.locationRationaleBody)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(ProductCopy.locationPrivacyLine)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(hasAppeared || accessibilityReduceMotion ? 1 : 0)
                .animation(
                    accessibilityReduceMotion ? nil : .easeOut(duration: 0.25),
                    value: hasAppeared
                )
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button(action: onContinue) {
                    Text(ProductCopy.locationRationaleContinueLabel)
                        .frame(maxWidth: .infinity, minHeight: minTap)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
                .background(.bar)
                .accessibilityHint(ProductCopy.locationRationaleAccessibilityHint)
                .accessibilityIdentifier("LocationRationaleContinueButton")
            }
        }
        .interactiveDismissDisabled(true)
        .onAppear {
            if accessibilityReduceMotion {
                hasAppeared = true
            } else {
                hasAppeared = true
            }
        }
    }
}
