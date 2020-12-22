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
        detailTextLabel?.text = convertTemp(temp: cList.temp, from: .kelvin, to: .fahrenheit)
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
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setUp(){
        tableView.rowHeight = 75
        getselectedItems = [
            CList(cName: "Sydney", icon:"04n", cID: 2147714, temp: 19.76),
            CList(cName: "Melbourne",icon:"04n", cID: 4163971,temp: 15.41),
            CList(cName: "Brisbane",icon:"11n", cID: 2174003, temp: 25.29)
        ]
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
        getDesinationVC.callback = {
            (citySelectedList) in
            print(citySelectedList?.name)
        }
     }
      
    
}
