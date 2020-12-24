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
    
    @IBOutlet weak var bottomStack: UIStackView!
    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var midStack: UIStackView!
    var shootingEngine:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBGImage()
        if !getCityName.isEmpty{
            self.title = getCityName
            // Adding pull to refresh control
            self.scrollView.alwaysBounceVertical = true
            self.scrollView.addSubview(refreshControl)
            getTempInfo(getCityName: getCityName)
        }
        
    }
    
    func showAndHideViews(state: Bool){
        UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
            self.midStack.isHidden = state
            self.topStack.isHidden = state
            self.bottomStack.isHidden = state
        }).startAnimation()
    }
    
    
    func setupBGImage(){
        vieBG.layer.contents = UIImage(named: "Weather_image.jpg")?.cgImage
        // To update periodically every 30 seconds
        shootingEngine = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(callListDetails), userInfo: nil, repeats: true)
    }
    
    //    Mark:- Call periodic function
    @objc func callListDetails(){
        self.getTempInfo(getCityName: self.getCityName)
    }
    
    deinit {
        nullifyTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nullifyTimer()
    }
    
    func nullifyTimer() {
        shootingEngine?.invalidate()
        shootingEngine = nil
    }
    
    //    Mark:- Refersh temperature manually
    @IBAction func refreshTemp(_ sender: UIBarButtonItem) {
        getTempInfo(getCityName: getCityName)
    }
    
    // MARK: - handle Refresh action
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.beginRefreshing()
        getTempInfo(getCityName: getCityName)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            self.midStack.isHidden = UIWindow.isLandscape ? true : false
        })
    }
    
    var statusBarOrientations: UIInterfaceOrientation? {
        get {
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
                #if DEBUG
                fatalError("Could not obtain UIInterfaceOrientation from a valid windowScene")
                #else
                return nil
                #endif
            }
            return orientation
        }
    }
}

extension DetailViewController {
    // MARK: - APi call for get city details
    func getTempInfo(getCityName: String){
        self.view.activityStartAnimating(activityColor: .white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
        self.showAndHideViews(state: true)
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
                        self.showAndHideViews(state: false)
                    }
                    
                case .failure (let error):
                    // print(error.localizedDescription)
                    self.showToast(message: error.localizedDescription, seconds: 2.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { self.navigationController?.popToRootViewController(animated: true) }
                }
            }
            
        }
    }
    
    func setupImage(icon: String){
        guard  !icon.isEmpty else {
            return
        }
        if let getImageURL = URL(string:String(format:"%@%@@2x.png",pathURL.imagePath, icon)), !getImageURL.absoluteString.isEmpty{
            imgCloudy?.loadImage(at: getImageURL)
        }
    }
}
