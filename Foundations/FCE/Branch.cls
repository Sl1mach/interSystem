Class FCE.Branch Extends (%Persistent,%Library.Populate,%XML.Adaptor)
{
	Property NationalCurrency As FCE.CurrencyName [InitialExpression = "USD"];
	Property Phone As FCE.PhoneNumber[Required];
	Property Address As FCE.RealEstate;
	ForeignKey RealEstateFk(Address) References FCE.RealEstate() [OnDelete = setnull];
	Property Opens As %Time(MINVAL = "$ztimeh(""6:00 am"")", MAXVAL = "$ztimeh(""12:00n"")");
	Property Closes As %Time(MINVAL = "$ztimeh(""1:00 pm"")", MAXVAL = "$ztimeh(""10:00pm"")");
	Property DurationOpen As %String [Calculated, SqlComputed, SqlComputeCode = 
	{	if ({Closes} = "") || ({Opens} = "") {
			set {DurationOpen} = ""
		}
		else {
			set {DurationOpen} = $ztime({Closes} - {Opens})
		}
	}];
	
	
	Index PhoneIndex on Phone [Unique];
	Index AddressIndex on Address [Unique];

	/// create a JSON object from Branch properties
	Method CopyToObject(object as %DynamicObject) as %Status
	{
		set object.ID = ..%Id()
		set object.Phone = ..Phone
		set object.Opens = $ztime(..Opens)
		set object.Closes = $ztime(..Closes)
		return $$$OK
	}
	
	/// copy a JSON object into Branch properties
	Method CopyFromObject(object as %DynamicObject) as %Status
	{
		set ..Phone  = object.Phone
		set ..Opens = $ztimeh(object.Opens)
		set ..Closes = $ztimeh(object.Closes)
		return $$$OK
	}
	





	Storage Default
{
<Data name="BranchDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>NationalCurrency</Value>
</Value>
<Value name="3">
<Value>Phone</Value>
</Value>
<Value name="4">
<Value>Address</Value>
</Value>
<Value name="5">
<Value>Opens</Value>
</Value>
<Value name="6">
<Value>Closes</Value>
</Value>
</Data>
<DataLocation>^FCE.BranchD</DataLocation>
<DefaultData>BranchDefaultData</DefaultData>
<IdLocation>^FCE.BranchD</IdLocation>
<IndexLocation>^FCE.BranchI</IndexLocation>
<StreamLocation>^FCE.BranchS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}