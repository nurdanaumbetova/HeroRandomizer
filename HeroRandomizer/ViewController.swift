import UIKit

struct Hero: Decodable {
    let name: String
    let biography: Biography
    let images: HeroImage
    let powerstats: Powerstats

    struct Biography: Decodable {
        let fullName: String
       // let alterEgos: String
        let placeOfBirth: String
    }
    
    struct Powerstats: Decodable{
        let intelligence: Int
        let strength: Int
        let speed: Int
        let durability: Int
        let power: Int
        let combat: Int
    }

    struct HeroImage: Decodable {
        let sm: String
    }
}

class ViewController: UIViewController {

    @IBOutlet private weak var heroImage: UIImageView!
    @IBOutlet private weak var heroTitle: UILabel!
    @IBOutlet private weak var heroDescription: UILabel!
    @IBOutlet private weak var heroPowerstatsLabel: UILabel!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func heroRollDidTap(_ sender: UIButton) {
        let randomId = Int.random(in: 1...563)
        fetchHero(by: randomId)
    }

    private func fetchHero(by id: Int) {
        let urlString = "https://akabab.github.io/superhero-api/api/id/\(id).json"
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url)

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard self.handleErrorIfNeeded(error: error) == false else {
                return
            }

            guard let data else { return }
            self.handleHeroData(data: data)
        }.resume()
    }

    private func handleHeroData(data: Data) {
        do {
            let hero = try JSONDecoder().decode(Hero.self, from: data)
            let heroImage = self.getImageFromUrl(string: hero.images.sm)

            DispatchQueue.main.async {
                self.heroTitle.text = hero.name
                let biography = """
                full Name: \(hero.biography.fullName)
                Place of birth: \(hero.biography.placeOfBirth)
                """
                self.heroDescription.text = biography
                
                self.heroImage.image = heroImage
                
                let powerstats = """
                Intelligence: \(hero.powerstats.intelligence)
                Strength: \(hero.powerstats.strength)
                Speed: \(hero.powerstats.speed)
                Durability: \(hero.powerstats.durability)
                Power: \(hero.powerstats.power)
                Combat: \(hero.powerstats.combat)
                """
                let paragraphStyle = NSMutableParagraphStyle()
                            paragraphStyle.lineSpacing = 8
                self.heroPowerstatsLabel.text = powerstats
            }
        } catch {
            DispatchQueue.main.async {
                self.heroTitle.text = error.localizedDescription + "\nReRoll again!"
                self.heroDescription.text = ""
                self.heroImage.image = nil
                self.heroPowerstatsLabel.text = ""
            }
        }
    }

    private func getImageFromUrl(string: String) -> UIImage? {
        guard
            let heroImageURL = URL(string: string),
            let imageData = try? Data(contentsOf: heroImageURL)
        else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    @IBAction func changehero(_ sender: UIButton) {
            UIView.transition(with: heroImage,
                              duration: 0.5,
                              options: .transitionFlipFromTop,
                              animations: {
                                  self.heroImage.image = UIImage(named: "new_image")
                              },
                              completion: nil)
        }

    private func handleErrorIfNeeded(error: Error?) -> Bool {
        guard let error else {
            return false
        }
        print(error.localizedDescription)
        return true
    }
}
