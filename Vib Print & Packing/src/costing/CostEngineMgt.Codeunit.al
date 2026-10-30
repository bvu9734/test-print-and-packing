codeunit 50107 "CCO Cost Engine Mgt."
{
  var
    PrintProcessMissingErr: Label 'Specify a print process on packaging specification %1.', Comment = '%1 = Packaging Specification No.';
    PrintCostMissingErr: Label 'The print cost matrix has no rates for print process %1.', Comment = '%1 = Print Process';

  /// <summary>
  /// Creates a cost sheet for a packaging specification and calculates it with the default price ladder.
  /// </summary>
  /// <param name="SpecificationNo">The packaging specification to cost.</param>
  /// <param name="CostSheet">Returns the created and calculated cost sheet.</param>
  procedure CreateCostSheet(SpecificationNo: Code[20]; var CostSheet: Record "CCO Packaging Cost Sheet")
  begin
    CostSheet.Init();
    CostSheet.Insert(true);
    CostSheet.Validate("Specification No.", SpecificationNo);
    CostSheet.Modify(true);
    Calculate(CostSheet);
  end;

  /// <summary>
  /// Calculates the per-piece cost components and fixed costs of a cost sheet from its specification and the current rates,
  /// adds the default ladder quantities when the sheet has no lines, and recalculates all lines.
  /// </summary>
  /// <param name="CostSheet">The cost sheet to calculate. It is modified in the database.</param>
  procedure Calculate(var CostSheet: Record "CCO Packaging Cost Sheet")
  var
    PackagingSpecification: Record "CCO Packaging Specification";
    PackagingSetup: Record "CCO Packaging Setup";
    PrintCostMatrix: Record "CCO Print Cost Matrix";
  begin
    CostSheet.TestField("Specification No.");
    PackagingSpecification.Get(CostSheet."Specification No.");
    CheckSpecification(PackagingSpecification);

    if not PackagingSetup.Get() then
      PackagingSetup.Init();
    if not PrintCostMatrix.Get(PackagingSpecification."Print Process") then
      Error(PrintCostMissingErr, PackagingSpecification."Print Process");

    CopySpecification(CostSheet, PackagingSpecification);

    CostSheet."Base Area (m²)" := PackagingSpecification."Height (mm)" * PackagingSpecification."Width (mm)" / 1000000;
    CostSheet."Required Area (m²)" := CostSheet."Base Area (m²)" * (100 + PackagingSpecification."Waste %") / 100;
    CostSheet."Material Cost" := CalcMaterialCost(PackagingSpecification, CostSheet."Required Area (m²)");
    CostSheet."Ink Cost" := CalcInkCost(PackagingSpecification, PackagingSetup, CostSheet."Required Area (m²)");
    CostSheet."Glue Cost" := CalcGlueCost(PackagingSetup);
    CostSheet."Lamination Cost" := CalcLaminationCost(PackagingSpecification, PackagingSetup, CostSheet."Required Area (m²)");
    CostSheet."Printing Cost" := PrintCostMatrix."Print Cost per Piece";
    CostSheet."Labor Cost" := PrintCostMatrix."Labor Cost per Piece";
    CostSheet."Variable Unit Cost" :=
      CostSheet."Material Cost" + CostSheet."Ink Cost" + CostSheet."Glue Cost" + CostSheet."Lamination Cost" +
      CostSheet."Printing Cost" + CostSheet."Labor Cost";

    CostSheet."Machine Setup Cost" := PrintCostMatrix."Machine Setup Cost";
    CostSheet."Die Cost" := 0;
    if PackagingSpecification."Die Cut" then
      CostSheet."Die Cost" := PackagingSpecification."Die Cost";
    CostSheet."Fixed Cost" := CostSheet."Machine Setup Cost" + CostSheet."Die Cost";

    CostSheet."Calculation Date" := Today();
    CostSheet.Modify(true);

    InsertDefaultLines(CostSheet);
    CalculateLines(CostSheet);
  end;

  /// <summary>
  /// Calculates the fixed cost per piece, unit cost, unit price, and line amount of a cost sheet line. The line is not saved.
  /// </summary>
  /// <param name="CostSheet">The calculated cost sheet that the line belongs to.</param>
  /// <param name="CostSheetLine">The line to calculate.</param>
  procedure CalculateLine(CostSheet: Record "CCO Packaging Cost Sheet"; var CostSheetLine: Record "CCO Packaging Cost Sheet Line")
  begin
    if CostSheetLine.Quantity <= 0 then begin
      CostSheetLine."Fixed Cost per Piece" := 0;
      CostSheetLine."Unit Cost" := 0;
      CostSheetLine."Unit Price" := 0;
      CostSheetLine."Line Amount" := 0;
      exit;
    end;

    CostSheetLine."Fixed Cost per Piece" := CostSheet."Fixed Cost" / CostSheetLine.Quantity;
    CostSheetLine."Unit Cost" := CostSheet."Variable Unit Cost" + CostSheetLine."Fixed Cost per Piece";
    UpdateLinePrice(CostSheet, CostSheetLine);
  end;

  /// <summary>
  /// Recalculates the unit price and line amount of all lines of a cost sheet from its margin.
  /// </summary>
  /// <param name="CostSheet">The cost sheet whose margin is applied.</param>
  procedure UpdateLinePrices(CostSheet: Record "CCO Packaging Cost Sheet")
  var
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    CostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    if CostSheetLine.FindSet(true) then
      repeat
        UpdateLinePrice(CostSheet, CostSheetLine);
        CostSheetLine.Modify(true);
      until CostSheetLine.Next() = 0;
  end;

  /// <summary>
  /// Returns the quantities that a new cost sheet is calculated for.
  /// </summary>
  /// <returns>The default price ladder quantities.</returns>
  procedure GetDefaultQuantities() Quantities: List of [Decimal]
  begin
    Quantities.Add(100);
    Quantities.Add(500);
    Quantities.Add(1000);
    Quantities.Add(5000);
    Quantities.Add(10000);
  end;

  /// <summary>
  /// Finds the price ladder line for a quantity on a calculated cost sheet, or adds and calculates a new line when none exists.
  /// </summary>
  /// <param name="CostSheet">The calculated cost sheet.</param>
  /// <param name="LadderQuantity">The order quantity. Must be greater than zero.</param>
  /// <param name="CostSheetLine">Returns the found or added line.</param>
  procedure FindOrAddLadderLine(CostSheet: Record "CCO Packaging Cost Sheet"; LadderQuantity: Decimal; var CostSheetLine: Record "CCO Packaging Cost Sheet Line")
  var
    LastCostSheetLine: Record "CCO Packaging Cost Sheet Line";
    QuantityErr: Label 'Quantity must be greater than zero.';
  begin
    if LadderQuantity <= 0 then
      Error(QuantityErr);
    CostSheet.TestField("Calculation Date");

    CostSheetLine.Reset();
    CostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    CostSheetLine.SetRange(Quantity, LadderQuantity);
    if CostSheetLine.FindFirst() then
      exit;

    LastCostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    if LastCostSheetLine.FindLast() then;

    CostSheetLine.Init();
    CostSheetLine."Cost Sheet No." := CostSheet."No.";
    CostSheetLine."Line No." := LastCostSheetLine."Line No." + 10000;
    CostSheetLine.Quantity := LadderQuantity;
    CalculateLine(CostSheet, CostSheetLine);
    CostSheetLine.Insert(true);
  end;

  local procedure CheckSpecification(PackagingSpecification: Record "CCO Packaging Specification")
  begin
    PackagingSpecification.TestField("Material Code");
    PackagingSpecification.TestField("Width (mm)");
    PackagingSpecification.TestField("Height (mm)");
    if PackagingSpecification."Print Process" = PackagingSpecification."Print Process"::None then
      Error(PrintProcessMissingErr, PackagingSpecification."No.");
  end;

  local procedure CopySpecification(var CostSheet: Record "CCO Packaging Cost Sheet"; PackagingSpecification: Record "CCO Packaging Specification")
  begin
    CostSheet."Width (mm)" := PackagingSpecification."Width (mm)";
    CostSheet."Height (mm)" := PackagingSpecification."Height (mm)";
    CostSheet."Waste %" := PackagingSpecification."Waste %";
    CostSheet."Material Item No." := PackagingSpecification."Material Code";
    CostSheet."Print Process" := PackagingSpecification."Print Process";
    CostSheet."No. of Colors" := PackagingSpecification."No. of Colors";
    CostSheet.Lamination := PackagingSpecification.Lamination;
    CostSheet."Die Cut" := PackagingSpecification."Die Cut";
  end;

  local procedure CalcMaterialCost(PackagingSpecification: Record "CCO Packaging Specification"; RequiredArea: Decimal) MaterialCost: Decimal
  var
    MaterialItem: Record Item;
  begin
    MaterialItem.Get(PackagingSpecification."Material Code");
    MaterialCost := RequiredArea * MaterialItem."CCO Cost per m²";
  end;

  local procedure CalcInkCost(PackagingSpecification: Record "CCO Packaging Specification"; PackagingSetup: Record "CCO Packaging Setup"; RequiredArea: Decimal) InkCost: Decimal
  var
    InkItem: Record Item;
  begin
    if (PackagingSpecification."No. of Colors" = 0) or (PackagingSetup."Ink Qty. per m² per Color" = 0) then
      exit;

    PackagingSetup.TestField("Ink Item No.");
    InkItem.Get(PackagingSetup."Ink Item No.");
    InkCost := RequiredArea * PackagingSetup."Ink Qty. per m² per Color" * PackagingSpecification."No. of Colors" * InkItem."Unit Cost";
  end;

  local procedure CalcGlueCost(PackagingSetup: Record "CCO Packaging Setup") GlueCost: Decimal
  var
    GlueItem: Record Item;
  begin
    if PackagingSetup."Glue Qty. per Piece" = 0 then
      exit;

    PackagingSetup.TestField("Glue Item No.");
    GlueItem.Get(PackagingSetup."Glue Item No.");
    GlueCost := PackagingSetup."Glue Qty. per Piece" * GlueItem."Unit Cost";
  end;

  local procedure CalcLaminationCost(PackagingSpecification: Record "CCO Packaging Specification"; PackagingSetup: Record "CCO Packaging Setup"; RequiredArea: Decimal) LaminationCost: Decimal
  var
    FilmItem: Record Item;
  begin
    if not PackagingSpecification.Lamination then
      exit;

    PackagingSetup.TestField("Lamination Film Item No.");
    FilmItem.Get(PackagingSetup."Lamination Film Item No.");
    LaminationCost := RequiredArea * FilmItem."CCO Cost per m²" + PackagingSetup."Lamination Cost per Piece";
  end;

  local procedure InsertDefaultLines(CostSheet: Record "CCO Packaging Cost Sheet")
  var
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
    LadderQuantity: Decimal;
    LineNo: Integer;
  begin
    CostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    if not CostSheetLine.IsEmpty() then
      exit;

    foreach LadderQuantity in GetDefaultQuantities() do begin
      LineNo += 10000;
      CostSheetLine.Init();
      CostSheetLine."Cost Sheet No." := CostSheet."No.";
      CostSheetLine."Line No." := LineNo;
      CostSheetLine.Quantity := LadderQuantity;
      CostSheetLine.Insert(true);
    end;
  end;

  local procedure CalculateLines(CostSheet: Record "CCO Packaging Cost Sheet")
  var
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    CostSheetLine.SetRange("Cost Sheet No.", CostSheet."No.");
    if CostSheetLine.FindSet(true) then
      repeat
        CalculateLine(CostSheet, CostSheetLine);
        CostSheetLine.Modify(true);
      until CostSheetLine.Next() = 0;
  end;

  local procedure UpdateLinePrice(CostSheet: Record "CCO Packaging Cost Sheet"; var CostSheetLine: Record "CCO Packaging Cost Sheet Line")
  begin
    CostSheetLine."Unit Price" := CostSheetLine."Unit Cost" * (100 + CostSheet."Margin %") / 100;
    CostSheetLine."Line Amount" := CostSheetLine."Unit Price" * CostSheetLine.Quantity;
  end;
}
