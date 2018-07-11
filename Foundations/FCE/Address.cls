Class FCE.Address Extends (%Library.Populate,%XML.Adaptor) [Abstract]
{
	Property Street As %String [Required];
	Property City As %String [Required];
	Property State As %String(VALUELIST="-NY-NJ-MA-TX", MAXLEN=2) [Required];
	//Property Zip As %String(PATTERN="5n.1(1""-""4n)", MAXLEN=10) [Required];
	Property Zip As FCE.Regex(REGEX="\d{5}(-\d{4})?") [Required];
	
	Method Print(){
		write ..Street, !, ..City," ", ..State," ", ..Zip
	}
}