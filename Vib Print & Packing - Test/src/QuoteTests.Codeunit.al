codeunit 50202 "CCO Quote Tests"
{
  Subtype = Test;
  TestPermissions = Disabled;

  var
    Assert: Codeunit "Library Assert";
    LibraryPackaging: Codeunit "CCO Library - Packaging";
    LibrarySales: Codeunit "Library - Sales";
    LibraryInventory: Codeunit "Library - Inventory";
    PackagingQuoteMgt: Codeunit "CCO Packaging Quote Mgt.";

  [Test]
  procedure CreateSalesQuoteUsesLadderPrice()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
  begin
    // [GIVEN] A released specification with a finished item and a calculated cost sheet for a customer with a 20% margin
    CreateReleasedSpecificationWithCostSheet(PackagingSpecification, CostSheet);

    // [WHEN] A sales quote is created for 1,000 pieces
    PackagingQuoteMgt.CreateSalesQuote(CostSheet, 1000, SalesHeader);

    // [THEN] A quote for the customer with one line for the finished item at the ladder price is created
    Assert.AreEqual(SalesHeader."Document Type"::Quote, SalesHeader."Document Type", 'A sales quote must be created.');
    Assert.AreEqual(CostSheet."Customer No.", SalesHeader."Sell-to Customer No.", 'The quote must be for the cost sheet customer.');
    FindQuoteLine(SalesHeader, SalesLine);
    Assert.AreEqual(SalesLine.Type::Item, SalesLine.Type, 'The quote line must be an item line.');
    Assert.AreEqual(PackagingSpecification."Item No.", SalesLine."No.", 'The quote line must be for the finished item.');
    Assert.AreEqual(1000, SalesLine.Quantity, 'The quote line must have the chosen quantity.');
    Assert.AreEqual(RoundUnitPrice(1.17288), SalesLine."Unit Price", 'The unit price must be the rounded ladder price.');
    Assert.AreEqual(0, SalesLine."Line Discount %", 'The calculated price must not be discounted.');

    // [THEN] The quote line and the cost sheet are linked
    Assert.AreEqual(PackagingSpecification."No.", SalesLine."CCO Packaging Spec. No.", 'The quote line must be linked to the specification.');
    Assert.AreEqual(CostSheet."No.", SalesLine."CCO Cost Sheet No.", 'The quote line must be linked to the cost sheet.');
    CostSheet.Get(CostSheet."No.");
    Assert.AreEqual(SalesHeader."No.", CostSheet."Sales Quote No.", 'The cost sheet must be linked to the quote.');
  end;

  [Test]
  procedure CreateSalesQuoteForCustomQuantity()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
  begin
    // [GIVEN] A released specification and a calculated cost sheet
    CreateReleasedSpecificationWithCostSheet(PackagingSpecification, CostSheet);

    // [WHEN] A sales quote is created for 2,500 pieces, which is not in the default ladder
    PackagingQuoteMgt.CreateSalesQuote(CostSheet, 2500, SalesHeader);

    // [THEN] The quantity is added to the ladder and quoted at its calculated price
    CostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    CostSheetLine.SetRange(Quantity, 2500);
    Assert.RecordIsNotEmpty(CostSheetLine);
    FindQuoteLine(SalesHeader, SalesLine);
    Assert.AreEqual(2500, SalesLine.Quantity, 'The quote line must have the custom quantity.');
    Assert.AreEqual(RoundUnitPrice(0.74088), SalesLine."Unit Price", 'Unit price = (0.3774 + 600 / 2500) x 1.2, rounded.');
  end;

  [Test]
  procedure CreateSalesQuoteRequiresReleasedSpecification()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    SalesHeader: Record "Sales Header";
  begin
    // [GIVEN] A calculated cost sheet for a specification without a finished item
    CreateReleasedSpecificationWithCostSheet(PackagingSpecification, CostSheet);
    PackagingSpecification.Get(PackagingSpecification."No.");
    PackagingSpecification."Item No." := '';
    PackagingSpecification.Modify(false);

    // [WHEN] A sales quote is created
    asserterror PackagingQuoteMgt.CreateSalesQuote(CostSheet, 1000, SalesHeader);

    // [THEN] The user is told to release the specification first
    Assert.ExpectedError('has no finished item');
  end;

  local procedure CreateReleasedSpecificationWithCostSheet(var PackagingSpecification: Record "CCO Packaging Specification"; var CostSheet: Record "CCO Packaging Cost Sheet")
  var
    Customer: Record Customer;
    Item: Record Item;
  begin
    LibraryPackaging.InitializeRates();
    LibrarySales.CreateCustomer(Customer);
    Customer."CCO Packaging Margin %" := 20;
    Customer.Modify(false);
    LibraryInventory.CreateItem(Item);

    LibraryPackaging.CreateSpecification(PackagingSpecification, Customer."No.", true, true);
    PackagingSpecification.Status := PackagingSpecification.Status::Released;
    PackagingSpecification."Item No." := Item."No.";
    PackagingSpecification.Modify(false);

    LibraryPackaging.CreateCalculatedCostSheet(PackagingSpecification, CostSheet);
  end;

  local procedure FindQuoteLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
  begin
    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
    SalesLine.SetRange("Document No.", SalesHeader."No.");
    Assert.RecordCount(SalesLine, 1);
    SalesLine.FindFirst();
  end;

  local procedure RoundUnitPrice(UnitPrice: Decimal) RoundedUnitPrice: Decimal
  var
    Currency: Record Currency;
  begin
    Currency.Initialize('');
    RoundedUnitPrice := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");
  end;
}
