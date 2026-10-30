codeunit 50200 "CCO Cost Engine Tests"
{
  Subtype = Test;
  TestPermissions = Disabled;

  var
    Assert: Codeunit "Library Assert";
    LibraryPackaging: Codeunit "CCO Library - Packaging";
    CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";

  [Test]
  procedure CalculateAppliesAgreedFormula()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    // [GIVEN] A Digital specification of 300 x 200 mm with 10% waste, 2 colors, lamination, and a die cost of 500
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateSpecification(PackagingSpecification, LibraryPackaging.CreateCustomer(20), true, true);

    // [WHEN] The cost sheet is calculated
    LibraryPackaging.CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

    // [THEN] Each cost component follows the agreed formula
    AssertDecimal(0.06, CostSheet."Base Area (m²)", 'Base Area = 300 x 200 / 1,000,000');
    AssertDecimal(0.066, CostSheet."Required Area (m²)", 'Required Area = Base Area x 110 / 100');
    AssertDecimal(0.165, CostSheet."Material Cost", 'Material Cost = 0.066 x 2.5');
    AssertDecimal(0.0264, CostSheet."Ink Cost", 'Ink Cost = 0.066 x 0.01 x 2 x 20');
    AssertDecimal(0.02, CostSheet."Glue Cost", 'Glue Cost = 0.005 x 4');
    AssertDecimal(0.096, CostSheet."Lamination Cost", 'Lamination Cost = 0.066 x 1 + 0.03');
    AssertDecimal(0.02, CostSheet."Printing Cost", 'Printing Cost from the print cost matrix');
    AssertDecimal(0.05, CostSheet."Labor Cost", 'Labor Cost from the print cost matrix');
    AssertDecimal(0.3774, CostSheet."Variable Unit Cost", 'Variable Unit Cost = sum of per-piece costs');
    AssertDecimal(600, CostSheet."Fixed Cost", 'Fixed Cost = machine setup 100 + die 500');

    // [THEN] The 1,000 piece line spreads the fixed cost and adds the 20% customer markup
    FindLine(CostSheet, 1000, CostSheetLine);
    AssertDecimal(0.6, CostSheetLine."Fixed Cost per Piece", 'Fixed Cost per Piece = 600 / 1000');
    AssertDecimal(0.9774, CostSheetLine."Unit Cost", 'Unit Cost = 0.3774 + 0.6');
    AssertDecimal(1.17288, CostSheetLine."Unit Price", 'Unit Price = 0.9774 x 1.2');
    AssertDecimal(1172.88, CostSheetLine."Line Amount", 'Line Amount = 1.17288 x 1000');
  end;

  [Test]
  procedure CalculateCreatesDefaultPriceLadder()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
    LadderQuantity: Decimal;
  begin
    // [GIVEN] A specification
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateSpecification(PackagingSpecification, '', false, false);

    // [WHEN] A new cost sheet is calculated
    LibraryPackaging.CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

    // [THEN] One line exists for each default ladder quantity
    CostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    Assert.AreEqual(5, CostSheetLine.Count(), 'The cost sheet must contain the five default ladder quantities.');
    foreach LadderQuantity in CostEngineMgt.GetDefaultQuantities() do
      FindLine(CostSheet, LadderQuantity, CostSheetLine);
  end;

  [Test]
  procedure DieCostIgnoredWithoutDieCut()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
  begin
    // [GIVEN] A specification with a die cost but without die cutting or lamination
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateSpecification(PackagingSpecification, '', false, false);

    // [WHEN] The cost sheet is calculated
    LibraryPackaging.CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

    // [THEN] Only the machine setup cost is a fixed cost, and no lamination cost applies
    AssertDecimal(0, CostSheet."Die Cost", 'Die Cost must be zero without die cutting.');
    AssertDecimal(100, CostSheet."Fixed Cost", 'Fixed Cost must equal the machine setup cost.');
    AssertDecimal(0, CostSheet."Lamination Cost", 'Lamination Cost must be zero without lamination.');
  end;

  [Test]
  procedure MarginDefaultsFromCustomer()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
  begin
    // [GIVEN] A specification for a customer with a 25% packaging margin
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateSpecification(PackagingSpecification, LibraryPackaging.CreateCustomer(25), false, false);

    // [WHEN] The specification is selected on a cost sheet
    LibraryPackaging.CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

    // [THEN] The cost sheet uses the customer margin
    AssertDecimal(25, CostSheet."Margin %", 'Margin % must default from the customer.');
  end;

  [Test]
  procedure ChangingMarginUpdatesLinePrices()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    // [GIVEN] A calculated cost sheet
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateSpecification(PackagingSpecification, '', false, false);
    LibraryPackaging.CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

    // [WHEN] The margin is changed to 50%
    CostSheet.Validate("Margin %", 50);
    CostSheet.Modify(true);

    // [THEN] Every line price is the unit cost plus 50%
    CostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    CostSheetLine.FindSet();
    repeat
      AssertDecimal(CostSheetLine."Unit Cost" * 1.5, CostSheetLine."Unit Price", 'Unit Price must include the new margin.');
      AssertDecimal(CostSheetLine."Unit Price" * CostSheetLine.Quantity, CostSheetLine."Line Amount", 'Line Amount must follow the unit price.');
    until CostSheetLine.Next() = 0;
  end;

  [Test]
  procedure FindOrAddLadderLineAddsCustomQuantity()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    // [GIVEN] A calculated cost sheet with die cutting and lamination, margin 20%
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateSpecification(PackagingSpecification, LibraryPackaging.CreateCustomer(20), true, true);
    LibraryPackaging.CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

    // [WHEN] A quantity outside the default ladder is requested
    CostEngineMgt.FindOrAddLadderLine(CostSheet, 2500, CostSheetLine);

    // [THEN] A calculated line is added for it
    AssertDecimal(0.24, CostSheetLine."Fixed Cost per Piece", 'Fixed Cost per Piece = 600 / 2500');
    AssertDecimal(0.6174, CostSheetLine."Unit Cost", 'Unit Cost = 0.3774 + 0.24');
    AssertDecimal(0.74088, CostSheetLine."Unit Price", 'Unit Price = 0.6174 x 1.2');
    CostSheetLine.Reset();
    CostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    Assert.AreEqual(6, CostSheetLine.Count(), 'The custom quantity must be added to the five default quantities.');
  end;

  [Test]
  procedure MissingPrintCostMatrixRaisesError()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    PrintCostMatrix: Record "CCO Print Cost Matrix";
  begin
    // [GIVEN] A Screen specification and no Screen rates in the print cost matrix
    LibraryPackaging.InitializeRates();
    LibraryPackaging.CreateSpecification(PackagingSpecification, '', false, false);
    PackagingSpecification."Print Process" := PackagingSpecification."Print Process"::Screen;
    PackagingSpecification.Modify(false);
    PrintCostMatrix.SetRange("Print Process", PrintCostMatrix."Print Process"::Screen);
    PrintCostMatrix.DeleteAll();

    // [WHEN] The cost sheet is calculated
    asserterror LibraryPackaging.CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

    // [THEN] The missing rates are reported
    Assert.ExpectedError('The print cost matrix has no rates for print process');
  end;

  [Test]
  procedure ReleasingSpecificationCreatesLinkedItem()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingSetup: Record "CCO Packaging Setup";
    Item: Record Item;
  begin
    // [GIVEN] An item number series in the packaging setup and a draft specification
    LibraryPackaging.InitializeRates();
    PackagingSetup.Get();
    PackagingSetup."Item Nos." := LibraryPackaging.CreateNoSeries();
    PackagingSetup."Item Template Code" := '';
    PackagingSetup.Modify(false);
    LibraryPackaging.CreateSpecification(PackagingSpecification, '', false, false);

    // [WHEN] The specification is released
    PackagingSpecification.Validate(Status, PackagingSpecification.Status::Released);
    PackagingSpecification.Modify(true);

    // [THEN] A make-to-order production item is created and linked both ways
    Assert.AreNotEqual('', PackagingSpecification."Item No.", 'The specification must be linked to the created item.');
    Item.Get(PackagingSpecification."Item No.");
    Assert.AreEqual(PackagingSpecification."No.", Item."CCO Packaging Spec. No.", 'The item must be linked to the specification.');
    Assert.AreEqual(PackagingSpecification.Description, Item.Description, 'The item must take the specification description.');
    Assert.AreEqual(Item."Replenishment System"::"Prod. Order", Item."Replenishment System", 'The item must be replenished by production orders.');
    Assert.AreEqual(Item."Manufacturing Policy"::"Make-to-Order", Item."Manufacturing Policy", 'The item must be made to order.');
  end;

  local procedure FindLine(CostSheet: Record "CCO Packaging Cost Sheet"; LadderQuantity: Decimal; var CostSheetLine: Record "CCO Packaging Cost Sheet Line")
  var
    LineMissingMsg: Label 'A line for quantity %1 must exist.', Comment = '%1 = Quantity', Locked = true;
  begin
    CostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    CostSheetLine.SetRange(Quantity, LadderQuantity);
    Assert.IsTrue(CostSheetLine.FindFirst(), StrSubstNo(LineMissingMsg, LadderQuantity));
  end;

  local procedure AssertDecimal(Expected: Decimal; Actual: Decimal; Message: Text)
  begin
    Assert.AreEqual(Expected, Actual, Message);
  end;
}
