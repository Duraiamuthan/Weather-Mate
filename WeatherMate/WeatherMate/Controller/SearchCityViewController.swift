//
//  SearchCityViewController.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 21/12/20.
//

import UIKit

class SearchListCell: UITableViewCell, Reusable {
}



class SearchCityViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchFooter: SearchFooter!
    @IBOutlet var searchFooterBottomConstraint: NSLayoutConstraint!
    
    var cityList: [CountryList] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCandies: [CountryList] = []
    
    var callback : ((CountryList?) -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()
        cityList = CountryList.getAllCity()
        // Do any additional setup after loading the view.
        // 1
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        // 3
        searchController.searchBar.placeholder = "Search City"
        // 4
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true

        // 5
        definesPresentationContext = true
        
        searchController.searchBar.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil, queue: .main) { (notification) in
                                        self.handleKeyboard(notification: notification) }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                       object: nil, queue: .main) { (notification) in
                                        self.handleKeyboard(notification: notification) }
        
        tableView.register(cellType: SearchListCell.self)

    }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    func filterContentForSearchText(_ searchText: String) {
      filteredCandies = cityList.filter { (cityList: CountryList) -> Bool in
        if !isSearchBarEmpty {
          return cityList.name.lowercased().contains(searchText.lowercased())
        }
        return false
      }
      tableView.refresh()
    }
    
    func handleKeyboard(notification: Notification) {
      // 1
      guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
        searchFooterBottomConstraint.constant = 0
        view.layoutIfNeeded()
        return
      }
      
      guard
        let info = notification.userInfo,
        let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
          return
      }
      
      // 2
      let keyboardHeight = keyboardFrame.cgRectValue.size.height
      UIView.animate(withDuration: 0.1, animations: { () -> Void in
        self.searchFooterBottomConstraint.constant = keyboardHeight
        self.view.layoutIfNeeded()
      })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchCityViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      searchFooter.setIsFilteringToShow(filteredItemCount:
        filteredCandies.count, of: cityList.count)
      return filteredCandies.count
    }
    
    searchFooter.setNotFiltering()
    return cityList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(for: indexPath) as SearchListCell
    let getCity = isFiltering ? filteredCandies[indexPath.row] : cityList[indexPath.row]
    cell.textLabel?.text = getCity.name
     return cell
  }
}

extension SearchCityViewController: UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}

extension SearchCityViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}
