import UIKit

protocol SearchDisplayLogic: AnyObject {
  func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

class SearchViewController: UIViewController, SearchDisplayLogic {

  var interactor: SearchBusinessLogic?
  var router: (NSObjectProtocol & SearchRoutingLogic)?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchViewModel = SearchViewModel.init(cell: [])
    private var timer: Timer?
    
    private lazy var footerView = FooterView()
    weak var tabBarDelegate: MainTabBatControllerDelegate?
      
  // MARK: Setup
  
  private func setup() {
    let viewController        = self
    let interactor            = SearchInteractor()
    let presenter             = SearchPresenter()
    let router                = SearchRouter()
    viewController.interactor = interactor
    viewController.router     = router
    interactor.presenter      = presenter
    presenter.viewController  = viewController
    router.viewController     = viewController
  }
  
  // MARK: Routing
  

  
  // MARK: View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupTableView()
    setupSearchBar()
    tableView.delegate = self
    tableView.dataSource = self
  }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        let nib = UINib(nibName: String(describing: TrackCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: TrackCell.self))
        tableView.tableFooterView = footerView
    }
  
  func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
    switch viewModel {
    case .displayTracks(let searchViewModel):
        self.searchViewModel = searchViewModel
        print("viewController .displayTracks")
        tableView.reloadData()
        footerView.hideLoader()
    case .displayFooterView:
        footerView.showLoader()
    }
  }
  
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.cell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackCell.self), for: indexPath)
        guard let trackCell = cell as? TrackCell else {return cell}
        let cellViewModel = searchViewModel.cell[indexPath.row]
        trackCell.trackImageView.backgroundColor = .red
        trackCell.set(viewModel: cellViewModel)
        return trackCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lable = UILabel()
        lable.text = "Пожалуйста, введите поисковый запрос"
        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return lable
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = searchViewModel.cell[indexPath.row]
        self.tabBarDelegate?.maximazedTrackDetailController(viewModel: cellViewModel)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchViewModel.cell.count > 0 ? 0 : 250
    }
}


// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.interactor?.makeRequest(request: Search.Model.Request.RequestType.getTracks(searchTerm: searchText))
        })
    }
}

// MARK: - protocol TrackMovingDelegate

extension SearchViewController: TrackMovingDelegate {
    
    private func getTrack(isForwardTrack: Bool) -> SearchViewModel.Cell? {
        guard let indexPath = tableView.indexPathForSelectedRow else {return nil}
        tableView.deselectRow(at: indexPath, animated: true)
        var nextIndexPath: IndexPath!
        if isForwardTrack {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row == searchViewModel.cell.count {
                nextIndexPath.row = 0
            }
        }else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath.row == -1 {
                nextIndexPath.row = searchViewModel.cell.count - 1
            }
        }
        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        let cellViewModel = searchViewModel.cell[nextIndexPath.row]
        return cellViewModel
    }
    
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: false)
    }
    
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: true)
    }
    
    
}
