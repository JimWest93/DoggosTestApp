import UIKit

class BreedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var breedLabel: UILabel!
    
    func cellInit(breed: String) {
        
        breedLabel.text = breed
        breedLabel.text?.capitalizeFirstLetter()
        
    }
}
