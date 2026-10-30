codeunit 50203 "CCO Library - Packaging"
{
  /// <summary>
  /// Sets up the consumption settings and the Digital print rates used by the tests:
  /// ink 0.01 per m² per color at unit cost 20, glue 0.005 per piece at unit cost 4,
  /// film at 1 per m² plus 0.03 per piece, and Digital printing 0.02, setup 100, labor 0.05.
  /// </summary>
  procedure InitializeRates()
  var
    PackagingSetup: Record "CCO Packaging Setup";
  begin
    if not PackagingSetup.Get() then begin
      PackagingSetup.Init();
      PackagingSetup.Insert(false);
    end;
    PackagingSetup."Ink Item No." := CreateMaterialItem(0, 20);
    PackagingSetup."Ink Qty. per m² per Color" := 0.01;
    PackagingSetup."Glue Item No." := CreateMaterialItem(0, 4);
    PackagingSetup."Glue Qty. per Piece" := 0.005;
    PackagingSetup."Lamination Film Item No." := CreateMaterialItem(1, 0);
    PackagingSetup."Lamination Cost per Piece" := 0.03;
    PackagingSetup.Modify(false);

    SetPrintCost("CCO Print Process"::Digital, 0.02, 100, 0.05);
  end;

  /// <summary>
  /// Creates a Digital draft specification of 300 x 200 mm with 10% waste, 2 colors, a material cost of 2.5 per m², and a die cost of 500.
  /// </summary>
  procedure CreateSpecification(var PackagingSpecification: Record "CCO Packaging Specification"; CustomerNo: Code[20]; DieCut: Boolean; Lamination: Boolean)
  begin
    PackagingSpecification.Init();
    PackagingSpecification."No." := NewCode();
    PackagingSpecification.Description := 'Takeaway food box';
    PackagingSpecification."Customer No." := CustomerNo;
    PackagingSpecification."Width (mm)" := 200;
    PackagingSpecification."Height (mm)" := 300;
    PackagingSpecification."Length (mm)" := 400;
    PackagingSpecification."Waste %" := 10;
    PackagingSpecification."Material Code" := CreateMaterialItem(2.5, 0);
    PackagingSpecification."Print Process" := PackagingSpecification."Print Process"::Digital;
    PackagingSpecification."No. of Colors" := 2;
    PackagingSpecification.Lamination := Lamination;
    PackagingSpecification."Die Cut" := DieCut;
    PackagingSpecification."Die Cost" := 500;
    PackagingSpecification.Insert(false);
  end;

  /// <summary>
  /// Creates a cost sheet for the specification and calculates it.
  /// </summary>
  procedure CreateCalculatedCostSheet(PackagingSpecification: Record "CCO Packaging Specification"; var CostSheet: Record "CCO Packaging Cost Sheet")
  var
    CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";
  begin
    CostSheet.Init();
    CostSheet."No." := NewCode();
    CostSheet.Insert(true);
    CostSheet.Validate("Specification No.", PackagingSpecification."No.");
    CostSheet.Modify(true);
    CostEngineMgt.Calculate(CostSheet);
  end;

  /// <summary>
  /// Creates a minimal packaging material item with a cost per m² and a unit cost.
  /// </summary>
  procedure CreateMaterialItem(CostPerSquareMeter: Decimal; UnitCost: Decimal) ItemNo: Code[20]
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

  /// <summary>
  /// Creates a minimal customer with a packaging margin.
  /// </summary>
  procedure CreateCustomer(MarginPercent: Decimal) CustomerNo: Code[20]
  var
    Customer: Record Customer;
  begin
    Customer.Init();
    Customer."No." := NewCode();
    Customer."CCO Packaging Margin %" := MarginPercent;
    Customer.Insert(false);
    CustomerNo := Customer."No.";
  end;

  /// <summary>
  /// Creates an open number series with manual and default numbers.
  /// </summary>
  procedure CreateNoSeries() NoSeriesCode: Code[20]
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

  /// <summary>
  /// Creates or updates the print cost matrix rates of a print process.
  /// </summary>
  procedure SetPrintCost(PrintProcess: Enum "CCO Print Process"; PrintCostPerPiece: Decimal; MachineSetupCost: Decimal; LaborCostPerPiece: Decimal)
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

  /// <summary>
  /// Returns a unique code for test records.
  /// </summary>
  procedure NewCode() NewCodeValue: Code[20]
  begin
    NewCodeValue := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(NewCodeValue));
  end;
}
