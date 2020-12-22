//
//  DetailViewController.swift
//  WeatherMate
//
//  Created by Duraiamuthan Harikrishnan on 22/12/20.
//

import UIKit

class DetailViewController: UIViewController {
    
    var getCityName = ""
    lazy var refreshControl: UIRefreshControl = {
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

  
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var vieBG: UIView!
    @IBOutlet weak var imgCloudy: UIImageView!
    @IBOutlet weak var lblCast: UILabel!
    @IBOutlet weak var lblMinTemp: UILabel!
    @IBOutlet weak var lblMaxTemp: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblHuminidy: UILabel!
    @IBOutlet weak var lblPressure: UILabel!
    @IBOutlet weak var lblWindSpeed: UILabel!
    
    var oneShot : DispatchSourceTimer!
    var shootingEngine:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBGImage()
        if !getCityName.isEmpty{
            self.title = getCityName
            self.scrollView.alwaysBounceVertical = true
            self.scrollView.addSubview(refreshControl)
            getTempInfo(getCityName: getCityName)
        }
        
    }
    
    func setupBGImage(){
        vieBG.layer.contents = UIImage(named: "Weather_image.jpg")?.cgImage
        
        shootingEngine = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(callListDetails), userInfo: nil, repeats: true)
 
    }
    
    @objc func callListDetails(){
        self.getTempInfo(getCityName: self.getCityName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
        shootingEngine?.invalidate()
        shootingEngine = nil
    }
    
    @IBAction func refreshTemp(_ sender: UIBarButtonItem) {
        getTempInfo(getCityName: getCityName)
    }
    
    // MARK: - APi call for get city details
    func getTempInfo(getCityName: String){
        self.view.activityStartAnimating(activityColor: .white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        ServiceLayer.request(router: Router.getCityInfo, ciyIDParameters: ["q": getCityName]) { (result: Result<TempInfo, Error>) in
            DispatchQueue.main.async {
                self.view.activityStopAnimating()
                let updateString = "Last Updated at " + self.dateFormatter.string(from: Date())
                   self.refreshControl.attributedTitle =  NSAttributedString(string: updateString,
                                                                             attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
                   if self.refreshControl.isRefreshing {
                     self.refreshControl.endRefreshing()
                   }
                switch result {
                case .success (let currentCityDetails):
                  //  print(currentCityDetails)
                    if let getList = currentCityDetails.list.first{
                      
                        if let getWather = getList.weather.first{
                            self.lblCast.text =  getWather.weatherDescription
                            self.setupImage(icon: getWather.icon )
                        }
                         
                    
                     self.lblMinTemp.text = String(format:"Min: %@",FormatDisplay.convertTemp(temp: getList.main.tempMin))
                     self.lblMaxTemp.text = String(format:"Max: %@",FormatDisplay.convertTemp(temp: getList.main.tempMax))
                     self.lblTemp.text = FormatDisplay.convertTemp(temp: getList.main.temp )
                    
                        self.lblHuminidy.text = String(format:"%d%",getList.main.humidity)
                        self.lblPressure.text = String(format:"%dinHg",getList.main.pressure)
                        self.lblWindSpeed.text = FormatDisplay.convertTemp(temp: getList.wind.speed )
                    }
                  
                case .failure (let error):
                   // print(error.localizedDescription)
                    self.showToast(message: error.localizedDescription, seconds: 2.0)
                }
            }

        }
    }
    
     
    
    func setupImage(icon: String){
        guard  !icon.isEmpty else {
            return
        }
    if let getImageURL = URL(string:String(format: "http://openweathermap.org/img/wn/%@@2x.png", icon)), !getImageURL.absoluteString.isEmpty{
        imgCloudy?.loadImage(at: getImageURL)
    }
    }
    
    // MARK: - handle Refresh action
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.beginRefreshing()
         getTempInfo(getCityName: getCityName)
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
