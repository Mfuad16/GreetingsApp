
import SwiftUI
struct CurrencyBoxView: View {
    
    @State private var selectedFromCurrency = "USD"
    @State private var selectedToCurrency = "JPY"
    @State var convertedAmount: (Double, Double) = (0.0, 0.0) // (FromAmount, ToAmount)
    @FocusState private var focusedField: Field?
    

    enum Field: Hashable {
            case amountBox1
            case amountBox2
    }

  
    var body: some View {
        ZStack {
            CurrencyConverterMid(
                selectedFromCurrency: $selectedFromCurrency,
                selectedToCurrency: $selectedToCurrency
            )
            .zIndex(1)

            VStack {
                CurrencyConvertorBox(
                    selectedCurrency: $selectedFromCurrency,
                    selectedFromCurrency: $selectedFromCurrency,
                    selectedToCurrency: $selectedToCurrency,
                    amount: $convertedAmount.0,
                    backgroundColor: .blue,
                    
                    convertedAmountIs: $convertedAmount,
                    focusedField: $focusedField,
                    field: .amountBox1
                )
                CurrencyConvertorBox(
                    selectedCurrency: $selectedToCurrency,
                    selectedFromCurrency: $selectedToCurrency,
                    selectedToCurrency: $selectedFromCurrency,
                    amount: $convertedAmount.1,
                    backgroundColor: .red,
                    convertedAmountIs: $convertedAmount,
                    focusedField: $focusedField,
                    field: .amountBox2
                )
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Dismiss") {
                    focusedField = nil
                }
            }
        }
    }
}

struct CurrencyConvertorBox: View {
    @ObservedObject var viewModel = MainViewModel()
    @Binding var selectedCurrency: String
    @Binding var selectedFromCurrency: String
    @Binding var selectedToCurrency: String
    @Binding var amount: Double // The value entered by the user in this box
    var backgroundColor: Color
    @Binding var convertedAmountIs: (Double, Double) // Holds both from and to amounts

    var focusedField :FocusState<CurrencyBoxView.Field?>.Binding
    var field: CurrencyBoxView.Field
   
    var body: some View {
        HStack {
            VStack {
                Text(selectedCurrency)
               
                TextField("Enter amount", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                    .focused(focusedField, equals: field)
                    .onChange(of: amount) { _ in
                        if let rates = viewModel.currencyData?.data {
                            if selectedCurrency == selectedFromCurrency {
                                // Update ToAmount
                                if let result = viewModel.calculateExchangeValueForCurrency(
                                    FromAmount: amount,
                                    ToAmount: nil,
                                    from: selectedFromCurrency,
                                    to: selectedToCurrency,
                                    rates: rates
                                ) {
                                    convertedAmountIs = result
                                    print(convertedAmountIs)
                                }
                            } else if selectedCurrency == selectedToCurrency {
                                // Update FromAmount
                                if let result = viewModel.calculateExchangeValueForCurrency(
                                    FromAmount: nil,
                                    ToAmount: amount,
                                    from: selectedFromCurrency,
                                    to: selectedToCurrency,
                                    rates: rates
                                ) {
                                    convertedAmountIs = result
                                }
                            }
                        }
                    }
            }

            Spacer()

            VStack {
              
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
//            .background(Color.gray.opacity(0.1))
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
    @ObservedObject var viewModel = MainViewModel()
    let time = Date()
    @Binding var selectedFromCurrency: String
    @Binding var selectedToCurrency: String
    @State  var conversionRate: Double = 0.0
   
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Image(systemName: "arrow.up.circle")
                Image(systemName: "arrow.down.circle")
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Text("1 \(selectedFromCurrency) = ")
                    
                    if let rates = viewModel.currencyData?.data {
                        Text(String(format: "%.2f", viewModel.CalculateExchangeValue(amount: 1, from: selectedFromCurrency, to: selectedToCurrency, rates: rates) ?? 0.0))
                    }
                    
                    Text(selectedToCurrency)
                }
                .bold()
                
                HStack {
                    Circle()
                        .fill(.yellow)
                        .frame(width: 10, height: 10)
                    Text("\(time.formatted(date: .numeric, time: .shortened))")
                }
            }
            .onAppear {
                viewModel.fetchCurrencyData()
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
