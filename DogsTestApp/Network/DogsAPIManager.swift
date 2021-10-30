import Foundation
import UIKit

protocol APIManagerDelegate {
    func dataUpdate(data: [String])
}

class DogsAPIManager {
    
    static var shared: DogsAPIManager {
        let instance = DogsAPIManager()
        return instance
    }
    
    var delegate: APIManagerDelegate?
    
    private var imageCache = NSCache<NSString, UIImage>()
    
    func fetchBreeds() {
        
        let url = "https://dog.ceo/api/breeds/list/all"
        
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
                
                if let error = error {
                    print(error)
                }
                
                guard let data = data else { return }
                
                do {
                    
                    let breeds = try JSONDecoder().decode(Breeds.self, from: data)
                    
                    let breedsArray: [String] = {
                        
                        var tempArray = [String]()
                        
                        breeds.message.forEach { (key: String, value: [String]) in
                            tempArray.append(key)
                        }
                        
                        return tempArray
                        
                    }()
                    
                    DispatchQueue.main.async {
                        self?.delegate?.dataUpdate(data: breedsArray)
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
                
            }
            
        }.resume()
        
    }
    
    func fetchPhotosURLs(breed: String) {
        
        let url = "https://dog.ceo/api/breed/\(breed)/images"
        
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
                
                if let error = error {
                    print(error)
                }
                
                guard let data = data else { return }
                
                do {
                    
                    let photosURLs = try JSONDecoder().decode(PhotosURLs.self, from: data)
                    
                    DispatchQueue.main.async {
                        self?.delegate?.dataUpdate(data: photosURLs.message)
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
                
            }
            
        }.resume()
    }
    
    func fetchPhoto(urlString: String, complition: @escaping (UIImage) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            
            if let imageFromCache = self.imageCache.object(forKey: urlString as NSString) {
                DispatchQueue.main.async {
                    complition(imageFromCache)
                }
            } else {
                
                guard let url = URL(string: urlString) else { return }
                
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
                let dataTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                    
                    if let error = error {
                        print(error)
                    }
                    
                    guard let data = data else { return }
                    
                    guard let image = UIImage(data: data) else { return }
                    
                    DispatchQueue.main.async {
                        complition(image)
                    }
                    self?.imageCache.setObject(image, forKey: urlString as NSString)
                }
                
                dataTask.resume()
                
            }
            
        }
        
    }
    
}
