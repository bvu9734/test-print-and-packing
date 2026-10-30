codeunit 50204 "CCO Packaging Wksh. Tests"
{
  Subtype = Test;
  TestPermissions = Disabled;

  var
    Assert: Codeunit "Library Assert";
    LibraryPackaging: Codeunit "CCO Library - Packaging";
    PackagingWkshMgt: Codeunit "CCO Packaging Wksh. Mgt.";

  [Test]
  procedure LineCalculatesPriceFromCostSheet()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    CostSheet: Record "CCO Packaging Cost Sheet";
  begin
    // [GIVEN] A released specification for a customer with a 20% margin
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, LibraryPackaging.CreateSalesCustomer(20), true, true);

    // [WHEN] The specification and a quantity of 1,000 are entered on a worksheet line
    CreateWorksheetLine(PackagingWkshLine, LibraryPackaging.CreateWorksheetName(), PackagingSpecification."No.", 1000);

    // [THEN] The customer comes from the specification and the line is priced from its own cost sheet
    Assert.AreEqual(PackagingSpecification."Customer No.", PackagingWkshLine."Customer No.", 'The customer must default from the specification.');
    Assert.AreEqual(PackagingSpecification."Item No.", PackagingWkshLine."Item No.", 'The finished item must be shown.');
    AssertDecimal(20, PackagingWkshLine."Margin %", 'The margin must default from the customer.');
    AssertDecimal(1.17288, PackagingWkshLine."Unit Price (LCY)", 'Unit price = (0.3774 + 600 / 1000) x 1.2.');
    AssertDecimal(1172.88, PackagingWkshLine."Line Amount (LCY)", 'Line amount = 1.17288 x 1000.');
    Assert.IsTrue(CostSheet.Get(PackagingWkshLine."Cost Sheet No."), 'The line must have a cost sheet.');
  end;

  [Test]
  procedure ChangingLineMarginRepricesLine()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
  begin
    // [GIVEN] A calculated worksheet line for 1,000 pieces
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, LibraryPackaging.CreateSalesCustomer(20), true, true);
    CreateWorksheetLine(PackagingWkshLine, LibraryPackaging.CreateWorksheetName(), PackagingSpecification."No.", 1000);

    // [WHEN] The margin of the line is changed to 25%
    PackagingWkshLine.Validate("Margin %", 25);
    PackagingWkshLine.Modify(true);

    // [THEN] The line is repriced
    AssertDecimal(1.22175, PackagingWkshLine."Unit Price (LCY)", 'Unit price = 0.9774 x 1.25.');
  end;

  [Test]
  procedure LineRejectsSpecificationOfOtherCustomer()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
  begin
    // [GIVEN] A released specification of customer A
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, LibraryPackaging.CreateSalesCustomer(20), false, false);

    // [GIVEN] A worksheet line for customer B
    PackagingWkshLine.Init();
    PackagingWkshLine."Worksheet Name" := LibraryPackaging.CreateWorksheetName();
    PackagingWkshLine."Line No." := 10000;
    PackagingWkshLine.Validate("Customer No.", LibraryPackaging.CreateSalesCustomer(20));

    // [WHEN] The specification of customer A is entered
    asserterror PackagingWkshLine.Validate("Specification No.", PackagingSpecification."No.");

    // [THEN] The mismatch is reported
    Assert.ExpectedError('belongs to customer');
  end;

  [Test]
  procedure CreateSalesQuotesGroupsLinesPerCustomer()
  var
    SpecificationA1: Record "CCO Packaging Specification";
    SpecificationA2: Record "CCO Packaging Specification";
    SpecificationB: Record "CCO Packaging Specification";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    CostSheet: Record "CCO Packaging Cost Sheet";
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    SalesQuoteNos: List of [Code[20]];
    WorksheetName: Code[10];
    CustomerA: Code[20];
    CustomerB: Code[20];
  begin
    // [GIVEN] Two released specifications of customer A and one of customer B in one worksheet
    LibraryPackaging.InitializeRates();
    CustomerA := LibraryPackaging.CreateSalesCustomer(20);
    CustomerB := LibraryPackaging.CreateSalesCustomer(20);
    LibraryPackaging.CreateReleasedSpecification(SpecificationA1, CustomerA, true, true);
    LibraryPackaging.CreateReleasedSpecification(SpecificationA2, CustomerA, false, false);
    LibraryPackaging.CreateReleasedSpecification(SpecificationB, CustomerB, true, true);
    WorksheetName := LibraryPackaging.CreateWorksheetName();
    CreateWorksheetLine(PackagingWkshLine, WorksheetName, SpecificationA1."No.", 1000);
    CreateWorksheetLine(PackagingWkshLine, WorksheetName, SpecificationB."No.", 500);
    CreateWorksheetLine(PackagingWkshLine, WorksheetName, SpecificationA2."No.", 5000);

    // [WHEN] Sales quotes are created from the worksheet
    SalesQuoteNos := PackagingWkshMgt.CreateSalesQuotes(WorksheetName);

    // [THEN] One quote per customer is created: two lines for customer A, one line for customer B
    AssertDecimal(2, SalesQuoteNos.Count(), 'One sales quote per customer must be created.');
    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
    SalesHeader.SetRange("Sell-to Customer No.", CustomerA);
    SalesHeader.FindFirst();
    Assert.IsTrue(SalesQuoteNos.Contains(SalesHeader."No."), 'The quote of customer A must be returned.');
    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
    SalesLine.SetRange("Document No.", SalesHeader."No.");
    Assert.RecordCount(SalesLine, 2);
    SalesLine.SetRange("CCO Packaging Spec. No.", SpecificationA1."No.");
    SalesLine.FindFirst();
    AssertDecimal(1000, SalesLine.Quantity, 'The quantity of the worksheet line must be quoted.');

    SalesHeader.SetRange("Sell-to Customer No.", CustomerB);
    SalesHeader.FindFirst();
    SalesLine.Reset();
    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
    SalesLine.SetRange("Document No.", SalesHeader."No.");
    Assert.RecordCount(SalesLine, 1);

    // [THEN] The worksheet is empty and the cost sheets are kept and linked to the quotes
    PackagingWkshLine.Reset();
    PackagingWkshLine.SetRange("Worksheet Name", WorksheetName);
    Assert.RecordIsEmpty(PackagingWkshLine);
    CostSheet.SetRange("Specification No.", SpecificationB."No.");
    CostSheet.FindFirst();
    Assert.AreEqual(SalesHeader."No.", CostSheet."Sales Quote No.", 'The cost sheet must be linked to its quote.');
  end;

  [Test]
  procedure OnlyAcceptedLinesAreQuoted()
  var
    SpecificationAccepted: Record "CCO Packaging Specification";
    SpecificationSkipped: Record "CCO Packaging Specification";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    SalesQuoteNos: List of [Code[20]];
    WorksheetName: Code[10];
  begin
    // [GIVEN] A worksheet with an accepted line and a line that is not accepted
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(SpecificationAccepted, LibraryPackaging.CreateSalesCustomer(20), false, false);
    LibraryPackaging.CreateReleasedSpecification(SpecificationSkipped, LibraryPackaging.CreateSalesCustomer(20), false, false);
    WorksheetName := LibraryPackaging.CreateWorksheetName();
    CreateWorksheetLine(PackagingWkshLine, WorksheetName, SpecificationAccepted."No.", 1000);
    CreateWorksheetLine(PackagingWkshLine, WorksheetName, SpecificationSkipped."No.", 1000);
    PackagingWkshLine.Validate(Accept, false);
    PackagingWkshLine.Modify(true);

    // [WHEN] Sales quotes are created
    SalesQuoteNos := PackagingWkshMgt.CreateSalesQuotes(WorksheetName);

    // [THEN] Only the accepted line is quoted; the other line stays in the worksheet
    AssertDecimal(1, SalesQuoteNos.Count(), 'Only the accepted line must be quoted.');
    PackagingWkshLine.Reset();
    PackagingWkshLine.SetRange("Worksheet Name", WorksheetName);
    Assert.RecordCount(PackagingWkshLine, 1);
    PackagingWkshLine.FindFirst();
    Assert.AreEqual(SpecificationSkipped."No.", PackagingWkshLine."Specification No.", 'The line that is not accepted must stay.');
  end;

  [Test]
  procedure DeletingLineDeletesUnquotedCostSheet()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    CostSheet: Record "CCO Packaging Cost Sheet";
    CostSheetNo: Code[20];
  begin
    // [GIVEN] A calculated worksheet line
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, LibraryPackaging.CreateSalesCustomer(20), false, false);
    CreateWorksheetLine(PackagingWkshLine, LibraryPackaging.CreateWorksheetName(), PackagingSpecification."No.", 1000);
    CostSheetNo := PackagingWkshLine."Cost Sheet No.";

    // [WHEN] The line is deleted
    PackagingWkshLine.Delete(true);

    // [THEN] Its cost sheet is deleted too
    Assert.IsFalse(CostSheet.Get(CostSheetNo), 'The cost sheet of a deleted, unquoted line must be deleted.');
  end;

  [Test]
  procedure CreateSalesQuotesRequiresQuantity()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    WorksheetName: Code[10];
  begin
    // [GIVEN] A worksheet line without a quantity
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateReleasedSpecification(PackagingSpecification, LibraryPackaging.CreateSalesCustomer(20), false, false);
    WorksheetName := LibraryPackaging.CreateWorksheetName();
    CreateWorksheetLine(PackagingWkshLine, WorksheetName, PackagingSpecification."No.", 0);

    // [WHEN] Sales quotes are created
    asserterror PackagingWkshMgt.CreateSalesQuotes(WorksheetName);

    // [THEN] The user is asked to enter a quantity
    Assert.ExpectedError('Enter a quantity');
  end;

  local procedure CreateWorksheetLine(var PackagingWkshLine: Record "CCO Packaging Wksh. Line"; WorksheetName: Code[10]; SpecificationNo: Code[20]; LineQuantity: Decimal)
  var
    LastPackagingWkshLine: Record "CCO Packaging Wksh. Line";
  begin
    LastPackagingWkshLine.SetRange("Worksheet Name", WorksheetName);
    if LastPackagingWkshLine.FindLast() then;

    PackagingWkshLine.Init();
    PackagingWkshLine."Worksheet Name" := WorksheetName;
    PackagingWkshLine."Line No." := LastPackagingWkshLine."Line No." + 10000;
    PackagingWkshLine.Validate("Specification No.", SpecificationNo);
    if LineQuantity <> 0 then
      PackagingWkshLine.Validate(Quantity, LineQuantity);
    PackagingWkshLine.Insert(true);
  end;

  local procedure AssertDecimal(Expected: Decimal; Actual: Decimal; Message: Text)
  begin
    Assert.AreEqual(Expected, Actual, Message);
  end;
}
