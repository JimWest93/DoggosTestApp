import UIKit

class BreedsListViewController: UIViewController {

    @IBOutlet weak var breedsTableView: UITableView!
    
    private var activityIndicatorView = UIActivityIndicatorView()
    private var tableHeader = DoggoTableHeader()

    private let cellId = "breedCell"
    
    private var breeds: [String] = []

    private let manager = DogsAPIManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBreedsTable()
        manager.delegate = self
        manager.fetchBreeds()
    }

    private func setupBreedsTable() {
        
        breedsTableView.delegate = self
        breedsTableView.dataSource = self
        
        tableHeader = DoggoTableHeader(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 4))
        tableHeader.imageView.image = UIImage(named: "doggo")
        activityIndicatorView = UIActivityIndicatorView(frame: breedsTableView.frame)
        
        breedsTableView.backgroundView = activityIndicatorView
        activityIndicatorView.startAnimating()
        
    }

}

extension BreedsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let breedCell = tableView.dequeueReusableCell(withIdentifier: cellId) as! BreedTableViewCell
        
        let breed = breeds[indexPath.row]
        breedCell.cellInit(breed: breed)

        return breedCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let breedPhotosVC = storyboard?.instantiateViewController(withIdentifier: "breedPhotosVC") as! BreedPhotosViewController
        breedPhotosVC.breedName = breeds[indexPath.row]
        navigationController?.pushViewController(breedPhotosVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension BreedsListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let header = breedsTableView.tableHeaderView as? DoggoTableHeader else { return }
        header.scrollViewDidScroll(scrollView: breedsTableView)
    }
    
}

extension BreedsListViewController: APIManagerDelegate {
    func dataUpdate(data: [String]) {
        breeds = data
        activityIndicatorView.stopAnimating()
        breedsTableView.tableHeaderView = tableHeader
        breedsTableView.reloadData()
    }
}
