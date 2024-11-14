import SwiftUI

struct ApiSandBox: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var amount: String = "1"
    @State private var selectedFromCurrency = "INR"
    @State private var selectedToCurrency = "JPY"
    
    var body: some View {
        VStack {
            if let rates = viewModel.currencyData?.data {
                VStack(spacing: 16) {
                    // Standard currency rows
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Rates (Base: USD)")
                        Text("\(rates)")
                            .font(.headline)
                        
                        
                    }
                    
                    // Converter section
                    VStack(spacing: 12) {
                        Text("Currency Converter")
                            .font(.headline)
                        
                        HStack {
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                            
                            Picker("From", selection: $selectedFromCurrency) {
                                Text("INR").tag("INR")
                                Text("JPY").tag("JPY")
                                Text("USD").tag("USD")
                                Text("AUD").tag("AUD")
                            }
                            .frame(width: 100)
                            
                            Text("→")
                            
                            Picker("To", selection: $selectedToCurrency) {
                                Text("INR").tag("INR")
                                Text("JPY").tag("JPY")
                                Text("USD").tag("USD")
                            }
                            .frame(width: 100)
                        }
                        
                        // Conversion result
                        if let convertedAmount = calculateConversion(
                            amount: Double(amount) ?? 1,
                            from: selectedFromCurrency,
                            to: selectedToCurrency,
                            rates: rates
                        ) {
                            HStack {
                                Text("\(amount) \(selectedFromCurrency) = ")
                                Text(String(format: "%.2f", convertedAmount))
                                    .bold()
                                Text(selectedToCurrency)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            } else if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
            } else {
                ProgressView("Loading rates...")
            }
        }
        .onAppear {
            viewModel.fetchCurrencyData()
        }
    }
    
    private func calculateConversion(amount: Double, from: String, to: String, rates: CurrencyRates) -> Double? {
        // First convert to USD (base currency)
        let fromRate = getRateForCurrency(from, rates: rates)
        let toRate = getRateForCurrency(to, rates: rates)
        
        guard fromRate > 0, toRate > 0 else { return nil }
        
        // Convert through USD as base currency
        let amountInUSD = amount / fromRate
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

struct CurrencyRow: View {
    let currency: String
    let rate: Double
    
    var body: some View {
        HStack {
            Text(currency)
                .frame(width: 50, alignment: .leading)
            Spacer()
            Text(String(format: "%.4f", rate))
                .monospacedDigit()
        }
    }
}

// Preview
#Preview {
    ApiSandBox()
}

