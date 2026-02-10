//
//  CaptureView.swift
//  MoodMoments
//
//  Created by Julien Avezou on 09/02/2026.
//

import SwiftUI
import PhotosUI
import SwiftData
import Photos

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var authStatus: PHAuthorizationStatus = .notDetermined
    @State private var enableGestureScoring = true

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var processing = false
    @State private var errorText: String?

    @State private var draftMoment: Moment?
    @State private var overlayPreview: Image?

    private let photos = PhotoLibraryService()
    private let pipeline = MomentPipeline()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    permissionsCard

                    Toggle("Try gesture scoring (beta)", isOn: $enableGestureScoring)

                    HStack {
                        Button {
                            Task { await importLatest() }
                        } label: {
                            Label("Import Latest", systemImage: "arrow.down.circle")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(processing || !canReadPhotos)

                        PhotosPicker(selection: $pickerItems, matching: .images, photoLibrary: .shared()) {
                            Label("Pick Photos", systemImage: "photo.on.rectangle")
                        }
                        .buttonStyle(.bordered)
                        .disabled(processing)
                    }

                    if processing {
                        ProgressView("Processing…")
                            .padding(.top, 8)
                    }

                    if let errorText {
                        Text(errorText).foregroundStyle(.red)
                    }

                    if let overlayPreview {
                        overlayPreview
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.top, 8)
                    }

                    if let moment = draftMoment {
                        draftEditor(moment: moment)
                    }
                }
                .padding()
            }
            .navigationTitle("Capture")
            .onAppear {
                authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            }
            .onChange(of: pickerItems) { _, newItems in
                guard let first = newItems.first else { return }
                Task { await importFromPicker(first) }
            }
        }
    }

    private var canReadPhotos: Bool {
        authStatus == .authorized || authStatus == .limited
    }

    private var permissionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Permissions").font(.headline)

            HStack {
                Text("Photos: \(statusText(authStatus))")
                Spacer()
                Button("Request") {
                    Task {
                        authStatus = await photos.requestAuth()
                    }
                }
            }

            Text("Tip: If Photos is Limited, Import Latest may not see the newest glasses photo. Use Pick Photos to add it.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statusText(_ s: PHAuthorizationStatus) -> String {
        switch s {
        case .authorized: return "Authorized"
        case .limited: return "Limited"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not determined"
        @unknown default: return "Unknown"
        }
    }

    private func importLatest() async {
        errorText = nil
        processing = true
        defer { processing = false }

        if !canReadPhotos {
            authStatus = await photos.requestAuth()
        }
        guard canReadPhotos else {
            errorText = "Photos permission is required."
            return
        }

        guard let asset = photos.fetchLatestImageAsset() else {
            errorText = "No images found. Try Pick Photos."
            return
        }

        guard let ui = await photos.loadUIImage(from: asset) else {
            errorText = "Failed to load latest image."
            return
        }

        do {
            let (moment, out) = try await pipeline.run(
                image: ui,
                photoLocalIdentifier: asset.localIdentifier,
                context: modelContext,
                enableGestureScoring: enableGestureScoring
            )

            draftMoment = moment
            overlayPreview = Image(uiImage: out.overlayImage)
        } catch {
            errorText = "Processing error: \(error.localizedDescription)"
        }
    }

    private func importFromPicker(_ item: PhotosPickerItem) async {
        errorText = nil
        processing = true
        defer { processing = false }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let ui = UIImage(data: data) {

                let localId = item.itemIdentifier // may be nil
                let (moment, out) = try await pipeline.run(
                    image: ui,
                    photoLocalIdentifier: localId,
                    context: modelContext,
                    enableGestureScoring: enableGestureScoring
                )

                draftMoment = moment
                overlayPreview = Image(uiImage: out.overlayImage)
            } else {
                errorText = "Could not load image from picker."
            }
        } catch {
            errorText = "Picker error: \(error.localizedDescription)"
        }
    }

    @ViewBuilder
    private func draftEditor(moment: Moment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review & Save").font(.headline)

            HStack(spacing: 12) {
                Picker("Category", selection: Binding(
                    get: { moment.sceneCategory },
                    set: { moment.sceneCategory = $0 }
                )) {
                    ForEach(SceneCategory.allCases) { c in
                        Text(c.displayName).tag(c)
                    }
                }
                .pickerStyle(.menu)

                Stepper(value: Binding(
                    get: { moment.score ?? 3 },
                    set: { moment.score = $0; moment.scoreSource = "manual" }
                ), in: 1...5) {
                    Text("Score: \(moment.score ?? 0)/5")
                }
            }

            Text("Score source: \(moment.scoreSource)")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button {
                saveDraft(moment)
            } label: {
                Label("Save Moment", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.top, 8)
    }

    private func saveDraft(_ moment: Moment) {
        modelContext.insert(moment)
        do {
            try modelContext.save()
            draftMoment = nil
            overlayPreview = nil
        } catch {
            errorText = "Failed to save: \(error.localizedDescription)"
        }
    }
}
