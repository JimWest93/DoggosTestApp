import UIKit

class BreedPhotosViewController: UIViewController {
    
    @IBOutlet weak var breedPhotosCollectionView: UICollectionView!
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    var breedName = String()
    
    private let cellId = "photoCell"
    private let cellsInARow = 2
    private let cellsSpacing = 2
    
    private let manager = DogsAPIManager.shared
    
    private var photosURLs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle()
        collectionSetup()
        manager.delegate = self
        manager.fetchPhotosURLs(breed: breedName)
        
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        manager.fetchPhotosURLs(breed: breedName)
    }
    
    private func collectionSetup() {
        breedPhotosCollectionView.delegate = self
        breedPhotosCollectionView.dataSource = self
        breedPhotosCollectionView.refreshControl = refreshControl
    }
    
    private func setTitle() {
        title = breedName
        title?.capitalizeFirstLetter()
    }
    
    private func configureCell(cell: PhotoCollectionViewCell, indexPath: IndexPath) {
        cell.initEmptyCell()
        let urlString = photosURLs[indexPath.row]
        manager.fetchPhoto(urlString: urlString) { image in
            cell.cellInit(image: image)
        }
    }
}

extension BreedPhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photosURLs.isEmpty {
            return 10
        }
        return photosURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoCollectionViewCell
        
        if photosURLs.isEmpty {
            photoCell.initEmptyCell()
        } else {
            configureCell(cell: photoCell, indexPath: indexPath)
        }
        return photoCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullscreenVC = storyboard?.instantiateViewController(withIdentifier: "fullscreenVC") as! FullscreenViewController
        fullscreenVC.imageURL = photosURLs[indexPath.row]
        navigationController?.pushViewController(fullscreenVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cVFrame = breedPhotosCollectionView.frame
        let cellWidth = cVFrame.width / CGFloat(cellsInARow)
        let cellHeight = cellWidth
        let totalSpacing = CGFloat((cellsInARow + 1) * cellsSpacing / cellsInARow)
        return CGSize(width: cellWidth - totalSpacing, height: cellHeight - CGFloat(cellsSpacing * 2))
    }
    
}

extension BreedPhotosViewController: APIManagerDelegate {
    func dataUpdate(data: [String]) {
        photosURLs = data
        breedPhotosCollectionView.reloadData()
        refreshControl.endRefreshing()
    }
}
