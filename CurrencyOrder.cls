/// An order for currency.
Class FCE.CurrencyOrder Extends (%Persistent, %Populate, %XML.Adaptor)
{

/// name of requestor
Property Requestor;

Property RequestorEmail;

Property AmountOut;

Property CurrencyOut;

Property AmountIn;

Property CurrencyIn;

Property ExchangeRate;

Property Fee;

Property DateStamp;

Property TimeStamp;

/// Satisfaction with the service on this order
Property Satisfaction;

/// Requested: initial request<br>
/// Pending:   only if awaiting approval<br>
/// Rejected:  not approved by bank<br>
/// Paid:      currency received by ATM, outgoing currency to be picked up<br>
/// Completed: outgoing currency paid to customer<br>
/// Problem:   problem in system<br>
/// Canceled:  canceled by customer<br>
Property Status;

Method OnPopulate() As %Status
{
	// only 10% of CurrencyOrders happen at a Branch (no ATM)
	if ($random(10) = 0) { set ..ATM = "" }
	// 80% CurrencyOrders are Status = Completed
	if ($random(10) > 1) {
		set ..Status = "Completed"
	}
	else {
		set ..Status = ##class(%PopulateUtils).ValueList("-Requested-Pending-Rejected-Paid-Problem-Canceled")
	}
	// make sure CurrencyIn and CurrencyOut are different
	while (..CurrencyIn = ..CurrencyOut) {
		set ..CurrencyOut = ##class(FCE.Currency).Currency()
	}
	// set fee
	set ..Fee = ..AmountIn * .025
	// get exchange rate
	set rate = ##class(FCE.Currency).ComputeRate(..CurrencyIn, ..CurrencyOut)
	set ..ExchangeRate = rate
	// set correct AmountOut
	set ..AmountOut = (..AmountIn - ..Fee) * rate
	return $$$OK
}

}
