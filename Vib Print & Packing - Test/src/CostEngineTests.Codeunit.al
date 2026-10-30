codeunit 50200 "CCO Cost Engine Tests"
{
  Subtype = Test;
  TestPermissions = Disabled;

  var
    Assert: Codeunit "Library Assert";
    CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";

  [Test]
  procedure CalculateAppliesAgreedFormula()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    // [GIVEN] A Digital specification of 300 x 200 mm with 10% waste, 2 colors, lamination, and a die cost of 500
    Initialize();
    CreateSpecification(PackagingSpecification, CreateCustomer(20), true, true);

    // [WHEN] The cost sheet is calculated
    CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

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
    Initialize();
    CreateSpecification(PackagingSpecification, '', false, false);

    // [WHEN] A new cost sheet is calculated
    CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

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
    Initialize();
    CreateSpecification(PackagingSpecification, '', false, false);

    // [WHEN] The cost sheet is calculated
    CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

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
    Initialize();
    CreateSpecification(PackagingSpecification, CreateCustomer(25), false, false);

    // [WHEN] The specification is selected on a cost sheet
    CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

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
    Initialize();
    CreateSpecification(PackagingSpecification, '', false, false);
    CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

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
  procedure MissingPrintCostMatrixRaisesError()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    CostSheet: Record "CCO Packaging Cost Sheet";
    PrintCostMatrix: Record "CCO Print Cost Matrix";
  begin
    // [GIVEN] A Screen specification and no Screen rates in the print cost matrix
    Initialize();
    CreateSpecification(PackagingSpecification, '', false, false);
    PackagingSpecification."Print Process" := PackagingSpecification."Print Process"::Screen;
    PackagingSpecification.Modify(false);
    PrintCostMatrix.SetRange("Print Process", PrintCostMatrix."Print Process"::Screen);
    PrintCostMatrix.DeleteAll();

    // [WHEN] The cost sheet is calculated
    asserterror CreateCalculatedCostSheet(PackagingSpecification, CostSheet);

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
    Initialize();
    PackagingSetup.Get();
    PackagingSetup."Item Nos." := CreateNoSeries();
    PackagingSetup."Item Template Code" := '';
    PackagingSetup.Modify(false);
    CreateSpecification(PackagingSpecification, '', false, false);

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

  local procedure Initialize()
  var
    PackagingSetup: Record "CCO Packaging Setup";
  begin
    if not PackagingSetup.Get() then begin
      PackagingSetup.Init();
      PackagingSetup.Insert(false);
    end;
    PackagingSetup."Ink Item No." := CreateItem(0, 20);
    PackagingSetup."Ink Qty. per m² per Color" := 0.01;
    PackagingSetup."Glue Item No." := CreateItem(0, 4);
    PackagingSetup."Glue Qty. per Piece" := 0.005;
    PackagingSetup."Lamination Film Item No." := CreateItem(1, 0);
    PackagingSetup."Lamination Cost per Piece" := 0.03;
    PackagingSetup.Modify(false);

    SetPrintCost("CCO Print Process"::Digital, 0.02, 100, 0.05);
  end;

  local procedure CreateSpecification(var PackagingSpecification: Record "CCO Packaging Specification"; CustomerNo: Code[20]; DieCut: Boolean; Lamination: Boolean)
  begin
    PackagingSpecification.Init();
    PackagingSpecification."No." := NewCode();
    PackagingSpecification.Description := 'Pizza box';
    PackagingSpecification."Customer No." := CustomerNo;
    PackagingSpecification."Width (mm)" := 200;
    PackagingSpecification."Height (mm)" := 300;
    PackagingSpecification."Length (mm)" := 400;
    PackagingSpecification."Waste %" := 10;
    PackagingSpecification."Material Code" := CreateItem(2.5, 0);
    PackagingSpecification."Print Process" := PackagingSpecification."Print Process"::Digital;
    PackagingSpecification."No. of Colors" := 2;
    PackagingSpecification.Lamination := Lamination;
    PackagingSpecification."Die Cut" := DieCut;
    PackagingSpecification."Die Cost" := 500;
    PackagingSpecification.Insert(false);
  end;

  local procedure CreateCalculatedCostSheet(PackagingSpecification: Record "CCO Packaging Specification"; var CostSheet: Record "CCO Packaging Cost Sheet")
  begin
    CostSheet.Init();
    CostSheet."No." := NewCode();
    CostSheet.Insert(true);
    CostSheet.Validate("Specification No.", PackagingSpecification."No.");
    CostSheet.Modify(true);
    CostEngineMgt.Calculate(CostSheet);
  end;

  local procedure CreateItem(CostPerSquareMeter: Decimal; UnitCost: Decimal) ItemNo: Code[20]
  var
    Item: Record Item;
  begin
    Item.Init();
    Item."No." := NewCode();
    Item."CCO Packaging Material Type" := Item."CCO Packaging Material Type"::Paper;
    Item."CCO Cost per m²" := CostPerSquareMeter;
    Item."Unit Cost" := UnitCost;
    Item.Insert(false);
    ItemNo := Item."No.";
  end;

  local procedure CreateCustomer(MarginPercent: Decimal) CustomerNo: Code[20]
  var
    Customer: Record Customer;
  begin
    Customer.Init();
    Customer."No." := NewCode();
    Customer."CCO Packaging Margin %" := MarginPercent;
    Customer.Insert(false);
    CustomerNo := Customer."No.";
  end;

  local procedure CreateNoSeries() NoSeriesCode: Code[20]
  var
    NoSeries: Record "No. Series";
    NoSeriesLine: Record "No. Series Line";
  begin
    NoSeries.Init();
    NoSeries.Code := NewCode();
    NoSeries."Default Nos." := true;
    NoSeries."Manual Nos." := true;
    NoSeries.Insert(false);

    NoSeriesLine.Init();
    NoSeriesLine."Series Code" := NoSeries.Code;
    NoSeriesLine."Line No." := 10000;
    NoSeriesLine."Starting No." := 'PPTEST00001';
    NoSeriesLine.Open := true;
    NoSeriesLine.Insert(false);
    NoSeriesCode := NoSeries.Code;
  end;

  local procedure SetPrintCost(PrintProcess: Enum "CCO Print Process"; PrintCostPerPiece: Decimal; MachineSetupCost: Decimal; LaborCostPerPiece: Decimal)
  var
    PrintCostMatrix: Record "CCO Print Cost Matrix";
  begin
    if not PrintCostMatrix.Get(PrintProcess) then begin
      PrintCostMatrix.Init();
      PrintCostMatrix."Print Process" := PrintProcess;
      PrintCostMatrix.Insert(true);
    end;
    PrintCostMatrix."Print Cost per Piece" := PrintCostPerPiece;
    PrintCostMatrix."Machine Setup Cost" := MachineSetupCost;
    PrintCostMatrix."Labor Cost per Piece" := LaborCostPerPiece;
    PrintCostMatrix.Modify(false);
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

  local procedure NewCode() NewCodeValue: Code[20]
  begin
    NewCodeValue := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(NewCodeValue));
  end;
}
