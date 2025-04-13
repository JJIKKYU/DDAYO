import SwiftUI

public struct ZoomableImageView: UIViewRepresentable {
    public let image: UIImage

    public init(image: UIImage) {
        self.image = image
    }

    public func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView

        return scrollView
    }

    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.imageView?.image = image
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: UIImageView?

        override init() {}

        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
    }
}
