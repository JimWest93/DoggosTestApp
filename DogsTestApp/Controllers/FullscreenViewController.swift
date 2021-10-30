import UIKit

class FullscreenViewController: UIViewController {
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var imageURL = String()
    
    private var isPresented = false
    
    private let manager = DogsAPIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImage()
        setupViews()
        setupLongGestureRecognizer()
    }
    
    private func setupImage() {
        manager.fetchPhoto(urlString: imageURL) { [weak self] image in
            self?.photoImageView.image = image
        }
    }
    
    private func setupViews() {
        imageScrollView.delegate = self
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.maximumZoomScale = 4.0
    }
    
    
    private func setupLongGestureRecognizer() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        longPressGestureRecognizer.delaysTouchesBegan = true
        longPressGestureRecognizer.delegate = self
        self.imageScrollView.addGestureRecognizer(longPressGestureRecognizer)
        
    }
    
    private func ACSetup() -> UIActivityViewController {
        var imageForShare = [Any]()
        if let image = photoImageView.image?.withRenderingMode(.alwaysOriginal) {
            imageForShare = [image] as [Any]
        }
        let activityController = UIActivityViewController(activityItems: imageForShare, applicationActivities: [])
        return activityController
    }
    
    @objc private func longPress(sender: UILongPressGestureRecognizer) {
        if !isPresented {
            let ac = ACSetup()
            self.present(ac, animated: true, completion: nil)
            isPresented = true
        } else if sender.state == .cancelled {
            isPresented = false
        }
    }
}

extension FullscreenViewController: UIGestureRecognizerDelegate {
    
}

extension FullscreenViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        imageScrollView.zoomScale = 1.0
    }
    
}
