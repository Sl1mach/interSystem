Class FCE.Tests.BasicTests Extends FCE.Tests.TestCase
{
	Property RefdRealEstate As FCE.RealEstate [Private];
	Property UnrefdRealEstate As FCE.RealEstate [Private];
	
	Method OnBeforeAllTests() As %Status
	{
	 	// create a Branch with this phone #
	
		set branch = ##class(FCE.Branch).%New()
	
		set branch.Phone = "999-999-9999"
	
	 
	
	 	/* create a dummy RealEstate object, link it to the Branch above
	
	           and save the object in the "global" RefdRealEstate property */
	
		set realestate = ##class(FCE.RealEstate).%New()
	
		set realestate.Street = "10 Main Street"
	
		set realestate.City = "New York"
	
		set realestate.State = "NY"
	
		set realestate.Zip = "99999"
	
		set status = realestate.%Save()
	
		set branch.Address = realestate
	
		set status = branch.%Save()
	
		set ..RefdRealEstate = realestate
	
		
	
		/* create a dummy RealEstate object that *isn't* referenced by a Branch
	
		   save the object in the "global" UnrefdRealEstate property */
	
		set realestate = ##class(FCE.RealEstate).%New()
	
		set realestate.Street = "20 Oak Street"
	
		set realestate.City = "Boston"
	
		set realestate.State = "MA"
	
		set realestate.Zip = "99999"
	
		set status = realestate.%Save()
	
		set ..UnrefdRealEstate = realestate
	
	 	return $$$OK
	}
	
	Method OnAfterAllTests() As %Status
	{
		/// in case any tests fail to *complete*
	
		/// remove the leftover branch and the initial branch
	
		&sql(delete from FCE.Branch
	
		     where (Phone = '999-999-9999' or Phone = '999-999-0000'))
	
		set ID1 = ..RefdRealEstate.%Id(), ID2 = ..UnrefdRealEstate.%Id()
	
		&sql(delete from FCE.RealEstate where ID in (:ID1, :ID2))
	
		return $$$OK
	}
		Method TestBranch()
	{
		// assertion 1
	
		set branch = ##class(FCE.Branch).%New()
	
		do $$$AssertTrue($isobject(branch),"Created New Branch")
	
		
	
		// assertion 2
	
		set status = branch.%Save()
	
		do $$$AssertStatusNotOK(status, "Phone is required")
	
		
	
		// assertion 3
	
		set branch.Phone = "9999999999" // bad pattern
	
		set status = branch.%Save()
	
		do $$$AssertStatusNotOK(status, "Phone doesn't match pattern: ###-###-####")
	
	
	
		// assertion 4
	
		set branch.Phone = "999-999-9999" // pre-existing number
	
		set status = branch.%Save()
	
		do $$$AssertStatusNotOK(status, "Phone must be unique")
	
	
	
		// assertion 5
	
		set branch.Phone = "999-999-0000"
	
		set branch.Address = ..RefdRealEstate
	
		set status = branch.%Save()
	
		do $$$AssertStatusNotOK(status, "Another Branch already has this address")
	
	
	
		// assertion 6
	
		set branch.Address = ..UnrefdRealEstate
	
		set branch.Opens = 18000 // open at 5am
	
		set status = branch.%Save()
	
		do $$$AssertStatusNotOK(status, "Opening at 5am too early")
	
		
	
		// assertion 7
	
		set branch.Opens = 28800 // open at 8am
	
		set branch.Closes = 82800 // close at 11pm
	
		set status = branch.%Save()
	
		do $$$AssertStatusNotOK(status, "Closing at 11pm too late")
	
	
	
		// assertion 8
	
		set branch.Closes = 64800 // close at 6pm
	
		set branch.NationalCurrency = "ABC" // invalid currency
	
		set status = branch.%Save()
	
		do $$$AssertStatusNotOK(status, "ABC is invalid currency")
	
	
	
		// assertion 9
	
		set branch.NationalCurrency = "USD" // valid currency
	
		set status = branch.%Save()
	
		do $$$AssertStatusOK(status, "Branch saved")
	
	
	
		// assertion 10
	
		set branchID = branch.%Id()
	
		do $$$AssertNotEquals(branchID, "", "ID assigned")
	
	
	
		// assertion 11
	
		set status = ##class(FCE.Branch).%DeleteId(branchID)
	
		do $$$AssertStatusOK(status, "Branch deleted")
	}
	Method TestBranchSQL()
	
	{
	
		set realestateID = ..UnrefdRealEstate.%Id()
	
	
	
		&sql(insert into FCE.Branch (Address)
	
		     VALUES (:realestateID))
	
		do $$$AssertNotEquals(SQLCODE, 0, "Phone is required")
	
		&sql(insert into FCE.Branch (Phone, Address)
	
		     VALUES ('9999999999',:realestateID))
	
		do $$$AssertNotEquals(SQLCODE, 0, "Phone doesn't match pattern: ###-###-####")
	
		&sql(insert into FCE.Branch (Phone, Address)
	
		     VALUES ('999-999-9999',:realestateID))
	
		do $$$AssertNotEquals(SQLCODE, 0, "Phone must be unique")
	
		&sql(insert into FCE.Branch (Phone, Address, Opens)
	
		     VALUES ('999-999-0000',:realestateID,18000))
	
		do $$$AssertNotEquals(SQLCODE, 0, "Opening at 5am too early")
	
		&sql(insert into FCE.Branch (Phone, Address, Opens, Closes)
	
		     VALUES ('999-999-0000',:realestateID,28800,82800))
	
		do $$$AssertNotEquals(SQLCODE, 0, "Closing at 11pm too late")
	
		&sql(insert into FCE.Branch (Phone, Address, Opens, Closes, NationalCurrency)
	
		     VALUES ('999-999-0000',:realestateID,28800,64800,'ABC'))
	
		do $$$AssertNotEquals(SQLCODE, 0, "ABC is invalid currency")
	
		&sql(insert into FCE.Branch (Phone, Address, Opens, Closes, NationalCurrency)
	
		     VALUES ('999-999-0000',:realestateID,28800,64800,'USD'))
	
		do $$$AssertEquals(SQLCODE, 0, "Branch saved")
	
		set branchID = %ROWID
	
		do $$$AssertNotEquals(branchID, "", "ID assigned")
	
		&sql(delete from FCE.Branch where ID = :branchID)
	
		do $$$AssertEquals(SQLCODE, 0, "Branch deleted")
	
	}





/// Basic tests for FCE.RealEstate

	Method TestRealEstate()
	
	{
	
		// assertion 1
	
		set realestate = ##class(FCE.RealEstate).%New()
	
		set status = realestate.%Save()
	
		do $$$AssertStatusNotOK(status, "Real Estate requires all 4 properties")
	
		// assertion 2
	
		set realestate.Street = "10 Main St."
	
		set status = realestate.%Save()
	
		do $$$AssertStatusNotOK(status, "Real Estate requires all 4 properties")
	
		// assertion 3
	
		set realestate.City = "New York"
	
		set status = realestate.%Save()
	
		do $$$AssertStatusNotOK(status, "Real Estate requires all 4 properties")
	
		// assertion 4
	
		set realestate.State = "ny"
	
		set status = realestate.%Save()
	
		do $$$AssertStatusNotOK(status, "State must be on VALUELIST and must match case")
	
		// assertion 5
	
		set realestate.State = "NY"
	
		set status = realestate.%Save()
	
		do $$$AssertStatusNotOK(status, "Real Estate requires all 4 properties")
	
		// assertion 6
	
		set realestate.Zip = "123"
	
		set status = realestate.%Save()
	
		do $$$AssertStatusNotOK(status, "ZipCode must be ##### or #####-####")
	
		// assertion 7
	
		set realestate.Zip = "12345-1"
	
		set status = realestate.%Save()
	
		do $$$AssertStatusNotOK(status, "ZipCode must be ##### or #####-####")
	
		// assertion 8
	
		set realestate.Zip = "99999-4567"
	
		set status = realestate.%Save()
	
		set realestateID = realestate.%Id()
	
		do $$$AssertStatusOK(status, "Real Estate saved")
	
		// assertion 9
	
		set branch = ##class(FCE.Branch).%New()
	
		set branch.Phone = "999-999-0000"
	
		set branch.Address = realestate
	
		set status = branch.%Save()
	
		set branchID = branch.%Id()
	
		do $$$AssertStatusOK(status, "Branch saved")
	
		// assertion 10
	
		set (branch, realestate) = ""
	
		do $$$LogMessage("All objects closed")
	
		// assertion 11
	
		set branch = ##class(FCE.Branch).%OpenId(branchID)
	
		set realestate = ##class(FCE.RealEstate).%OpenId(realestateID)
	
		do $$$AssertEquals(branch.Address.City, realestate.City, "Branch references Real Estate")
	
		// assertion 12
	
		set (branch, realestate) = ""
	
		do $$$LogMessage("All objects closed")
	
		// assertion 13
	
		set status = ##class(FCE.RealEstate).%DeleteId(realestateID)
	
		do $$$AssertStatusOK(status, "Real Estate deleted")
	
		// assertion 14
	
		set realestateID = ##class(FCE.Branch).AddressGetStored(branchID)
	
		do $$$AssertEquals(realestateID, "", "Branch not linked to Real Estate")
	
		// assertion 15
	
		set status = ##class(FCE.Branch).%DeleteId(branchID)
	
		do $$$AssertStatusOK(status, "Branch deleted")
	
	}



/// SQL tests for FCE.RealEstate

	Method TestRealEstateSQL()
	
	{
	
		&sql(insert into FCE.RealEstate (Street) VALUES ('10 Main St.'))
	
		do $$$AssertNotEquals(SQLCODE, 0, "Real Estate requires all 4 properties")
	
		&sql(insert into FCE.RealEstate (Street,City) VALUES ('10 Main St.','New York'))
	
		do $$$AssertNotEquals(SQLCODE, 0, "Real Estate requires all 4 properties")
	
		&sql(insert into FCE.RealEstate (Street,City,State)
	
	             VALUES ('10 Main St.','New York','ny'))
	
		do $$$AssertNotEquals(SQLCODE, 0, "State must be on VALUELIST and must match case")
	
		&sql(insert into FCE.RealEstate (Street,City,State)
	
	             VALUES ('10 Main St.','New York','NY'))
	
		do $$$AssertNotEquals(SQLCODE, 0, "Real Estate requires all 4 properties")
	
		&sql(insert into FCE.RealEstate (Street,City,State,Zip) 
	
	             VALUES ('10 Main St.','New York','NY','123'))
	
		do $$$AssertNotEquals(SQLCODE, 0, "ZipCode must be ##### or #####-####")
	
		&sql(insert into FCE.RealEstate (Street,City,State,Zip) 
	
	             VALUES ('10 Main St.','New York','NY','12345-1'))
	
		do $$$AssertNotEquals(SQLCODE, 0, "ZipCode must be ##### or #####-####")
	
		&sql(insert into FCE.RealEstate (Street,City,State,Zip)
	
	             VALUES ('10 Main St.','New York','NY','99999-4567'))
	
		do $$$AssertEquals(SQLCODE, 0, "Real Estate saved")
	
		set realestateID = %ROWID
	
		do $$$AssertNotEquals(realestateID, "", "Real Estate ID assigned")
	
		&sql(insert into FCE.Branch (Phone,Address) VALUES ('999-999-0000',:realestateID))
	
		do $$$AssertEquals(SQLCODE, 0, "Branch saved")
	
		set branchID = %ROWID
	
		&sql(select Address->City into :city from FCE.Branch where ID = :branchID)
	
		do $$$AssertEquals(SQLCODE, 0, "City retrieved")
	
		do $$$AssertEquals(city, "New York", "Branch references Real Estate")
	
		&sql(delete from FCE.RealEstate where ID = :realestateID)
	
		do $$$AssertEquals(SQLCODE, 0, "Real Estate deleted")
	
		&sql(select Address into :realestateID from FCE.Branch where ID = :branchID)
	
		do $$$AssertEquals(SQLCODE, 0, "Real Estate ID retrieved")
	
		do $$$AssertEquals(realestateID, "", "Branch not linked to Real Estate")
	
		&sql(delete from FCE.Branch where ID = :branchID)
	
		do $$$AssertEquals(SQLCODE, 0, "Branch deleted")
	
	}
	
}