//
//  DownloadImageAsyncView.swift
//  DownloadImageAsync
//
//  Created by Ibrahim on 11/10/24.
//

import SwiftUI
import Combine

class DownloaderImageLoader {
    private let url = URL(string: "https://picsum.photos/300")!
    
    func downloadImageCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError{ $0 }
            .eraseToAnyPublisher()
    }
    
    private func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              200..<300 ~= response.statusCode
        else { return nil }
        
        return image
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    
    private var cancellable = Set<AnyCancellable>()
    
    private let loader: DownloaderImageLoader
    
    init(loader: DownloaderImageLoader = DownloaderImageLoader()) {
        self.loader = loader
    }
    
    @MainActor
    func fetch() {
        loader.downloadImageCombine()
            .sink { error in
                print(error)
            } receiveValue: { [weak self] image in
                self? .image = image
            }
            .store(in: &cancellable)

    }
}

struct DownloadImageAsyncView: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
        }.onAppear {
            viewModel.fetch()
        }
    }
}

#Preview {
    DownloadImageAsyncView()
}
