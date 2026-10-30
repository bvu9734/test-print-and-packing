codeunit 50139 "CCO Packaging Demo Data"
{
  var
    Summary: TextBuilder;
    ReferenceGenProdPostingGroup: Code[20];
    ReferenceVATProdPostingGroup: Code[20];
    ReferenceInventoryPostingGroup: Code[20];
    SpecNosTok: Label 'PP-SPEC', Locked = true;
    CostSheetNosTok: Label 'PP-COST', Locked = true;
    ItemNosTok: Label 'PP-ITEM', Locked = true;
    ItemTemplateTok: Label 'PACKAGING', Locked = true;
    PaperItemTok: Label 'PP-PAPER', Locked = true;
    CorrugatedItemTok: Label 'PP-CORRUGATED', Locked = true;
    InkItemTok: Label 'PP-INK', Locked = true;
    GlueItemTok: Label 'PP-GLUE', Locked = true;
    FoilItemTok: Label 'PP-FOIL', Locked = true;
    FilmItemTok: Label 'PP-FILM', Locked = true;
    PizzaCustomerTok: Label 'PP-PIZZA', Locked = true;
    BurgerCustomerTok: Label 'PP-BURGER', Locked = true;
    BoxSpecTok: Label 'PP-DEMO-BOX', Locked = true;
    InsertSpecTok: Label 'PP-DEMO-INSERT', Locked = true;
    LabelSpecTok: Label 'PP-DEMO-LABEL', Locked = true;
    GenericSpecTok: Label 'PP-DEMO-GENERIC', Locked = true;
    DraftSpecTok: Label 'PP-DEMO-DRAFT', Locked = true;
    WorksheetNameTok: Label 'DEMO', Locked = true, MaxLength = 10;
    SquareMeterTok: Label 'M2', Locked = true;
    LiterTok: Label 'L', Locked = true;
    KilogramTok: Label 'KG', Locked = true;
    PieceTok: Label 'PCS', Locked = true;
    SummaryLineTxt: Label '%1: %2 created, %3 already existed.', Comment = '%1 = Area, %2 = Number of created records, %3 = Number of existing records';
    NoPostingGroupsTxt: Label 'No item with posting groups was found. The demo items have no posting groups, so they cannot be posted or quoted until you add them.';
    NoCustomerPostingSetupTxt: Label 'No customer with posting groups was found. The demo customers have no posting groups, so quotes may fail until you add them.';
    NoShopCalendarTxt: Label 'No shop calendar was found. The demo work centers have no shop calendar; add one before you schedule production orders.';
    BoxTemplateTok: Label 'BOX_STD', Locked = true;
    LabelTemplateTok: Label 'LABEL_STD', Locked = true;
    DigitalTemplateTok: Label 'DIGITAL_STD', Locked = true;
    PrintWorkCenterTok: Label 'PP-PRINT', Locked = true;
    LaminateWorkCenterTok: Label 'PP-LAMINATE', Locked = true;
    DieCutWorkCenterTok: Label 'PP-DIECUT', Locked = true;
    FoldWorkCenterTok: Label 'PP-FOLD', Locked = true;
    GlueWorkCenterTok: Label 'PP-GLUE', Locked = true;
    PackWorkCenterTok: Label 'PP-PACK', Locked = true;
    WorkCenterGroupTok: Label 'PP', Locked = true;
    CapacityUnitTok: Label 'PP-MIN', Locked = true;

  /// <summary>
  /// Creates the master data needed to test the packaging feature manually: number series, Packaging Setup,
  /// Print Cost Matrix, an item template, one material item per material type with random values, work centers,
  /// routing templates, demo customers, sample specifications, and a worksheet batch with lines. Existing demo records are kept.
  /// </summary>
  /// <returns>A summary of the created and existing records.</returns>
  procedure Generate() GenerationSummary: Text
  begin
    Clear(Summary);
    Randomize();
    FindReferencePostingGroups();

    CreateNumberSeries();
    CreateUnitsOfMeasure();
    CreateItemTemplate();
    CreateMaterialItems();
    CreateWorkCenters();
    CreateRoutingTemplates();
    UpdatePackagingSetup();
    CreatePrintCostMatrix();
    CreateCustomers();
    CreateSpecifications();
    CreateWorksheet();

    GenerationSummary := Summary.ToText();
  end;

  local procedure CreateWorkCenters()
  var
    ReferenceWorkCenter: Record "Work Center";
    ShopCalendar: Record "Shop Calendar";
    WorkCenterGroupCode: Code[10];
    CapacityUnitCode: Code[10];
    ShopCalendarCode: Code[10];
    Created: Integer;
    Existing: Integer;
  begin
    ReferenceWorkCenter.SetFilter("Work Center Group Code", '<>%1', '');
    ReferenceWorkCenter.SetFilter("Unit of Measure Code", '<>%1', '');
    if ReferenceWorkCenter.FindFirst() then begin
      WorkCenterGroupCode := ReferenceWorkCenter."Work Center Group Code";
      CapacityUnitCode := ReferenceWorkCenter."Unit of Measure Code";
      ShopCalendarCode := ReferenceWorkCenter."Shop Calendar Code";
    end else begin
      WorkCenterGroupCode := CreateWorkCenterGroup();
      CapacityUnitCode := CreateCapacityUnitOfMeasure();
    end;
    if (ShopCalendarCode = '') and ShopCalendar.FindFirst() then
      ShopCalendarCode := ShopCalendar.Code;
    if ShopCalendarCode = '' then
      Summary.AppendLine(NoShopCalendarTxt);

    CountResult(CreateWorkCenter(PrintWorkCenterTok, 'Printing (demo)', WorkCenterGroupCode, CapacityUnitCode, ShopCalendarCode), Created, Existing);
    CountResult(CreateWorkCenter(LaminateWorkCenterTok, 'Laminating (demo)', WorkCenterGroupCode, CapacityUnitCode, ShopCalendarCode), Created, Existing);
    CountResult(CreateWorkCenter(DieCutWorkCenterTok, 'Die cutting (demo)', WorkCenterGroupCode, CapacityUnitCode, ShopCalendarCode), Created, Existing);
    CountResult(CreateWorkCenter(FoldWorkCenterTok, 'Folding (demo)', WorkCenterGroupCode, CapacityUnitCode, ShopCalendarCode), Created, Existing);
    CountResult(CreateWorkCenter(GlueWorkCenterTok, 'Gluing (demo)', WorkCenterGroupCode, CapacityUnitCode, ShopCalendarCode), Created, Existing);
    CountResult(CreateWorkCenter(PackWorkCenterTok, 'Packing (demo)', WorkCenterGroupCode, CapacityUnitCode, ShopCalendarCode), Created, Existing);
    AddSummaryLine('Work centers', Created, Existing);
  end;

  local procedure CreateWorkCenterGroup() WorkCenterGroupCode: Code[10]
  var
    WorkCenterGroup: Record "Work Center Group";
  begin
    WorkCenterGroupCode := WorkCenterGroupTok;
    if WorkCenterGroup.Get(WorkCenterGroupCode) then
      exit;
    WorkCenterGroup.Init();
    WorkCenterGroup.Code := WorkCenterGroupCode;
    WorkCenterGroup.Name := 'Packaging (demo)';
    WorkCenterGroup.Insert(true);
  end;

  local procedure CreateCapacityUnitOfMeasure() CapacityUnitCode: Code[10]
  var
    CapacityUnitOfMeasure: Record "Capacity Unit of Measure";
  begin
    CapacityUnitCode := CapacityUnitTok;
    if CapacityUnitOfMeasure.Get(CapacityUnitCode) then
      exit;
    CapacityUnitOfMeasure.Init();
    CapacityUnitOfMeasure.Code := CapacityUnitCode;
    CapacityUnitOfMeasure.Description := 'Minutes (demo)';
    CapacityUnitOfMeasure.Type := CapacityUnitOfMeasure.Type::Minutes;
    CapacityUnitOfMeasure.Insert(true);
  end;

  local procedure CreateWorkCenter(WorkCenterNo: Code[20]; WorkCenterName: Text[100]; WorkCenterGroupCode: Code[10]; CapacityUnitCode: Code[10]; ShopCalendarCode: Code[10]) Created: Boolean
  var
    WorkCenter: Record "Work Center";
  begin
    if WorkCenter.Get(WorkCenterNo) then
      exit;

    WorkCenter.Init();
    WorkCenter."No." := WorkCenterNo;
    WorkCenter.Insert(true);
    WorkCenter.Validate(Name, WorkCenterName);
    WorkCenter.Validate("Work Center Group Code", WorkCenterGroupCode);
    WorkCenter.Validate("Unit of Measure Code", CapacityUnitCode);
    if ShopCalendarCode <> '' then
      WorkCenter.Validate("Shop Calendar Code", ShopCalendarCode);
    if ReferenceGenProdPostingGroup <> '' then
      WorkCenter.Validate("Gen. Prod. Posting Group", ReferenceGenProdPostingGroup);
    WorkCenter.Validate(Capacity, 1);
    WorkCenter.Validate(Efficiency, 100);
    WorkCenter.Validate("Direct Unit Cost", RandomDecimal(0.3, 1.5, 0.05));
    WorkCenter.Modify(true);
    Created := true;
  end;

  local procedure CreateRoutingTemplates()
  var
    Created: Integer;
    Existing: Integer;
  begin
    if CreateRoutingTemplate(BoxTemplateTok, 'Standard box: print, laminate, die cut, fold, glue, pack') then begin
      AddTemplateOperation(BoxTemplateTok, '10', PrintWorkCenterTok, 30, 0.02, "CCO Operation Condition"::Printing);
      AddTemplateOperation(BoxTemplateTok, '20', LaminateWorkCenterTok, 15, 0.01, "CCO Operation Condition"::Lamination);
      AddTemplateOperation(BoxTemplateTok, '30', DieCutWorkCenterTok, 45, 0.015, "CCO Operation Condition"::"Die Cut");
      AddTemplateOperation(BoxTemplateTok, '40', FoldWorkCenterTok, 10, 0.01, "CCO Operation Condition"::Always);
      AddTemplateOperation(BoxTemplateTok, '50', GlueWorkCenterTok, 10, 0.01, "CCO Operation Condition"::Always);
      AddTemplateOperation(BoxTemplateTok, '60', PackWorkCenterTok, 5, 0.005, "CCO Operation Condition"::Always);
      Created += 1;
    end else
      Existing += 1;

    if CreateRoutingTemplate(LabelTemplateTok, 'Standard label: print, laminate, die cut, pack') then begin
      AddTemplateOperation(LabelTemplateTok, '10', PrintWorkCenterTok, 30, 0.01, "CCO Operation Condition"::Printing);
      AddTemplateOperation(LabelTemplateTok, '20', LaminateWorkCenterTok, 15, 0.005, "CCO Operation Condition"::Lamination);
      AddTemplateOperation(LabelTemplateTok, '30', DieCutWorkCenterTok, 30, 0.005, "CCO Operation Condition"::"Die Cut");
      AddTemplateOperation(LabelTemplateTok, '40', PackWorkCenterTok, 5, 0.002, "CCO Operation Condition"::Always);
      Created += 1;
    end else
      Existing += 1;

    if CreateRoutingTemplate(DigitalTemplateTok, 'Digital print: print, laminate, die cut, pack') then begin
      AddTemplateOperation(DigitalTemplateTok, '10', PrintWorkCenterTok, 10, 0.03, "CCO Operation Condition"::Printing);
      AddTemplateOperation(DigitalTemplateTok, '20', LaminateWorkCenterTok, 15, 0.01, "CCO Operation Condition"::Lamination);
      AddTemplateOperation(DigitalTemplateTok, '30', DieCutWorkCenterTok, 30, 0.015, "CCO Operation Condition"::"Die Cut");
      AddTemplateOperation(DigitalTemplateTok, '40', PackWorkCenterTok, 5, 0.005, "CCO Operation Condition"::Always);
      Created += 1;
    end else
      Existing += 1;

    AddSummaryLine('Routing templates', Created, Existing);
  end;

  local procedure CreateRoutingTemplate(TemplateCode: Code[20]; TemplateDescription: Text[100]) Created: Boolean
  var
    RoutingTemplate: Record "CCO Routing Template";
  begin
    if RoutingTemplate.Get(TemplateCode) then
      exit;
    RoutingTemplate.Init();
    RoutingTemplate."Code" := TemplateCode;
    RoutingTemplate.Description := TemplateDescription;
    RoutingTemplate.Insert(true);
    Created := true;
  end;

  local procedure AddTemplateOperation(TemplateCode: Code[20]; OperationNo: Code[10]; WorkCenterNo: Code[20]; SetupTime: Decimal; RunTime: Decimal; Condition: Enum "CCO Operation Condition")
  var
    RoutingTemplateLine: Record "CCO Routing Template Line";
  begin
    RoutingTemplateLine.Init();
    RoutingTemplateLine."Template Code" := TemplateCode;
    RoutingTemplateLine."Operation No." := OperationNo;
    RoutingTemplateLine.Validate("Work Center No.", WorkCenterNo);
    RoutingTemplateLine."Setup Time" := SetupTime;
    RoutingTemplateLine."Run Time" := RunTime;
    RoutingTemplateLine.Condition := Condition;
    RoutingTemplateLine.Insert(true);
  end;

  local procedure CreateNumberSeries()
  var
    Created: Integer;
    Existing: Integer;
  begin
    CountResult(CreateNoSeries(SpecNosTok, 'Packaging specifications (demo)', 'PPS00001'), Created, Existing);
    CountResult(CreateNoSeries(CostSheetNosTok, 'Packaging cost sheets (demo)', 'PPC00001'), Created, Existing);
    CountResult(CreateNoSeries(ItemNosTok, 'Packaging finished items (demo)', 'PPI00001'), Created, Existing);
    AddSummaryLine('Number series', Created, Existing);
  end;

  local procedure CreateNoSeries(NoSeriesCode: Code[20]; SeriesDescription: Text[100]; StartingNo: Code[20]) Created: Boolean
  var
    NoSeries: Record "No. Series";
    NoSeriesLine: Record "No. Series Line";
  begin
    if NoSeries.Get(NoSeriesCode) then
      exit;

    NoSeries.Init();
    NoSeries.Code := NoSeriesCode;
    NoSeries.Description := SeriesDescription;
    NoSeries."Default Nos." := true;
    NoSeries."Manual Nos." := true;
    NoSeries.Insert(true);

    NoSeriesLine.Init();
    NoSeriesLine."Series Code" := NoSeriesCode;
    NoSeriesLine."Line No." := 10000;
    NoSeriesLine."Starting No." := StartingNo;
    NoSeriesLine.Open := true;
    NoSeriesLine.Insert(true);
    Created := true;
  end;

  local procedure CreateUnitsOfMeasure()
  begin
    CreateUnitOfMeasure(SquareMeterTok, 'Square meter');
    CreateUnitOfMeasure(LiterTok, 'Liter');
    CreateUnitOfMeasure(KilogramTok, 'Kilogram');
    CreateUnitOfMeasure(PieceTok, 'Piece');
  end;

  local procedure CreateUnitOfMeasure(UnitOfMeasureCode: Code[10]; UnitOfMeasureDescription: Text[50])
  var
    UnitOfMeasure: Record "Unit of Measure";
  begin
    if UnitOfMeasure.Get(UnitOfMeasureCode) then
      exit;

    UnitOfMeasure.Init();
    UnitOfMeasure.Code := UnitOfMeasureCode;
    UnitOfMeasure.Description := UnitOfMeasureDescription;
    UnitOfMeasure.Insert(true);
  end;

  local procedure CreateItemTemplate()
  var
    ItemTempl: Record "Item Templ.";
  begin
    if ItemTempl.Get(ItemTemplateTok) then begin
      AddSummaryLine('Item template', 0, 1);
      exit;
    end;

    ItemTempl.Init();
    ItemTempl.Code := ItemTemplateTok;
    ItemTempl.Description := 'Packaging finished item (demo)';
    ItemTempl.Type := ItemTempl.Type::Inventory;
    ItemTempl."Base Unit of Measure" := PieceTok;
    ItemTempl."Gen. Prod. Posting Group" := ReferenceGenProdPostingGroup;
    ItemTempl."VAT Prod. Posting Group" := ReferenceVATProdPostingGroup;
    ItemTempl."Inventory Posting Group" := ReferenceInventoryPostingGroup;
    ItemTempl.Insert(true);
    AddSummaryLine('Item template', 1, 0);
  end;

  local procedure CreateMaterialItems()
  var
    Created: Integer;
    Existing: Integer;
  begin
    CountResult(CreateSheetMaterial(PaperItemTok, 'Coated paper (demo)', "CCO Material Type"::Paper, RandomDecimal(80, 350, 10), RandomDecimal(0.3, 1.5, 0.05)), Created, Existing);
    CountResult(CreateSheetMaterial(CorrugatedItemTok, 'Corrugated board, E-flute (demo)', "CCO Material Type"::Corrugated, RandomDecimal(300, 700, 10), RandomDecimal(1.5, 3.5, 0.05)), Created, Existing);
    CountResult(CreateSheetMaterial(FoilItemTok, 'Hot stamping foil (demo)', "CCO Material Type"::Foil, RandomDecimal(20, 60, 5), RandomDecimal(2, 6, 0.1)), Created, Existing);
    CountResult(CreateSheetMaterial(FilmItemTok, 'Gloss lamination film (demo)', "CCO Material Type"::Film, RandomDecimal(20, 40, 5), RandomDecimal(0.5, 1.5, 0.05)), Created, Existing);
    CountResult(CreateConsumableMaterial(InkItemTok, 'Printing ink, per liter (demo)', "CCO Material Type"::Ink, LiterTok, RandomDecimal(15, 30, 0.5)), Created, Existing);
    CountResult(CreateConsumableMaterial(GlueItemTok, 'Hot-melt glue, per kg (demo)', "CCO Material Type"::Glue, KilogramTok, RandomDecimal(3, 8, 0.25)), Created, Existing);
    AddSummaryLine('Material items', Created, Existing);
  end;

  local procedure CreateSheetMaterial(ItemNo: Code[20]; ItemDescription: Text[100]; MaterialType: Enum "CCO Material Type"; GSM: Decimal; CostPerSquareMeter: Decimal) Created: Boolean
  var
    Item: Record Item;
  begin
    if not InsertMaterialItem(Item, ItemNo, ItemDescription, MaterialType, SquareMeterTok) then
      exit;

    Item."CCO Material GSM" := GSM;
    Item."CCO Material Width (mm)" := RandomDecimal(700, 1600, 50);
    Item."CCO Material Length (mm)" := RandomDecimal(1000, 2400, 50);
    Item."CCO Cost per m²" := CostPerSquareMeter;
    Item."Unit Cost" := CostPerSquareMeter;
    Item."Last Direct Cost" := CostPerSquareMeter;
    Item.Modify(true);
    Created := true;
  end;

  local procedure CreateConsumableMaterial(ItemNo: Code[20]; ItemDescription: Text[100]; MaterialType: Enum "CCO Material Type"; BaseUnitOfMeasure: Code[10]; UnitCost: Decimal) Created: Boolean
  var
    Item: Record Item;
  begin
    if not InsertMaterialItem(Item, ItemNo, ItemDescription, MaterialType, BaseUnitOfMeasure) then
      exit;

    Item."Unit Cost" := UnitCost;
    Item."Last Direct Cost" := UnitCost;
    Item.Modify(true);
    Created := true;
  end;

  local procedure InsertMaterialItem(var Item: Record Item; ItemNo: Code[20]; ItemDescription: Text[100]; MaterialType: Enum "CCO Material Type"; BaseUnitOfMeasure: Code[10]) Inserted: Boolean
  begin
    if Item.Get(ItemNo) then
      exit;

    Item.Init();
    Item."No." := ItemNo;
    Item.Insert(true);
    Item.Validate(Description, ItemDescription);
    Item.Validate(Type, Item.Type::Inventory);
    Item.Validate("Base Unit of Measure", BaseUnitOfMeasure);
    if ReferenceGenProdPostingGroup <> '' then begin
      Item.Validate("Gen. Prod. Posting Group", ReferenceGenProdPostingGroup);
      Item.Validate("VAT Prod. Posting Group", ReferenceVATProdPostingGroup);
      Item.Validate("Inventory Posting Group", ReferenceInventoryPostingGroup);
    end;
    Item."CCO Packaging Material Type" := MaterialType;
    Inserted := true;
  end;

  local procedure UpdatePackagingSetup()
  var
    PackagingSetup: Record "CCO Packaging Setup";
    Updated: Integer;
  begin
    if not PackagingSetup.Get() then begin
      PackagingSetup.Init();
      PackagingSetup.Insert(true);
    end;

    SetIfBlank(PackagingSetup."Packaging Spec. Nos.", SpecNosTok, Updated);
    SetIfBlank(PackagingSetup."Cost Sheet Nos.", CostSheetNosTok, Updated);
    SetIfBlank(PackagingSetup."Item Nos.", ItemNosTok, Updated);
    SetIfBlank(PackagingSetup."Item Template Code", ItemTemplateTok, Updated);
    SetIfBlank(PackagingSetup."Ink Item No.", InkItemTok, Updated);
    SetIfBlank(PackagingSetup."Glue Item No.", GlueItemTok, Updated);
    SetIfBlank(PackagingSetup."Lamination Film Item No.", FilmItemTok, Updated);
    SetIfBlank(PackagingSetup."Digital Routing Template", DigitalTemplateTok, Updated);
    SetIfBlank(PackagingSetup."Box Routing Template", BoxTemplateTok, Updated);
    SetIfBlank(PackagingSetup."Label Routing Template", LabelTemplateTok, Updated);
    SetIfZero(PackagingSetup."Ink Qty. per m² per Color", RandomDecimal(0.005, 0.015, 0.001), Updated);
    SetIfZero(PackagingSetup."Glue Qty. per Piece", RandomDecimal(0.002, 0.008, 0.001), Updated);
    SetIfZero(PackagingSetup."Lamination Cost per Piece", RandomDecimal(0.01, 0.05, 0.005), Updated);
    PackagingSetup.Modify(true);
    AddSummaryLine('Packaging Setup fields', Updated, 13 - Updated);
  end;

  local procedure CreatePrintCostMatrix()
  var
    Created: Integer;
    Existing: Integer;
  begin
    CountResult(CreatePrintCost("CCO Print Process"::Digital, 0.02, RandomDecimal(50, 150, 5), RandomDecimal(0.03, 0.08, 0.005)), Created, Existing);
    CountResult(CreatePrintCost("CCO Print Process"::Offset, 0.01, RandomDecimal(200, 400, 10), RandomDecimal(0.02, 0.05, 0.005)), Created, Existing);
    CountResult(CreatePrintCost("CCO Print Process"::Flexo, 0.015, RandomDecimal(300, 600, 10), RandomDecimal(0.01, 0.04, 0.005)), Created, Existing);
    CountResult(CreatePrintCost("CCO Print Process"::Screen, RandomDecimal(0.02, 0.04, 0.005), RandomDecimal(100, 250, 10), RandomDecimal(0.04, 0.1, 0.005)), Created, Existing);
    AddSummaryLine('Print Cost Matrix lines', Created, Existing);
  end;

  local procedure CreatePrintCost(PrintProcess: Enum "CCO Print Process"; PrintCostPerPiece: Decimal; MachineSetupCost: Decimal; LaborCostPerPiece: Decimal) Created: Boolean
  var
    PrintCostMatrix: Record "CCO Print Cost Matrix";
  begin
    if PrintCostMatrix.Get(PrintProcess) then
      exit;

    PrintCostMatrix.Init();
    PrintCostMatrix."Print Process" := PrintProcess;
    PrintCostMatrix."Print Cost per Piece" := PrintCostPerPiece;
    PrintCostMatrix."Machine Setup Cost" := MachineSetupCost;
    PrintCostMatrix."Labor Cost per Piece" := LaborCostPerPiece;
    PrintCostMatrix.Insert(true);
    Created := true;
  end;

  local procedure CreateCustomers()
  var
    ReferenceCustomer: Record Customer;
    Created: Integer;
    Existing: Integer;
  begin
    ReferenceCustomer.SetFilter("Customer Posting Group", '<>%1', '');
    ReferenceCustomer.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
    ReferenceCustomer.SetFilter("VAT Bus. Posting Group", '<>%1', '');
    ReferenceCustomer.SetRange("Currency Code", '');
    ReferenceCustomer.SetRange(Blocked, ReferenceCustomer.Blocked::" ");
    if not ReferenceCustomer.FindFirst() then begin
      Clear(ReferenceCustomer);
      Summary.AppendLine(NoCustomerPostingSetupTxt);
    end;

    CountResult(CreateCustomer(PizzaCustomerTok, 'Pizza Kft. (demo)', 20, ReferenceCustomer), Created, Existing);
    CountResult(CreateCustomer(BurgerCustomerTok, 'Burger Bt. (demo)', 15, ReferenceCustomer), Created, Existing);
    AddSummaryLine('Customers', Created, Existing);
  end;

  local procedure CreateCustomer(CustomerNo: Code[20]; CustomerName: Text[100]; MarginPercent: Decimal; ReferenceCustomer: Record Customer) Created: Boolean
  var
    Customer: Record Customer;
  begin
    if Customer.Get(CustomerNo) then
      exit;

    Customer.Init();
    Customer."No." := CustomerNo;
    Customer.Insert(true);
    Customer.Validate(Name, CustomerName);
    if ReferenceCustomer."No." <> '' then begin
      Customer.Validate("Customer Posting Group", ReferenceCustomer."Customer Posting Group");
      Customer.Validate("Gen. Bus. Posting Group", ReferenceCustomer."Gen. Bus. Posting Group");
      Customer.Validate("VAT Bus. Posting Group", ReferenceCustomer."VAT Bus. Posting Group");
      Customer.Validate("Payment Terms Code", ReferenceCustomer."Payment Terms Code");
    end;
    Customer."CCO Packaging Margin %" := MarginPercent;
    Customer.Modify(true);
    Created := true;
  end;

  local procedure CreateSpecifications()
  var
    Created: Integer;
    Existing: Integer;
  begin
    CountResult(CreateSpecification(BoxSpecTok, 'Takeaway food box, 2-color print', PizzaCustomerTok, 200, 400, 300, CorrugatedItemTok, "CCO Print Process"::Digital, 2, true, true, 500, 10, true), Created, Existing);
    CountResult(CreateSpecification(InsertSpecTok, 'Pizza box insert, 1-color print', PizzaCustomerTok, 150, 200, 200, PaperItemTok, "CCO Print Process"::Digital, 1, false, false, 0, 5, true), Created, Existing);
    CountResult(CreateSpecification(LabelSpecTok, 'Burger bag label, 4-color print', BurgerCustomerTok, 100, 0, 60, PaperItemTok, "CCO Print Process"::Flexo, 4, false, true, 250, 8, true), Created, Existing);
    CountResult(CreateSpecification(GenericSpecTok, 'Generic shipping label, 1-color print', '', 150, 0, 100, PaperItemTok, "CCO Print Process"::Offset, 1, false, false, 0, 5, true), Created, Existing);
    CountResult(CreateSpecification(DraftSpecTok, 'Burger box, 3-color print (draft)', BurgerCustomerTok, 250, 250, 250, CorrugatedItemTok, "CCO Print Process"::Offset, 3, true, true, 800, 12, false), Created, Existing);
    AddSummaryLine('Specifications', Created, Existing);
  end;

  local procedure CreateSpecification(SpecificationNo: Code[20]; SpecificationDescription: Text[100]; CustomerNo: Code[20]; WidthMm: Decimal; LengthMm: Decimal; HeightMm: Decimal; MaterialItemNo: Code[20]; PrintProcess: Enum "CCO Print Process"; NoOfColors: Integer; Lamination: Boolean; DieCut: Boolean; DieCost: Decimal; WastePercent: Decimal; Release: Boolean) Created: Boolean
  var
    PackagingSpecification: Record "CCO Packaging Specification";
  begin
    if PackagingSpecification.Get(SpecificationNo) then
      exit;

    PackagingSpecification.Init();
    PackagingSpecification."No." := SpecificationNo;
    PackagingSpecification.Insert(true);
    PackagingSpecification.Validate(Description, SpecificationDescription);
    PackagingSpecification.Validate("Customer No.", CustomerNo);
    PackagingSpecification.Validate("Width (mm)", WidthMm);
    PackagingSpecification.Validate("Length (mm)", LengthMm);
    PackagingSpecification.Validate("Height (mm)", HeightMm);
    PackagingSpecification.Validate("Material Code", MaterialItemNo);
    PackagingSpecification.Validate("Print Process", PrintProcess);
    PackagingSpecification.Validate("No. of Colors", NoOfColors);
    PackagingSpecification.Validate(Lamination, Lamination);
    PackagingSpecification.Validate("Die Cut", DieCut);
    PackagingSpecification.Validate("Die Cost", DieCost);
    PackagingSpecification.Validate("Waste %", WastePercent);
    if Release then
      PackagingSpecification.Validate(Status, PackagingSpecification.Status::Released);
    PackagingSpecification.Modify(true);
    Created := true;
  end;

  local procedure CreateWorksheet()
  var
    PackagingWkshName: Record "CCO Packaging Wksh. Name";
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
  begin
    if not PackagingWkshName.Get(WorksheetNameTok) then begin
      PackagingWkshName.Init();
      PackagingWkshName.Name := WorksheetNameTok;
      PackagingWkshName.Description := 'Demo quotes';
      PackagingWkshName.Insert(true);
    end;

    PackagingWkshLine.SetRange("Worksheet Name", WorksheetNameTok);
    if not PackagingWkshLine.IsEmpty() then begin
      AddSummaryLine('Worksheet lines', 0, PackagingWkshLine.Count());
      exit;
    end;

    CreateWorksheetLine(10000, '', BoxSpecTok, 1000);
    CreateWorksheetLine(20000, '', InsertSpecTok, 5000);
    CreateWorksheetLine(30000, '', LabelSpecTok, 10000);
    CreateWorksheetLine(40000, BurgerCustomerTok, GenericSpecTok, 2500);
    AddSummaryLine('Worksheet lines', 4, 0);
  end;

  local procedure CreateWorksheetLine(LineNo: Integer; CustomerNo: Code[20]; SpecificationNo: Code[20]; LineQuantity: Decimal)
  var
    PackagingWkshLine: Record "CCO Packaging Wksh. Line";
  begin
    PackagingWkshLine.Init();
    PackagingWkshLine."Worksheet Name" := WorksheetNameTok;
    PackagingWkshLine."Line No." := LineNo;
    if CustomerNo <> '' then
      PackagingWkshLine.Validate("Customer No.", CustomerNo);
    PackagingWkshLine.Validate("Specification No.", SpecificationNo);
    PackagingWkshLine.Validate(Quantity, LineQuantity);
    PackagingWkshLine.Insert(true);
  end;

  local procedure FindReferencePostingGroups()
  var
    Item: Record Item;
  begin
    Item.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
    Item.SetFilter("VAT Prod. Posting Group", '<>%1', '');
    Item.SetFilter("Inventory Posting Group", '<>%1', '');
    Item.SetRange(Type, Item.Type::Inventory);
    if Item.FindFirst() then begin
      ReferenceGenProdPostingGroup := Item."Gen. Prod. Posting Group";
      ReferenceVATProdPostingGroup := Item."VAT Prod. Posting Group";
      ReferenceInventoryPostingGroup := Item."Inventory Posting Group";
    end else
      Summary.AppendLine(NoPostingGroupsTxt);
  end;

  local procedure SetIfBlank(var FieldValue: Code[20]; NewValue: Code[20]; var Updated: Integer)
  begin
    if FieldValue <> '' then
      exit;
    FieldValue := NewValue;
    Updated += 1;
  end;

  local procedure SetIfZero(var FieldValue: Decimal; NewValue: Decimal; var Updated: Integer)
  begin
    if FieldValue <> 0 then
      exit;
    FieldValue := NewValue;
    Updated += 1;
  end;

  local procedure CountResult(Created: Boolean; var CreatedCount: Integer; var ExistingCount: Integer)
  begin
    if Created then
      CreatedCount += 1
    else
      ExistingCount += 1;
  end;

  local procedure AddSummaryLine(AreaName: Text; CreatedCount: Integer; ExistingCount: Integer)
  begin
    Summary.AppendLine(StrSubstNo(SummaryLineTxt, AreaName, CreatedCount, ExistingCount));
  end;

  local procedure RandomDecimal(MinValue: Decimal; MaxValue: Decimal; Precision: Decimal) RandomValue: Decimal
  var
    Steps: Integer;
  begin
    Steps := Round((MaxValue - MinValue) / Precision, 1);
    RandomValue := MinValue + (Random(Steps + 1) - 1) * Precision;
  end;
}
