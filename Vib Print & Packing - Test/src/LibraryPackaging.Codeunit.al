codeunit 50203 "CCO Library - Packaging"
{
  /// <summary>
  /// Sets up the consumption settings and the Digital print rates used by the tests:
  /// ink 0.01 per m² per color at unit cost 20, glue 0.005 per piece at unit cost 4,
  /// film at 1 per m² plus 0.03 per piece, and Digital printing 0.02, setup 100, labor 0.05.
  /// Ensures that Packaging Setup exists and has number series for specifications, cost sheets, and items.
  /// </summary>
  procedure InitializeRates()
  var
    PackagingSetup: Record "CCO Packaging Setup";
  begin
    if not PackagingSetup.Get() then begin
      PackagingSetup.Init();
      PackagingSetup.Insert(false);
    end;
    if PackagingSetup."Packaging Spec. Nos." = '' then
      PackagingSetup."Packaging Spec. Nos." := CreateNoSeries('PPTSPEC00001');
    if PackagingSetup."Cost Sheet Nos." = '' then
      PackagingSetup."Cost Sheet Nos." := CreateNoSeries('PPTCS00001');
    if PackagingSetup."Item Nos." = '' then
      PackagingSetup."Item Nos." := CreateNoSeries('PPTITEM00001');
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
  /// Creates a packaging material item, with a base unit of measure and posting groups, with a cost per m² and a unit cost.
  /// </summary>
  procedure CreateMaterialItem(CostPerSquareMeter: Decimal; UnitCost: Decimal) ItemNo: Code[20]
  var
    Item: Record Item;
    LibraryInventory: Codeunit "Library - Inventory";
  begin
    LibraryInventory.CreateItem(Item);
    Item."CCO Packaging Material Type" := Item."CCO Packaging Material Type"::Paper;
    Item."CCO Cost per m²" := CostPerSquareMeter;
    Item."Unit Cost" := UnitCost;
    Item.Modify(false);
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
  begin
    NoSeriesCode := CreateNoSeries('PPTEST00001');
  end;

  /// <summary>
  /// Creates an open number series with manual and default numbers that starts with the given number.
  /// </summary>
  procedure CreateNoSeries(StartingNo: Code[20]) NoSeriesCode: Code[20]
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
    NoSeriesLine."Starting No." := StartingNo;
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

  /// <summary>
  /// Creates a customer that can be used on sales documents, with a packaging margin.
  /// </summary>
  procedure CreateSalesCustomer(MarginPercent: Decimal) CustomerNo: Code[20]
  var
    Customer: Record Customer;
    LibrarySales: Codeunit "Library - Sales";
  begin
    LibrarySales.CreateCustomer(Customer);
    Customer."CCO Packaging Margin %" := MarginPercent;
    Customer.Modify(false);
    CustomerNo := Customer."No.";
  end;

  /// <summary>
  /// Creates a released specification (see CreateSpecification) with a sellable finished item.
  /// </summary>
  procedure CreateReleasedSpecification(var PackagingSpecification: Record "CCO Packaging Specification"; CustomerNo: Code[20]; DieCut: Boolean; Lamination: Boolean)
  var
    Item: Record Item;
    LibraryInventory: Codeunit "Library - Inventory";
  begin
    LibraryInventory.CreateItem(Item);
    CreateSpecification(PackagingSpecification, CustomerNo, DieCut, Lamination);
    PackagingSpecification.Status := PackagingSpecification.Status::Released;
    PackagingSpecification."Item No." := Item."No.";
    PackagingSpecification.Modify(false);
  end;

  /// <summary>
  /// Creates a packaging worksheet batch.
  /// </summary>
  procedure CreateWorksheetName() WorksheetName: Code[10]
  var
    PackagingWkshName: Record "CCO Packaging Wksh. Name";
  begin
    PackagingWkshName.Init();
    PackagingWkshName.Name := CopyStr(NewCode(), 1, MaxStrLen(PackagingWkshName.Name));
    PackagingWkshName.Insert(true);
    WorksheetName := PackagingWkshName.Name;
  end;

  /// <summary>
  /// Creates a routing template with four operations on new work centers:
  /// 10 printing (only if printed), 20 laminating (only if laminated), 30 die cutting (only if die cut), and 40 packing (always).
  /// </summary>
  procedure CreateRoutingTemplate() TemplateCode: Code[20]
  var
    RoutingTemplate: Record "CCO Routing Template";
  begin
    RoutingTemplate.Init();
    RoutingTemplate."Code" := NewCode();
    RoutingTemplate.Description := 'Test routing template';
    RoutingTemplate.Insert(true);
    TemplateCode := RoutingTemplate."Code";

    AddTemplateOperation(TemplateCode, '10', 30, 0.02, "CCO Operation Condition"::Printing);
    AddTemplateOperation(TemplateCode, '20', 15, 0.01, "CCO Operation Condition"::Lamination);
    AddTemplateOperation(TemplateCode, '30', 45, 0.015, "CCO Operation Condition"::"Die Cut");
    AddTemplateOperation(TemplateCode, '40', 5, 0.005, "CCO Operation Condition"::Always);
  end;

  local procedure AddTemplateOperation(TemplateCode: Code[20]; OperationNo: Code[10]; SetupTime: Decimal; RunTime: Decimal; Condition: Enum "CCO Operation Condition")
  var
    RoutingTemplateLine: Record "CCO Routing Template Line";
    WorkCenter: Record "Work Center";
    LibraryManufacturing: Codeunit "Library - Manufacturing";
  begin
    LibraryManufacturing.CreateWorkCenter(WorkCenter);
    RoutingTemplateLine.Init();
    RoutingTemplateLine."Template Code" := TemplateCode;
    RoutingTemplateLine."Operation No." := OperationNo;
    RoutingTemplateLine.Validate("Work Center No.", WorkCenter."No.");
    RoutingTemplateLine."Setup Time" := SetupTime;
    RoutingTemplateLine."Run Time" := RunTime;
    RoutingTemplateLine.Condition := Condition;
    RoutingTemplateLine.Insert(true);
  end;
}
