//
//  CountryListViewController.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 21/12/20.
//

import UIKit



class CountryListCell: UITableViewCell, Reusable {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
     
    var onReuse: () -> Void = {}
    func  configureCell(cList: CList){
        textLabel?.text = cList.cName
        detailTextLabel?.text =  String(format:"%0.f°C",cList.temp) //(FormatDisplay.convertTemp(temp: cList.temp) // fahrenheit
        guard !cList.icon.isEmpty else { return }
        if let getImageURL = URL(string:String(format: "%@%@@2x.png",pathURL.imagePath, cList.icon)), !getImageURL.absoluteString.isEmpty{
            imageView?.loadImage(at: getImageURL)
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        imageView?.image = nil
      }
    
    
}

class CountryListViewController: UITableViewController {
    
   /* var items: [CountryList] = []{
        didSet{
            self.navigationItem.rightBarButtonItem?.isEnabled = !items.isEmpty
        }
    } */
    var getselectedItems: [CList] =  []
    let toDetailVCSegue = "openDetail"
    var cityList: [CountryList] = []
    
    lazy var cityRefreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:
                         #selector(handleRefresh(_:)),
                                     for: .valueChanged)
        refreshControl.tintColor = .white
        refreshControl.backgroundColor = .purple
        return refreshControl
        }()
    
    lazy var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 75
        cityList = CountryList.getAllCity()
        setUp()
        tableView.register(cellType: CountryListCell.self)
        tableView.addSubview(cityRefreshControl)
        /*
        self.getAllList(configure: { [weak self] countryList in
            guard let this = self else { return}
            this.items = countryList
        }) */
        
        
        
    }
    
    // MARK: - handle Refresh action
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.cityRefreshControl.beginRefreshing()
        self.getselectedItems.removeAll()
        setUp()
        }
    
    func setUp(){
        
        for getCitylist in [2147714,4163971, 2174003 ]{
            updateCityList(geCityID: getCitylist)
        }
       
//        getselectedItems = [
//            CList(cName: "Sydney", icon:"04n", cID: 2147714, temp: 19.76),
//            CList(cName: "Melbourne",icon:"04n", cID: 4163971,temp: 15.41),
//            CList(cName: "Brisbane",icon:"11n", cID: 2174003, temp: 25.29)
//        ]
    }
    
    // MARK: - APi call for get city details
    func updateCityList(geCityID: Int){
        self.view.activityStartAnimating(activityColor: .white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        ServiceLayer.request(router: Router.getCityTempInfo, ciyIDParameters: ["id": String(geCityID)]) { (result: Result<CityDetailsList, Error>) in
            DispatchQueue.main.async {
                self.view.activityStopAnimating()
                let updateString = "Last Updated at " + self.dateFormatter.string(from: Date())
                   self.cityRefreshControl.attributedTitle =  NSAttributedString(string: updateString,
                                                                             attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
                   if self.cityRefreshControl.isRefreshing {
                     self.cityRefreshControl.endRefreshing()
                   }
                switch result {
                case .success (let currentCity):
                        let getCityName = CList(cName: currentCity.name, icon:currentCity.weather.first?.icon ?? "", cID: currentCity.id, temp: currentCity.main.temp)
                        self.getselectedItems.append(getCityName)
                        self.tableView.refresh()
                    
                case .failure (let error):
                   // print(error.localizedDescription)
                    self.showToast(message: error.localizedDescription, seconds: 2.0)
                }
            }

        }
    }
   

    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return getselectedItems.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let animation = AnimationFactory.makeMoveUpWithBounce(rowHeight: cell.frame.height, duration: 1.0, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
        }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CountryListCell {
        let countryCell = tableView.dequeueReusableCell(for: indexPath) as CountryListCell
        // Configure the cell...
        let item = getselectedItems[indexPath.row]
        countryCell.configureCell(cList: item)
         return countryCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:  true)
        self.performSegue(withIdentifier: toDetailVCSegue, sender: indexPath)
    }
    
    
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        
        if segue.identifier == toDetailVCSegue{
            guard  let getDesinationVC = segue.destination as? DetailViewController else { return
            }
            if let selectedIndex = sender as? IndexPath{
                getDesinationVC.getCityName = getselectedItems[selectedIndex.row].cName
            }
            
            return
        }
        guard  let getDesinationVC = segue.destination as? SearchCityViewController else { return
        }
        getDesinationVC.cityList = cityList
        getDesinationVC.callback = { [self]
            (citySelectedList) in
            if let getCityID = citySelectedList?.id, let getCityName = citySelectedList?.name {
                let getFoundedItem = getselectedItems.first(where: {$0.cID == getCityID})
                if getFoundedItem != nil{
                    // city is already founded in list
                    self.showToast(message: String(format: "%@ city already added in the list", getCityName), seconds: 2.0)
                    return
                }
                updateCityList(geCityID: getCityID)
            }
        }
     }
      
    
}
