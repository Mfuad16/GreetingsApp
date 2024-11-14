//
//  currencyBoxView.swift
//  GreetingsApp
//
//  Created by Mohamed Fuad on 11/12/24.
//
import SwiftUI

struct CurrencyBoxView: View {
    @State private var selectedFromCurrency = "USD"
    @State private var selectedToCurrency = "JPY"
    @State var amount: String = "1"
    @State var convertedAmount: Double = 0
    
    var body: some View {
        ZStack {
            CurrencyConverterMid(
                amount: $amount,
                selectedFromCurrency: $selectedFromCurrency,
                selectedToCurrency: $selectedToCurrency,
                convertedAmount: $convertedAmount
            ).zIndex(1)
            
            VStack {
                CurrencyConvertorBox(
                    selectedCurrency: $selectedFromCurrency,
                    selectedFromCurrency: $selectedFromCurrency,
                    selectedToCurrency: $selectedToCurrency,
                    amount: $amount,
                    backgroundColor: .blue,
                    convertedAmountIs: $convertedAmount
                )
                CurrencyConvertorBox(
                    selectedCurrency: $selectedToCurrency,
                    selectedFromCurrency: $selectedFromCurrency,
                    selectedToCurrency: $selectedToCurrency,
                    amount: $amount,
                    backgroundColor: .red,
                    convertedAmountIs: $convertedAmount
                )
            }
        }
    }
}

struct CurrencyConvertorBox: View {
    @ObservedObject var viewModel = MainViewModel()
    @Binding var selectedCurrency: String
    @Binding var selectedFromCurrency: String
    @Binding var selectedToCurrency: String
    @Binding var amount: String
    var backgroundColor: Color
    @Binding var convertedAmountIs: Double
    
    var body: some View {
        HStack {
            VStack {
                Text(selectedCurrency)
                TextField(amount, text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
            }
            
            Spacer()
            
            VStack {
                Text(selectedCurrency)
                Picker("From", selection: $selectedCurrency) {
                    Text("INR").tag("INR")
                    Text("JPY").tag("JPY")
                    Text("USD").tag("USD")
                    Text("AUD").tag("AUD")
                }
                .frame(width: 100)
                .tint(.black)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .frame(height: 80)
        .padding()
        .background(backgroundColor.opacity(0.8))
        .onAppear {
            viewModel.fetchCurrencyData()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

struct CurrencyConverterMid: View {
    @Binding var amount: String
    @Binding var selectedFromCurrency: String
    @Binding var selectedToCurrency: String
    @Binding var convertedAmount: Double
    @ObservedObject var viewModel = MainViewModel()
    
    let time = Date()
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Image(systemName: "arrow.up.circle")
                Image(systemName: "arrow.down.circle")
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Text("\(amount) \(selectedFromCurrency) = ")
                    Text(String(format: "%.2f", convertedAmount))
                        .bold()
                    Text(selectedToCurrency)
                }
                
                HStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 10, height: 10)
                    Text("\(time.formatted(date: .numeric, time: .shortened))")
                }
            }
            .onAppear {
                viewModel.fetchCurrencyData()
                if let rates = viewModel.currencyData?.data {
                    convertedAmount = viewModel.CalculateExchangeValue(
                        amount: Double(amount) ?? 0.0,
                        from: selectedFromCurrency,
                        to: selectedToCurrency,
                        rates: rates
                    ) ?? 0
                }
            }
            .onChange( of: [amount, selectedFromCurrency,selectedToCurrency]) { _ in
                if let rates = viewModel.currencyData?.data {
            convertedAmount = viewModel.CalculateExchangeValue(
                amount: Double(amount) ?? 0.0,
                from: selectedFromCurrency,
                to: selectedToCurrency,
                rates: rates
            ) ?? 0
        }
                        }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: 300, maxHeight: 30)
        .padding()
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}







#Preview {
    CurrencyBoxView()
}
