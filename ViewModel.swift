import SwiftUI


struct CurrencyType: Codable {
    let data: CurrencyRates
}

struct CurrencyRates: Codable {
    let EUR, USD, CAD, JPY, INR, AUD, GBP, CHF: Double
}

// MainViewModel

class MainViewModel: ObservableObject {
    @Published var currencyData: CurrencyType?
    @Published var errorMessage: String = ""
    private let apiKey = "fca_live_7M1YPjRKNM0z06hR4LxaTGm939syzYGFNoiYQbcE"
    
    func fetchCurrencyData() {
        guard let url = URL(string: "https://api.freecurrencyapi.com/v1/latest?apikey=\(apiKey)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid server response"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data returned"
                }
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(CurrencyType.self, from: data)
                DispatchQueue.main.async {
                    self.currencyData = decodedData
                    print(decodedData)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func CalculateExchangeValue(amount: Double, from: String, to: String, rates: CurrencyRates) -> Double? {
        // for INR to JPY is 1USD in INR is 80 & 1 USD in JPY 150
        // 100
        let fromRate = getRateForCurrency(from, rates: rates) // 84.34
        print(fromRate)
        let toRate = getRateForCurrency(to, rates: rates) // 154.58
        
        let multiplier = toRate / fromRate * amount
        guard fromRate > 0, toRate > 0 else { return nil }
        let finalMultiplier = multiplier * amount
        return finalMultiplier
    }
    
    func calculateExchangeValueForCurrency(
        FromAmount: Double?,
        ToAmount: Double?,
        from: String,
        to: String,
        rates: CurrencyRates
    ) -> (fromResult: Double, toResult: Double)? {
        let fromRate = getRateForCurrency(from, rates: rates)
        let toRate = getRateForCurrency(to, rates: rates)
        
        guard fromRate > 0, toRate > 0 else {
            print("Invalid rates provided")
            return nil
        }
        
        if let fromAmount = FromAmount {
            let toAmount = ((fromAmount / fromRate) * toRate)
            let decimals = getDecimalPlaces(fromAmount)
            return (fromAmount, toAmount.rounded(toPlaces: decimals))
        } else if let toAmount = ToAmount {
            let fromAmount = (toAmount / toRate) * fromRate
            let decimals = getDecimalPlaces(toAmount)
            return (fromAmount.rounded(toPlaces: decimals), toAmount)
        }
        
        print("Both amounts cannot be nil")
        return nil
    }
    func getDecimalPlaces(_ value: Double) -> Int {
        let stringValue = String(value)
        if let index = stringValue.firstIndex(of: ".") {
            return stringValue.distance(from: index, to: stringValue.endIndex) - 1
        }
        return 0
    }
    
    private func getRateForCurrency(_ currency: String, rates: CurrencyRates) -> Double {
        switch currency {
        case "INR": return rates.INR
        case "JPY": return rates.JPY
        case "USD": return rates.USD
        case "AUD": return rates.AUD
        default: return 0
        }
    }
}


extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
