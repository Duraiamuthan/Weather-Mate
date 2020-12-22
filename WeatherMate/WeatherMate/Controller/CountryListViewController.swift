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
        detailTextLabel?.text = convertTemp(temp: cList.temp, from: .kelvin, to: .celsius) // fahrenheit
        guard !cList.icon.isEmpty else { return }
        if let getImageURL = URL(string:String(format: "http://openweathermap.org/img/wn/%@@2x.png", cList.icon)), !getImageURL.absoluteString.isEmpty{
            imageView?.loadImage(at: getImageURL)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        imageView?.image = nil
      }
    
    func convertTemp(temp: Double, from inputTempType: UnitTemperature, to outputTempType: UnitTemperature) -> String {
        let mf = MeasurementFormatter()
        mf.numberFormatter.maximumFractionDigits = 0
        mf.unitOptions = .providedUnit
        let input = Measurement(value: temp, unit: inputTempType)
        let output = input.converted(to: outputTempType)
        return mf.string(from: output)
      }
}

class CountryListViewController: UITableViewController {
    
   /* var items: [CountryList] = []{
        didSet{
            self.navigationItem.rightBarButtonItem?.isEnabled = !items.isEmpty
        }
    } */
    var getselectedItems: [CList] =  []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        tableView.register(cellType: CountryListCell.self)
        
        /*
        self.getAllList(configure: { [weak self] countryList in
            guard let this = self else { return}
            this.items = countryList
        }) */
        
        
        
    }
    
    func setUp(){
        tableView.rowHeight = 75
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
    
    
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        guard  let getDesinationVC = segue.destination as? SearchCityViewController else { return
        }
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
