page 50128 "CCO Packaging Quote Wizard"
{
  Caption = 'Packaging Quote Wizard';
  PageType = NavigatePage;
  ApplicationArea = All;
  UsageCategory = Tasks;

  layout
  {
    area(Content)
    {
      group(StepCustomer)
      {
        Caption = 'Step 1 of 4: Customer';
        Visible = CustomerStepVisible;
        InstructionalText = 'Select the customer the sales quote is for.';

        field(CustomerNoField; CustomerNo)
        {
          ApplicationArea = All;
          Caption = 'Customer No.';
          TableRelation = Customer;
          ToolTip = 'Specifies the customer the sales quote is for.', Comment = 'hu-HU=Megadja a vevőt, akinek az árajánlat készül.';

          trigger OnValidate()
          begin
            UpdateCustomerName();
          end;
        }
        field(CustomerNameField; CustomerName)
        {
          ApplicationArea = All;
          Caption = 'Customer Name';
          Editable = false;
          ToolTip = 'Specifies the name of the selected customer.', Comment = 'hu-HU=Megadja a kiválasztott vevő nevét.';
        }
      }
      group(StepSpecification)
      {
        Caption = 'Step 2 of 4: Packaging Specification';
        Visible = SpecificationStepVisible;
        InstructionalText = 'Select a released packaging specification of the customer, or a generic specification without a customer.';

        field(SpecificationNoField; SpecificationNo)
        {
          ApplicationArea = All;
          Caption = 'Specification No.';
          ToolTip = 'Specifies the released packaging specification to quote.', Comment = 'hu-HU=Megadja az árajánlatba adandó kiadott csomagolási specifikációt.';

          trigger OnLookup(var Text: Text): Boolean
          begin
            exit(LookupSpecification(Text));
          end;

          trigger OnValidate()
          begin
            UpdateSpecificationDetails();
          end;
        }
        field(SpecificationDescriptionField; SpecificationDescription)
        {
          ApplicationArea = All;
          Caption = 'Description';
          Editable = false;
          ToolTip = 'Specifies the description of the selected specification.', Comment = 'hu-HU=Megadja a kiválasztott specifikáció leírását.';
        }
        field(ItemNoField; ItemNo)
        {
          ApplicationArea = All;
          Caption = 'Item No.';
          Editable = false;
          ToolTip = 'Specifies the finished item that is quoted.', Comment = 'hu-HU=Megadja az árajánlatba kerülő késztermék cikket.';
        }
      }
      group(StepPriceLadder)
      {
        Caption = 'Step 3 of 4: Price Ladder';
        Visible = PriceLadderStepVisible;
        InstructionalText = 'The cost and price are calculated for each ladder quantity. Choose the quantity to quote, or enter another quantity.';

        part(LadderPart; "CCO Cost Sheet Subform")
        {
          ApplicationArea = All;
          Caption = 'Price Ladder';
          Editable = false;
        }
        field(MarginPercentField; MarginPercent)
        {
          ApplicationArea = All;
          Caption = 'Margin %';
          DecimalPlaces = 0 : 5;
          MinValue = 0;
          ToolTip = 'Specifies the markup percentage added to the unit cost. It defaults from the customer.', Comment = 'hu-HU=Megadja az egységköltségre felszámított árrés százalékát. Alapértéke a vevőtől származik.';

          trigger OnValidate()
          begin
            UpdateMargin();
          end;
        }
        field(SelectedQuantityField; SelectedQuantity)
        {
          ApplicationArea = All;
          Caption = 'Quantity to Quote';
          DecimalPlaces = 0 : 5;
          ToolTip = 'Specifies the quantity to quote. Choose a ladder quantity or enter another quantity to calculate it.', Comment = 'hu-HU=Megadja az árajánlatba adandó mennyiséget. Válasszon egy ársáv-mennyiséget, vagy adjon meg másikat a kiszámításhoz.';

          trigger OnLookup(var Text: Text): Boolean
          begin
            LookupLadderQuantity();
            exit(false);
          end;

          trigger OnValidate()
          begin
            UpdateSelectedLine();
          end;
        }
        field(UnitPriceField; UnitPrice)
        {
          ApplicationArea = All;
          Caption = 'Unit Price (LCY)';
          DecimalPlaces = 0 : 5;
          Editable = false;
          ToolTip = 'Specifies the calculated unit price for the quantity, in local currency.', Comment = 'hu-HU=Megadja a mennyiségre számított egységárat saját pénznemben.';
        }
        field(LineAmountField; LineAmount)
        {
          ApplicationArea = All;
          Caption = 'Line Amount (LCY)';
          DecimalPlaces = 0 : 5;
          Editable = false;
          ToolTip = 'Specifies the calculated total price for the quantity, in local currency.', Comment = 'hu-HU=Megadja a mennyiségre számított teljes árat saját pénznemben.';
        }
      }
      group(StepReview)
      {
        Caption = 'Step 4 of 4: Review';
        Visible = ReviewStepVisible;
        InstructionalText = 'Check the quote details, and then choose Create Quote. The sales quote opens when it has been created.';

        field(ReviewCustomerField; CustomerName)
        {
          ApplicationArea = All;
          Caption = 'Customer';
          Editable = false;
          ToolTip = 'Specifies the customer the sales quote is for.', Comment = 'hu-HU=Megadja a vevőt, akinek az árajánlat készül.';
        }
        field(ReviewSpecificationField; SpecificationDescription)
        {
          ApplicationArea = All;
          Caption = 'Specification';
          Editable = false;
          ToolTip = 'Specifies the packaging specification that is quoted.', Comment = 'hu-HU=Megadja az árajánlatba adott csomagolási specifikációt.';
        }
        field(ReviewItemNoField; ItemNo)
        {
          ApplicationArea = All;
          Caption = 'Item No.';
          Editable = false;
          ToolTip = 'Specifies the finished item on the quote line.', Comment = 'hu-HU=Megadja az árajánlat sorában szereplő késztermék cikket.';
        }
        field(ReviewQuantityField; SelectedQuantity)
        {
          ApplicationArea = All;
          Caption = 'Quantity';
          DecimalPlaces = 0 : 5;
          Editable = false;
          ToolTip = 'Specifies the quoted quantity.', Comment = 'hu-HU=Megadja az árajánlatba adott mennyiséget.';
        }
        field(ReviewMarginField; MarginPercent)
        {
          ApplicationArea = All;
          Caption = 'Margin %';
          DecimalPlaces = 0 : 5;
          Editable = false;
          ToolTip = 'Specifies the markup percentage included in the unit price.', Comment = 'hu-HU=Megadja az egységárban szereplő árrés százalékát.';
        }
        field(ReviewUnitPriceField; UnitPrice)
        {
          ApplicationArea = All;
          Caption = 'Unit Price (LCY)';
          DecimalPlaces = 0 : 5;
          Editable = false;
          ToolTip = 'Specifies the calculated unit price in local currency. It is rounded and converted to the currency of the customer on the quote.', Comment = 'hu-HU=Megadja a számított egységárat saját pénznemben. Az árajánlaton kerekítve és a vevő pénznemére átváltva jelenik meg.';
        }
        field(ReviewLineAmountField; LineAmount)
        {
          ApplicationArea = All;
          Caption = 'Line Amount (LCY)';
          DecimalPlaces = 0 : 5;
          Editable = false;
          ToolTip = 'Specifies the calculated total price in local currency.', Comment = 'hu-HU=Megadja a számított teljes árat saját pénznemben.';
        }
        field(ReviewCostSheetField; CostSheetNo)
        {
          ApplicationArea = All;
          Caption = 'Cost Sheet No.';
          Editable = false;
          ToolTip = 'Specifies the cost sheet that the price was calculated on. It is kept with the quote.', Comment = 'hu-HU=Megadja a költséglapot, amelyen az árat kiszámították. Az árajánlattal együtt megmarad.';
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(ActionBack)
      {
        ApplicationArea = All;
        Caption = 'Back';
        Enabled = BackEnabled;
        Image = PreviousRecord;
        InFooterBar = true;
        ToolTip = 'Go to the previous step.', Comment = 'hu-HU=Visszalép az előző lépésre.';

        trigger OnAction()
        begin
          GoToStep(CurrentStep - 1);
        end;
      }
      action(ActionNext)
      {
        ApplicationArea = All;
        Caption = 'Next';
        Enabled = NextEnabled;
        Image = NextRecord;
        InFooterBar = true;
        ToolTip = 'Check this step and go to the next step.', Comment = 'hu-HU=Ellenőrzi ezt a lépést, és továbblép a következőre.';

        trigger OnAction()
        begin
          CheckStep(CurrentStep);
          GoToStep(CurrentStep + 1);
        end;
      }
      action(ActionFinish)
      {
        ApplicationArea = All;
        Caption = 'Create Quote';
        Enabled = FinishEnabled;
        Image = Approve;
        InFooterBar = true;
        ToolTip = 'Create the sales quote and open it.', Comment = 'hu-HU=Létrehozza az értékesítési árajánlatot, és megnyitja.';

        trigger OnAction()
        begin
          CreateQuote();
        end;
      }
    }
  }

  var
    CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";
    CustomerNo: Code[20];
    CustomerName: Text[100];
    SpecificationNo: Code[20];
    SpecificationDescription: Text[100];
    ItemNo: Code[20];
    CostSheetNo: Code[20];
    CostSheetSpecificationNo: Code[20];
    CostSheetCustomerNo: Code[20];
    MarginPercent: Decimal;
    SelectedQuantity: Decimal;
    UnitPrice: Decimal;
    LineAmount: Decimal;
    CurrentStep: Integer;
    QuoteCreated: Boolean;
    CustomerStepVisible: Boolean;
    SpecificationStepVisible: Boolean;
    PriceLadderStepVisible: Boolean;
    ReviewStepVisible: Boolean;
    BackEnabled: Boolean;
    NextEnabled: Boolean;
    FinishEnabled: Boolean;
    SelectCustomerErr: Label 'Select a customer.';
    SelectSpecificationErr: Label 'Select a packaging specification.';
    SelectQuantityErr: Label 'Select a quantity to quote.';
    SpecificationNotReleasedErr: Label 'Packaging specification %1 must be released before it can be quoted.', Comment = '%1 = Packaging Specification No.';
    SpecificationOtherCustomerErr: Label 'Packaging specification %1 belongs to customer %2.', Comment = '%1 = Packaging Specification No., %2 = Customer No.';

  trigger OnOpenPage()
  begin
    UpdateCustomerName();
    UpdateSpecificationDetails();
    CurrPage.LadderPart.Page.SetCostSheet('');
    GoToStep(1);
  end;

  trigger OnQueryClosePage(CloseAction: Action): Boolean
  begin
    if not QuoteCreated then
      DeleteWizardCostSheet();
    exit(true);
  end;

  /// <summary>
  /// Prefills the wizard with a packaging specification and its customer.
  /// </summary>
  /// <param name="PackagingSpecification">The specification to quote.</param>
  procedure SetSpecification(PackagingSpecification: Record "CCO Packaging Specification")
  begin
    SpecificationNo := PackagingSpecification."No.";
    if PackagingSpecification."Customer No." <> '' then
      CustomerNo := PackagingSpecification."Customer No.";
  end;

  local procedure GoToStep(NewStep: Integer)
  begin
    if (NewStep = 3) and (CurrentStep = 2) then
      PrepareCostSheet();

    CurrentStep := NewStep;
    CustomerStepVisible := CurrentStep = 1;
    SpecificationStepVisible := CurrentStep = 2;
    PriceLadderStepVisible := CurrentStep = 3;
    ReviewStepVisible := CurrentStep = 4;
    BackEnabled := CurrentStep > 1;
    NextEnabled := CurrentStep < 4;
    FinishEnabled := CurrentStep = 4;
    CurrPage.Update(false);
  end;

  local procedure CheckStep(Step: Integer)
  var
    PackagingSpecification: Record "CCO Packaging Specification";
  begin
    case Step of
      1:
        if CustomerNo = '' then
          Error(SelectCustomerErr);
      2:
        begin
          if SpecificationNo = '' then
            Error(SelectSpecificationErr);
          PackagingSpecification.Get(SpecificationNo);
          if (PackagingSpecification.Status <> PackagingSpecification.Status::Released) or (PackagingSpecification."Item No." = '') then
            Error(SpecificationNotReleasedErr, SpecificationNo);
          if not (PackagingSpecification."Customer No." in ['', CustomerNo]) then
            Error(SpecificationOtherCustomerErr, SpecificationNo, PackagingSpecification."Customer No.");
        end;
      3:
        if SelectedQuantity <= 0 then
          Error(SelectQuantityErr);
    end;
  end;

  local procedure PrepareCostSheet()
  var
    CostSheet: Record "CCO Packaging Cost Sheet";
  begin
    if (CostSheetNo <> '') and (CostSheetSpecificationNo = SpecificationNo) and (CostSheetCustomerNo = CustomerNo) then
      exit;

    DeleteWizardCostSheet();
    CostEngineMgt.CreateCostSheet(SpecificationNo, CostSheet);
    if CostSheet."Customer No." <> CustomerNo then begin
      CostSheet.Validate("Customer No.", CustomerNo);
      CostSheet.Modify(true);
    end;

    CostSheetNo := CostSheet."No.";
    CostSheetSpecificationNo := SpecificationNo;
    CostSheetCustomerNo := CustomerNo;
    MarginPercent := CostSheet."Margin %";
    SelectedQuantity := 0;
    UnitPrice := 0;
    LineAmount := 0;
    CurrPage.LadderPart.Page.SetCostSheet(CostSheetNo);
  end;

  local procedure UpdateMargin()
  var
    CostSheet: Record "CCO Packaging Cost Sheet";
  begin
    CostSheet.Get(CostSheetNo);
    CostSheet.Validate("Margin %", MarginPercent);
    CostSheet.Modify(true);
    if SelectedQuantity > 0 then
      UpdateSelectedLine();
    CurrPage.LadderPart.Page.SetCostSheet(CostSheetNo);
  end;

  local procedure UpdateSelectedLine()
  var
    CostSheet: Record "CCO Packaging Cost Sheet";
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    CostSheet.Get(CostSheetNo);
    CostEngineMgt.FindOrAddLadderLine(CostSheet, SelectedQuantity, CostSheetLine);
    UnitPrice := CostSheetLine."Unit Price";
    LineAmount := CostSheetLine."Line Amount";
    CurrPage.LadderPart.Page.SetCostSheet(CostSheetNo);
  end;

  local procedure LookupLadderQuantity()
  var
    CostSheetLine: Record "CCO Packaging Cost Sheet Line";
  begin
    CostSheetLine.SetRange("Cost Sheet No.", CostSheetNo);
    if Page.RunModal(Page::"CCO Cost Sheet Ladder", CostSheetLine) <> Action::LookupOK then
      exit;

    SelectedQuantity := CostSheetLine.Quantity;
    UpdateSelectedLine();
  end;

  local procedure LookupSpecification(var Text: Text): Boolean
  var
    PackagingSpecification: Record "CCO Packaging Specification";
  begin
    PackagingSpecification.SetRange(Status, PackagingSpecification.Status::Released);
    PackagingSpecification.SetFilter("Customer No.", '%1|%2', CustomerNo, '');
    if Page.RunModal(Page::"CCO Packaging Specifications", PackagingSpecification) <> Action::LookupOK then
      exit(false);

    Text := PackagingSpecification."No.";
    exit(true);
  end;

  local procedure UpdateCustomerName()
  var
    Customer: Record Customer;
  begin
    CustomerName := '';
    if Customer.Get(CustomerNo) then
      CustomerName := Customer.Name;
  end;

  local procedure UpdateSpecificationDetails()
  var
    PackagingSpecification: Record "CCO Packaging Specification";
  begin
    SpecificationDescription := '';
    ItemNo := '';
    if PackagingSpecification.Get(SpecificationNo) then begin
      SpecificationDescription := PackagingSpecification.Description;
      ItemNo := PackagingSpecification."Item No.";
    end;
  end;

  local procedure CreateQuote()
  var
    CostSheet: Record "CCO Packaging Cost Sheet";
    SalesHeader: Record "Sales Header";
    PackagingQuoteMgt: Codeunit "CCO Packaging Quote Mgt.";
  begin
    CheckStep(3);
    CostSheet.Get(CostSheetNo);
    PackagingQuoteMgt.CreateSalesQuote(CostSheet, SelectedQuantity, SalesHeader);
    QuoteCreated := true;
    CurrPage.Close();
    Page.Run(Page::"Sales Quote", SalesHeader);
  end;

  local procedure DeleteWizardCostSheet()
  var
    CostSheet: Record "CCO Packaging Cost Sheet";
  begin
    if CostSheetNo = '' then
      exit;
    if CostSheet.Get(CostSheetNo) then
      CostSheet.Delete(true);
    CostSheetNo := '';
  end;
}
