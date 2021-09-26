

import UIKit

protocol MainTabBatControllerDelegate: AnyObject {
    func minimazedTrackDetailController()
    func maximazedTrackDetailController(viewModel: SearchViewModel.Cell?)
}

class MainTabBarController: UITabBarController {
    
    var minimazedTopAnchorConstraint: NSLayoutConstraint!
    var maximazedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstrains: NSLayoutConstraint!
    
    var trackDetailView: TrackDetailView  = TrackDetailView.loadFromNib()
    
    let searchVC: SearchViewController = SearchViewController.LoadFromStorybord()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrackDetailView()
        searchVC.tabBarDelegate = self
        
        viewControllers = [
            generateVC(rootVC: searchVC, image: "magnifyingglass", title: "Search"),
        ]
    }
    
    private func generateVC(rootVC: UIViewController, image: String, title: String) -> UIViewController {
        let navVC = UINavigationController(rootViewController: rootVC)
        navVC.tabBarItem.image = UIImage(systemName: image)
        navVC.tabBarItem.title = title
        rootVC.navigationItem.title = title
        navVC.navigationBar.prefersLargeTitles = true
        return navVC
    }
    
    
    
    private func setupTrackDetailView() {
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchVC
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        // use autolayuot
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        maximazedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimazedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstrains = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstrains.isActive = true
        //        trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trackDetailView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
}

extension MainTabBarController: MainTabBatControllerDelegate {
    func maximazedTrackDetailController(viewModel: SearchViewModel.Cell?) {
        minimazedTopAnchorConstraint.isActive = false
        maximazedTopAnchorConstraint.isActive = true
        maximazedTopAnchorConstraint.constant = 0
        bottomAnchorConstrains.constant = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.layoutIfNeeded()
                        self.tabBar.alpha = 0
                        self.trackDetailView.miniTrackView.alpha = 0
                        self.trackDetailView.maximazedStackView.alpha = 1
                       },
                       completion: nil)
        
        guard let viewModel = viewModel else {return}
        self.trackDetailView.set(viewModel: viewModel)
    }
    
    func minimazedTrackDetailController() {
        
        maximazedTopAnchorConstraint.isActive = false
        bottomAnchorConstrains.constant = view.frame.height
        minimazedTopAnchorConstraint.isActive = true
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.layoutIfNeeded()
                        self.tabBar.alpha = 1
                        self.trackDetailView.miniTrackView.alpha = 1
                        self.trackDetailView.maximazedStackView.alpha = 0
                       },
                       completion: nil)
    }
}
