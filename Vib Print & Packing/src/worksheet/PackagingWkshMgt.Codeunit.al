codeunit 50136 "CCO Packaging Wksh. Mgt."
{
  var
    CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";
    NothingToCreateErr: Label 'There are no accepted lines in packaging worksheet %1.', Comment = '%1 = Worksheet Name';
    EnterQuantityErr: Label 'Enter a quantity for specification %1 on line %2 of packaging worksheet %3.', Comment = '%1 = Packaging Specification No., %2 = Line No., %3 = Worksheet Name';
    SpecificationNotReleasedErr: Label 'Packaging specification %1 must be released before it can be quoted.', Comment = '%1 = Packaging Specification No.';
    DefaultWorksheetNameTok: Label 'DEFAULT', Locked = true, MaxLength = 10;
    DefaultWorksheetDescriptionLbl: Label 'Default packaging worksheet';

  /// <summary>
  /// Calculates the price of a worksheet line from its cost sheet. Creates the cost sheet when the customer,
  /// specification, and quantity are filled in and no cost sheet exists yet. The line is not saved.
  /// </summary>
  /// <param name="PackagingWkshLine">The worksheet line to calculate.</param>
  procedure CalculateLine(var PackagingWkshLine: Record "CCO Packaging Wksh. Line")
  var
    CostSheet: Record "CCO Packaging Cost Sheet";
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    if (PackagingWkshLine."Customer No." = '') or (PackagingWkshLine."Specification No." = '') or (PackagingWkshLine.Quantity <= 0) then begin
      ClearPrice(PackagingWkshLine);
      exit;
    end;

    if not CostSheet.Get(PackagingWkshLine."Cost Sheet No.") then begin
      CostEngineMgt.CreateCostSheet(PackagingWkshLine."Specification No.", CostSheet);
      if CostSheet."Customer No." <> PackagingWkshLine."Customer No." then begin
        CostSheet.Validate("Customer No.", PackagingWkshLine."Customer No.");
        CostSheet.Modify(true);
      end;
      PackagingWkshLine."Cost Sheet No." := CostSheet."No.";
      PackagingWkshLine."Margin %" := CostSheet."Margin %";
    end else
      if CostSheet."Margin %" <> PackagingWkshLine."Margin %" then begin
        CostSheet.Validate("Margin %", PackagingWkshLine."Margin %");
        CostSheet.Modify(true);
      end;

    CostEngineMgt.FindOrAddLadderLine(CostSheet, PackagingWkshLine.Quantity, CostSheetLine);
    PackagingWkshLine."Unit Price (LCY)" := CostSheetLine."Unit Price";
    PackagingWkshLine."Line Amount (LCY)" := CostSheetLine."Line Amount";
  end;

  /// <summary>
  /// Deletes the cost sheet of a worksheet line unless a sales quote was created from it, and clears the price of the line. The line is not saved.
  /// </summary>
  /// <param name="PackagingWkshLine">The worksheet line.</param>
  procedure DeleteCostSheet(var PackagingWkshLine: Record "CCO Packaging Wksh. Line")
  var
    CostSheet: Record "CCO Packaging Cost Sheet";
  begin
    if PackagingWkshLine."Cost Sheet No." <> '' then
      if CostSheet.Get(PackagingWkshLine."Cost Sheet No.") then
        if CostSheet."Sales Quote No." = '' then
          CostSheet.Delete(true);

    PackagingWkshLine."Cost Sheet No." := '';
    PackagingWkshLine."Margin %" := 0;
    ClearPrice(PackagingWkshLine);
  end;

  /// <summary>
  /// Adds one worksheet line for each specification. The customer is taken from the specification; the quantity must be entered on the line.
  /// </summary>
  /// <param name="WorksheetName">The worksheet batch to add the lines to.</param>
  /// <param name="PackagingSpecification">The selected specifications.</param>
  procedure AddSpecifications(WorksheetName: Code[10]; var PackagingSpecification: Record "CCO Packaging Specification")
  var
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    LineNo: Integer;
  begin
    if not PackagingSpecification.FindSet() then
      exit;

    PackagingWkshLine.SetRange("Worksheet Name", WorksheetName);
    if PackagingWkshLine.FindLast() then
      LineNo := PackagingWkshLine."Line No.";

    repeat
      LineNo += 10000;
      PackagingWkshLine.Init();
      PackagingWkshLine."Worksheet Name" := WorksheetName;
      PackagingWkshLine."Line No." := LineNo;
      PackagingWkshLine.Validate("Specification No.", PackagingSpecification."No.");
      PackagingWkshLine.Insert(true);
    until PackagingSpecification.Next() = 0;
  end;

  /// <summary>
  /// Recalculates the cost sheets and prices of all lines of a worksheet batch with the current specifications and rates. Line margins are kept.
  /// </summary>
  /// <param name="WorksheetName">The worksheet batch.</param>
  procedure RecalculateWorksheet(WorksheetName: Code[10])
  var
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    CostSheet: Record "CCO Packaging Cost Sheet";
  begin
    PackagingWkshLine.SetRange("Worksheet Name", WorksheetName);
    if PackagingWkshLine.FindSet(true) then
      repeat
        if CostSheet.Get(PackagingWkshLine."Cost Sheet No.") then
          CostEngineMgt.Calculate(CostSheet);
        CalculateLine(PackagingWkshLine);
        PackagingWkshLine.Modify(true);
      until PackagingWkshLine.Next() = 0;
  end;

  /// <summary>
  /// Creates one sales quote per customer from the accepted lines of a worksheet batch, and deletes the processed lines.
  /// The cost sheets are kept and linked to the quotes.
  /// </summary>
  /// <param name="WorksheetName">The worksheet batch.</param>
  /// <returns>The numbers of the created sales quotes.</returns>
  procedure CreateSalesQuotes(WorksheetName: Code[10]) SalesQuoteNos: List of [Code[20]]
  var
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
    CostSheet: Record "CCO Packaging Cost Sheet";
    SalesHeader: Record "Sales Header";
    PackagingQuoteMgt: Codeunit "CCO Packaging Quote Mgt.";
    QuotedCustomerNo: Code[20];
  begin
    PackagingWkshLine.SetCurrentKey("Worksheet Name", "Customer No.");
    PackagingWkshLine.SetRange("Worksheet Name", WorksheetName);
    PackagingWkshLine.SetRange(Accept, true);
    if PackagingWkshLine.IsEmpty() then
      Error(NothingToCreateErr, WorksheetName);

    PackagingWkshLine.FindSet(true);
    QuotedCustomerNo := '';
    repeat
      CheckLine(PackagingWkshLine);
      if PackagingWkshLine."Cost Sheet No." = '' then begin
        CalculateLine(PackagingWkshLine);
        PackagingWkshLine.Modify(true);
      end;

      if (SalesQuoteNos.Count() = 0) or (PackagingWkshLine."Customer No." <> QuotedCustomerNo) then begin
        PackagingQuoteMgt.CreateQuoteHeader(PackagingWkshLine."Customer No.", SalesHeader);
        SalesQuoteNos.Add(SalesHeader."No.");
        QuotedCustomerNo := PackagingWkshLine."Customer No.";
      end;

      CostSheet.Get(PackagingWkshLine."Cost Sheet No.");
      PackagingQuoteMgt.AddQuoteLine(SalesHeader, CostSheet, PackagingWkshLine.Quantity);
    until PackagingWkshLine.Next() = 0;

    PackagingWkshLine.DeleteAll(true);
  end;

  /// <summary>
  /// Returns a valid worksheet batch name. Creates a default batch when no batch exists.
  /// </summary>
  /// <param name="WorksheetName">The preferred batch name. It is kept when the batch exists.</param>
  /// <returns>The batch name to open.</returns>
  procedure GetWorksheetName(WorksheetName: Code[10]) ValidWorksheetName: Code[10]
  var
    PackagingWkshName: Record "CCO Packaging Wksh. Name";
  begin
    if (WorksheetName <> '') and PackagingWkshName.Get(WorksheetName) then begin
      ValidWorksheetName := WorksheetName;
      exit;
    end;

    if not PackagingWkshName.FindFirst() then begin
      PackagingWkshName.Init();
      PackagingWkshName.Name := DefaultWorksheetNameTok;
      PackagingWkshName.Description := DefaultWorksheetDescriptionLbl;
      PackagingWkshName.Insert(true);
    end;
    ValidWorksheetName := PackagingWkshName.Name;
  end;

  local procedure CheckLine(PackagingWkshLine: Record "CCO Packaging Wksh. Line")
  var
    PackagingSpecification: Record "CCO Packaging Specification";
  begin
    PackagingWkshLine.TestField("Customer No.");
    PackagingWkshLine.TestField("Specification No.");
    if PackagingWkshLine.Quantity <= 0 then
      Error(EnterQuantityErr, PackagingWkshLine."Specification No.", PackagingWkshLine."Line No.", PackagingWkshLine."Worksheet Name");

    PackagingSpecification.Get(PackagingWkshLine."Specification No.");
    if (PackagingSpecification.Status <> PackagingSpecification.Status::Released) or (PackagingSpecification."Item No." = '') then
      Error(SpecificationNotReleasedErr, PackagingSpecification."No.");
  end;

  local procedure ClearPrice(var PackagingWkshLine: Record "CCO Packaging Wksh. Line")
  begin
    PackagingWkshLine."Unit Price (LCY)" := 0;
    PackagingWkshLine."Line Amount (LCY)" := 0;
  end;
}
