//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Chandra Rao on 15/11/17.
//  Copyright © 2017 Chandra Rao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblEUR: UILabel!
    @IBOutlet weak var lblUSD: UILabel!
    @IBOutlet weak var lblJPY: UILabel!
    
    @IBOutlet weak var txtFieldAmount: UITextField!
    
    @IBOutlet weak var btnConFromEUR: UIButton!
    @IBOutlet weak var btnConFromUSD: UIButton!
    @IBOutlet weak var btnConFromJPY: UIButton!
    
    @IBOutlet weak var btnConToEUR: UIButton!
    @IBOutlet weak var btnConToUSD: UIButton!
    @IBOutlet weak var btnConToJPY: UIButton!
    
    @IBOutlet weak var btnConvert: UIButton!
    @IBOutlet weak var lblTotalCommision: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var eur :Float = 1000.0
    var usd :Float = 0.0
    var jpy :Float = 0.0
    
    var commissionPercentage :Float = 0.7
    var totalCommissionDeducted :Float = 0.0
    var freeTransanctionsLeft :Int = 5
    
    var fromCurrency: String = "EUR"
    var toCurrency: String = "USD"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        commissionPercentage = commissionPercentage/100
        self.activityIndicator.stopAnimating()
        self.updateCurrencyUI()
        btnConFromEUR.isSelected = true
        btnConToUSD.isSelected = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - UpdateUI Methods

    func updateCurrencyUI() {
        
        lblEUR.text = "Balance EUR: \n \(eur)"
        lblUSD.text = "Balance USD: \n \(usd)"
        lblJPY.text = "Balance JPY: \n \(jpy)"
        lblTotalCommision.text = "Total Commision deducted: \(totalCommissionDeducted)"
    }
    
    // MARK: - UIButton Action Methods
    
    @IBAction func btnConvertClicked(_ sender: Any) {
        
        let n : Float = Float(txtFieldAmount.text!) ?? 0.0
        
        if checkForCurrencyBalance(currentValue: n) {
            showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.InsuffientFunds)
        } else if checkSameCurrencySelected() {
            showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.SameCurrency)
        } else if check(forBlanks: txtFieldAmount) {
            showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.EnterAmount)
        } else if n <= 0 {
            showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.EnterValidAmount)
        } else if freeTransanctionsLeft == 0 {
            showConfirmationAlert()
        } else {
            convertToDesiredCurrency()
        }
    }
    
    @IBAction func btnConvertFromCurrency(_ sender: Any) {
        
        let btnClicked : UIButton = sender as! UIButton
        
        switch btnClicked.tag {
        case 10:
            btnConFromEUR.isSelected = true
            btnConFromJPY.isSelected = false
            btnConFromUSD.isSelected = false
            fromCurrency = "EUR"
        case 11:
            btnConFromEUR.isSelected = false
            btnConFromUSD.isSelected = true
            btnConFromJPY.isSelected = false
            fromCurrency = "USD"
        case 12:
            btnConFromEUR.isSelected = false
            btnConFromUSD.isSelected = false
            btnConFromJPY.isSelected = true
            fromCurrency = "JPY"
        default:
            btnConFromEUR.isSelected = false
            btnConFromUSD.isSelected = false
            btnConFromJPY.isSelected = false
        }
    }
    
    @IBAction func btnConvertToCurrency(_ sender: Any) {
        
        let btnClicked : UIButton = sender as! UIButton
        
        switch btnClicked.tag {
        case 13:
            btnConToEUR.isSelected = true
            btnConToUSD.isSelected = false
            btnConToJPY.isSelected = false
            toCurrency = "EUR"
        case 14:
            btnConToEUR.isSelected = false
            btnConToUSD.isSelected = true
            btnConToJPY.isSelected = false
            toCurrency = "USD"
        case 15:
            btnConToEUR.isSelected = false
            btnConToUSD.isSelected = false
            btnConToJPY.isSelected = true
            toCurrency = "JPY"
        default:
            btnConToEUR.isSelected = false
            btnConToUSD.isSelected = false
            btnConToJPY.isSelected = false
        }
    }
    
    // MARK: - API Call to Convert Currency
    
    func convertToDesiredCurrency() {
        
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        let amountEntered : String = txtFieldAmount.text!
        let convert : String = "\(amountEntered)-\(fromCurrency)/\(toCurrency)/latest"
        
//        print(convert)
        
        APIHelperS.sharedInstance.callGetApiWithMethod(withMethod: convert, successHandler: { (dictData) in
//            print(dictData)
            DispatchQueue.main.async {
                //Any UI operations to be performed.
                if self.freeTransanctionsLeft > 0 {
                    self.sucessFullTransanctionWithoutCommision(convertedValue: dictData.object(forKey: Constants.AmountKey) as! String , convertedCurrency: dictData.object(forKey: Constants.CurrencyKey) as! String)
                } else {
                    self.deductCommision(convertedValue: dictData.object(forKey: Constants.AmountKey) as! String , convertedCurrency: dictData.object(forKey: Constants.CurrencyKey) as! String)
                }
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.stopAnimating()
            }
            
        }) { (strMessage) in
            self.view.isUserInteractionEnabled = true
            print(strMessage)
        }
    }
    
    // MARK: - Check For Currency Balance/ Selected Currency
    
    func checkForCurrencyBalance(currentValue value:Float) -> Bool{
        
        if btnConFromEUR.isSelected && eur > 0.0 && value <= eur {
            return false
        } else if btnConFromUSD.isSelected && usd > 0.0 && value <= usd {
            return false
        } else if btnConFromJPY.isSelected && jpy > 0.0 && value <= jpy {
            return false
        } else {
            return true
        }
    }
    
    func checkSameCurrencySelected() -> Bool {
        
        if btnConFromEUR.isSelected && btnConToEUR.isSelected {
            return true
        } else if btnConFromUSD.isSelected && btnConToUSD.isSelected {
            return true
        } else if btnConFromJPY.isSelected && btnConToJPY.isSelected {
            return true
        }
        return false
    }
    
    
    func check(forBlanks textfield: UITextField) -> Bool {
        let rawString: String? = textfield.text
        let whitespace = CharacterSet.whitespacesAndNewlines
        let trimmed: String? = rawString?.trimmingCharacters(in: whitespace)
        if (trimmed?.count ?? 0) == 0 {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - Show Alerts for App
    
    func showAlert(withTitleAndMessage title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showConfirmationAlert() {
        let alertView = UIAlertController(title: Constants.AlertTitle, message: "Free transanctions are over, now you will be charged with \(self.commissionPercentage * 100)% commission of the base currency to be converted. Press OK to proceed. ", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            self.convertToDesiredCurrency()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (alert) in
            
        })
        
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - Calculation Methods
    
    func deductCommision(convertedValue val: String , convertedCurrency: String) {
        let amt : Float = Float(txtFieldAmount.text!) ?? 0.0
        var commisionToBeDeduced : Float = 0.0
        var updateValues : Bool = false
        lblTotalCommision.isHidden = false
        
        print("Currency = \(convertedCurrency) Amount = \(val)")
        
        if btnConFromEUR.isSelected {
            
            commisionToBeDeduced = (eur * commissionPercentage)
            
            if (amt + commisionToBeDeduced) < eur {
                updateValues = true
                eur = eur - (amt + commisionToBeDeduced)
                totalCommissionDeducted = totalCommissionDeducted + commisionToBeDeduced
            } else {
                showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.InsuffientFunds)
            }
            
        } else if btnConFromUSD.isSelected {
            
            commisionToBeDeduced = (usd * commissionPercentage)
            
            if (amt + commisionToBeDeduced) < usd {
                updateValues = true
                usd = usd - (amt + commisionToBeDeduced)
                totalCommissionDeducted = totalCommissionDeducted + commisionToBeDeduced
            } else {
                showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.InsuffientFunds)
            }
        } else if btnConFromJPY.isSelected {
            
            commisionToBeDeduced = (jpy * commissionPercentage)
            
            if (amt + commisionToBeDeduced) < jpy {
                updateValues = true
                jpy = jpy - (amt + commisionToBeDeduced)
                totalCommissionDeducted = totalCommissionDeducted + commisionToBeDeduced
            } else {
                showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.InsuffientFunds)
            }
        }
        
        if updateValues {
            
            if btnConToEUR.isSelected {
                eur = eur + Float(val)!
            } else if btnConToUSD.isSelected {
                usd = usd + Float(val)!
            } else if btnConToJPY.isSelected {
                jpy = jpy + Float(val)!
            }
            self.showAlert(withTitleAndMessage: Constants.AlertTitle, message: "The amount \(amt) \(fromCurrency) is sucessfully converted to \(val) \(toCurrency). Commison fee: \(commisionToBeDeduced)")

        }
        self.updateCurrencyUI()
    }
    
    func sucessFullTransanctionWithoutCommision(convertedValue val: String , convertedCurrency: String) {
        
        let amt : Float = Float(txtFieldAmount.text!) ?? 0.0
        print("Currency = \(convertedCurrency) Amount = \(val)")
        var updateValues : Bool = false
        
        if btnConFromEUR.isSelected {
            
            if amt <= eur {
                updateValues = true
                eur = eur - amt
            } else {
                showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.InsuffientFunds)
            }
            
        } else if btnConFromUSD.isSelected {
            
            if amt <= usd {
                updateValues = true
                usd = usd - amt
            } else {
                showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.InsuffientFunds)
            }
            
        } else if btnConFromJPY.isSelected {
            
            if amt <= jpy {
                updateValues = true
                jpy = jpy - amt
            } else {
                showAlert(withTitleAndMessage: Constants.AlertTitle, message: Constants.InsuffientFunds)
            }
        }
        
        if updateValues {
            
            self.freeTransanctionsLeft = self.freeTransanctionsLeft - 1
            if btnConToEUR.isSelected {
                eur = eur + Float(val)!
            } else if btnConToUSD.isSelected {
                usd = usd + Float(val)!
            } else if btnConToJPY.isSelected {
                jpy = jpy + Float(val)!
            }
            self.showAlert(withTitleAndMessage: Constants.AlertTitle, message: "The amount \(amt) \(fromCurrency) is sucessfully converted to \(val) \(toCurrency)")
        }
        self.updateCurrencyUI()
    }
}

