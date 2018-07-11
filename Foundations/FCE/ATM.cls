Class FCE.ATM Extends (%Persistent,%XML.Adaptor,%Library.Populate)
{
	Property SerialNumber As %String(POPSPEC ="##class(%PopulateUtils).String(5)_##class(%PopulateUtils).String(5)");
	Index SerialNumberIndex on SerialNumber [Unique];
	Property Address as FCE.RealEstate;
	ForeignKey RealEstateFk(Address) References FCE.RealEstate() [OnDelete = setnull];
	Property CurrencyBalances as array of %Numeric (MINVAL = 0, MAXVAL = 10000, POPSPEC=":5:##class(FCE.Currency).Currency()") [SqlFieldName = Balance];
	Index CBIndex on CurrencyBalances(KEYS);






	
	Storage Default
{
<Data name="ATMDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SerialNumber</Value>
</Value>
<Value name="3">
<Value>Address</Value>
</Value>
</Data>
<Data name="CurrencyBalances">
<Attribute>CurrencyBalances</Attribute>
<Structure>subnode</Structure>
<Subscript>"CurrencyBalances"</Subscript>
</Data>
<DataLocation>^FCE.ATMD</DataLocation>
<DefaultData>ATMDefaultData</DefaultData>
<IdLocation>^FCE.ATMD</IdLocation>
<IndexLocation>^FCE.ATMI</IndexLocation>
<StreamLocation>^FCE.ATMS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}