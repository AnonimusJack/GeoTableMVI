//
//  GTStatePresenterViewController.swift
//  GeoTableMVI
//
//  Created by Jacob on 17/01/2021.
//  Copyright © 2021 JFTech. All rights reserved.
//

import UIKit
import Network

class GTStatePresenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GTStateChangesDelegate
{
    private let countryArrayUtil = GTCountryArrayUtilities()
    @IBOutlet weak var SortByNativeNameButton: UIButton!
    @IBOutlet weak var CountriesTable: UITableView!
    @IBOutlet weak var SortByAreaButton: UIButton!
    @IBOutlet weak var SortByNameButton: UIButton!
    private let networkMonitor = NWPathMonitor()
    private let loadingViewTag: Int = 9999
    private var currentState: GTState?
    {
        didSet
        {
            if currentState != nil
            {
                currentState!.OnStateLoadedInDelegate()
            }
        }
    }

    override func loadView()
    {
        super.loadView()
        setNetworkStatusHandler()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CountriesTable.register(UINib(nibName: "GeoTableSelectedCountryHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "GeoTableSelectedCountryHeader")
        CountriesTable.delegate = self
        CountriesTable.dataSource = self
        networkMonitor.start(queue: DispatchQueue(label: "geo_table_network_monitor"))
    }
    
    func UpdateChanges()
    {
        switch currentState?.StateType
        {
            case .AllCountriesState:
                handleAllCountriesState()
                break
            case .SelectedCountryState:
                CountriesTable.reloadData()
                break
            case .ErrorState:
                let error = (currentState as! GTErrorState).Error
                handleErrorStateFor(error)
                break
            default:
                break
        }
    }
    
    func ChangeState(_ newState: GTState)
    {
        if newState is GTErrorState
        {
            self.currentState = newState
        }
        else
        {
            if networkMonitor.currentPath.status == .satisfied
            {
                self.currentState = newState
            }
            else
            {
                self.currentState = GTErrorState(delegate: self, error: .GTNoInternetConnectionAvalible)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if currentState != nil && currentState!.StateType == .SelectedCountryState
        {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "GeoTableSelectedCountryHeader") as! GeoTableSelectedCountryHeader
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OnBackToMainHeaderButtonTouch(recognizer:))))
            return header
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch currentState?.StateType
        {
            case .AllCountriesState:
                return (currentState as! GTAllCountriesState).CountriesData.count
            case .SelectedCountryState:
                return (currentState as! GTCountryState).BorderingCountries.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if currentState != nil && (currentState!.StateType == .AllCountriesState || currentState!.StateType == .SelectedCountryState)
        {
            let row = indexPath.row
            let country = (currentState!.StateType == .AllCountriesState) ? (currentState as! GTAllCountriesState).CountriesData[row] : (currentState as! GTCountryState).BorderingCountries[row]
            let countryCell = tableView.dequeueReusableCell(withIdentifier: "GeoTableCountryCell") as! GeoTableCountryCell
            countryCell.AssociatedCountry = country
            countryCell.CountryNameLable.text = country.Name
            countryCell.CountryNativeNameLable.text = country.NativeName
            countryCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(OnCountryCellTouch(recognizer:))))
            return countryCell
        }
        return UITableViewCell()
    }
    
    
    @IBAction func OnSortButtonTouch(_ sender: UIButton)
    {
        var buttonText = sender.titleLabel!.text!
        let lastButtonTitleChar: Character = buttonText.last!
        //clear button text
        buttonText = (lastButtonTitleChar.isSymbol) ? String(buttonText[..<buttonText.index(buttonText.endIndex, offsetBy: -2)]) : buttonText
        let buttonSortingProperty: GTCountry.Property = GTCountry.Property(rawValue: buttonText.replacingOccurrences(of: " ", with: ""))!
        //If not Down arrow it's Ascending
        let ascending: Bool = lastButtonTitleChar != "\u{21D1}"
        //Sort the data
        sortCountriesBy(buttonSortingProperty, ascending)
        //Set new Button text, mayne color in the future
        sender.setTitle(buttonText + (ascending ? " \u{21D1}" : " \u{21D3}" ), for: .normal)
        //Update things
        CountriesTable.reloadData()
    }
    
    @objc func OnCountryCellTouch(recognizer: UITapGestureRecognizer)
    {
        let cell = recognizer.view as! GeoTableCountryCell
        self.ChangeState(GTCountryState(delegate: self, selectedCountry: cell.AssociatedCountry!))
    }
    
    @objc func OnBackToMainHeaderButtonTouch(recognizer: UITapGestureRecognizer)
    {
        self.ChangeState(GTAllCountriesState(delegate: self))
    }
    
    
    
    
    private func handleAllCountriesState()
    {
        let state = currentState as! GTAllCountriesState
        var loadingView: UIActivityIndicatorView? = nil
        if state.IsLoading
        {
            loadingView = UIActivityIndicatorView(style: .large)
            loadingView!.tag = loadingViewTag
            CountriesTable.addSubview(loadingView!)
            loadingView!.center = CGPoint(x: CountriesTable.center.x, y: CountriesTable.center.y)
            loadingView!.startAnimating()
        }
        else
        {
            CountriesTable.viewWithTag(loadingViewTag)?.removeFromSuperview()
            CountriesTable.reloadData()
        }
    }
    
    private func handleErrorStateFor(_ error: GTError)
    {
        switch error
        {
            case .GTNoInternetConnectionAvalible:
                showAlertViewForError(withTitle: "No Network Connection Detected!", andMessage: "Please check your phone's network settings, and make sure you're connected to WiFi or that you have Mobile reception. \nPress Cancel to reaload the app.")
                break
            case .GTServerError, .GTServerDownError:
                showAlertViewForError(withTitle: "The Remote Server Issued an Error", andMessage: "To try again please press Cancel. \nOr exit the app and try again later.")
                break
            default:
                showAlertViewForError(withTitle: "Error!", andMessage: "Some error has occured, please try reloading the page by pressing Cancel.")
                break
        }
    }
    
    private func showAlertViewForError(withTitle title: String, andMessage message: String, andAcceptHandler handler: ((UIAlertAction) -> Void)? = nil)
    {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if handler != nil
        {
            errorAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: handler))
        }
        errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: onErrorAlertCancel(_:)))
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    private func onErrorAlertCancel(_ action: UIAlertAction)
    {
        self.ChangeState(GTAllCountriesState(delegate: self))
    }
    
    private func setNetworkStatusHandler()
    {
        self.networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status != .satisfied
                {
                    self.ChangeState(GTErrorState(delegate: self, error: .GTNoInternetConnectionAvalible))
                }
                else
                {
                    self.ChangeState(GTAllCountriesState(delegate: self))
                }
            }
        }
    }
    
    private func sortCountriesBy(_ property: GTCountry.Property, _ ascending: Bool)
    {
        switch currentState?.StateType
        {
            case .AllCountriesState:
                let state = currentState as! GTAllCountriesState
                state.CountriesData = countryArrayUtil.SortCountries(with: property, by: ascending)
                break
            case .SelectedCountryState:
                let state = currentState as! GTCountryState
                state.BorderingCountries = countryArrayUtil.SortCountries(with: property, by: ascending, selectedCountry: state.SelectedCountry)
                break
            default:
                break
        }
    }
}
