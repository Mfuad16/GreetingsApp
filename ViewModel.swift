import Foundation


struct CurrencyType: Codable {
    let data: CurrencyRates
}

struct CurrencyRates: Codable {
    let EUR, USD, CAD, JPY, INR, AUD, GBP, CHF: Double
}


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
        }.resume() // Don't forget to call resume()!
    }
    
    func CalculateExchangeValue(amount: Double, from: String, to: String, rates: CurrencyRates) -> Double? {
         
               let fromRate = getRateForCurrency(from, rates: rates)
               let toRate = getRateForCurrency(to, rates: rates)
       
               guard fromRate > 0, toRate > 0 else { return nil }
       
               // Convert through USD as base currency
               let amountInUSD = amount / fromRate
               print(amountInUSD * toRate)
               return amountInUSD * toRate
    }
    
 
    private func getRateForCurrency(_ currency: String, rates: CurrencyRates) -> Double {
        switch currency {
        case "INR":
            return rates.INR
        case "JPY":
            return rates.JPY
        case "USD":
            return rates.USD
        case "AUD":
            return rates.AUD
            
        default:
            return 0
        }
    }
    
}
