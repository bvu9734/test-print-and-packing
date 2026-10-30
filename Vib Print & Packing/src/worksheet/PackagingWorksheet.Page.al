page 50137 "CCO Packaging Worksheet"
{
  Caption = 'Packaging Worksheet';
  PageType = Worksheet;
  SourceTable = "CCO Packaging Wksh. Line";
  ApplicationArea = All;
  UsageCategory = Tasks;
  AutoSplitKey = true;
  DelayedInsert = true;
  SaveValues = true;

  layout
  {
    area(Content)
    {
      field(CurrentWorksheetNameField; CurrentWorksheetName)
      {
        ApplicationArea = All;
        Caption = 'Name';
        Lookup = true;
        ToolTip = 'Specifies the packaging worksheet batch you are working in.', Comment = 'hu-HU=Megadja a csomagolási munkalap kötegét, amelyben dolgozik.';

        trigger OnLookup(var Text: Text): Boolean
        var
          PackagingWkshName: Record "CCO Packaging Wksh. Name";
        begin
          PackagingWkshName.Name := CurrentWorksheetName;
          if Page.RunModal(Page::"CCO Packaging Wksh. Names", PackagingWkshName) <> Action::LookupOK then
            exit(false);
          Text := PackagingWkshName.Name;
          exit(true);
        end;

        trigger OnValidate()
        var
          PackagingWkshName: Record "CCO Packaging Wksh. Name";
        begin
          PackagingWkshName.Get(CurrentWorksheetName);
          CurrPage.SaveRecord();
          SetWorksheetFilter();
          CurrPage.Update(false);
        end;
      }
      repeater(Lines)
      {
        field(Accept; Rec.Accept)
        {
          ApplicationArea = All;
        }
        field("Customer No."; Rec."Customer No.")
        {
          ApplicationArea = All;
        }
        field("Customer Name"; Rec."Customer Name")
        {
          ApplicationArea = All;
        }
        field("Specification No."; Rec."Specification No.")
        {
          ApplicationArea = All;
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
        }
        field("Item No."; Rec."Item No.")
        {
          ApplicationArea = All;
        }
        field(Quantity; Rec.Quantity)
        {
          ApplicationArea = All;
        }
        field("Margin %"; Rec."Margin %")
        {
          ApplicationArea = All;
        }
        field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
        {
          ApplicationArea = All;
          Style = Strong;
        }
        field("Line Amount (LCY)"; Rec."Line Amount (LCY)")
        {
          ApplicationArea = All;
        }
        field("Cost Sheet No."; Rec."Cost Sheet No.")
        {
          ApplicationArea = All;
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(GetSpecifications)
      {
        ApplicationArea = All;
        Caption = 'Get Specifications';
        Image = GetLines;
        Ellipsis = true;
        ToolTip = 'Select one or more released packaging specifications and add a worksheet line for each of them.', Comment = 'hu-HU=Egy vagy több kiadott csomagolási specifikáció kiválasztása, és mindegyikhez egy munkalapsor hozzáadása.';

        trigger OnAction()
        var
          PackagingSpecification: Record "CCO Packaging Specification";
          PackagingSpecifications: Page "CCO Packaging Specifications";
        begin
          CurrPage.SaveRecord();
          PackagingSpecification.SetRange(Status, PackagingSpecification.Status::Released);
          PackagingSpecifications.SetTableView(PackagingSpecification);
          PackagingSpecifications.LookupMode(true);
          if PackagingSpecifications.RunModal() <> Action::LookupOK then
            exit;

          PackagingSpecifications.GetSelectedSpecifications(PackagingSpecification);
          PackagingWkshMgt.AddSpecifications(CurrentWorksheetName, PackagingSpecification);
          CurrPage.Update(false);
        end;
      }
      action(Calculate)
      {
        ApplicationArea = All;
        Caption = 'Calculate';
        Image = Calculate;
        ToolTip = 'Recalculate the prices of all lines with the current specifications and rates. Changed line margins are kept.', Comment = 'hu-HU=Az összes sor árának újraszámítása az aktuális specifikációk és díjak alapján. A módosított sorárrések megmaradnak.';

        trigger OnAction()
        begin
          CurrPage.SaveRecord();
          PackagingWkshMgt.RecalculateWorksheet(CurrentWorksheetName);
          CurrPage.Update(false);
        end;
      }
      action(CreateSalesQuotes)
      {
        ApplicationArea = All;
        Caption = 'Create Sales Quotes';
        Image = NewSalesQuote;
        ToolTip = 'Create one sales quote per customer from the accepted lines, and remove those lines from the worksheet.', Comment = 'hu-HU=Vevőnként egy értékesítési árajánlat létrehozása az elfogadott sorokból, és a sorok eltávolítása a munkalapról.';

        trigger OnAction()
        var
          SalesQuoteNos: List of [Code[20]];
        begin
          CurrPage.SaveRecord();
          SalesQuoteNos := PackagingWkshMgt.CreateSalesQuotes(CurrentWorksheetName);
          Message(SalesQuotesCreatedMsg, SalesQuoteNos.Count(), FormatQuoteNos(SalesQuoteNos));
          CurrPage.Update(false);
        end;
      }
    }
    area(Navigation)
    {
      action(Specification)
      {
        ApplicationArea = All;
        Caption = 'Specification';
        Image = Document;
        RunObject = page "CCO Packaging Spec. Card";
        RunPageLink = "No." = field("Specification No.");
        ToolTip = 'Open the packaging specification of the selected line.', Comment = 'hu-HU=Megnyitja a kijelölt sor csomagolási specifikációját.';
      }
      action(CostSheet)
      {
        ApplicationArea = All;
        Caption = 'Cost Sheet';
        Image = CalculateCost;
        RunObject = page "CCO Packaging Cost Sheet";
        RunPageLink = "No." = field("Cost Sheet No.");
        ToolTip = 'Open the cost sheet that the price of the selected line is calculated on.', Comment = 'hu-HU=Megnyitja a költséglapot, amelyen a kijelölt sor árát kiszámították.';
      }
    }
    area(Promoted)
    {
      actionref(GetSpecifications_Promoted; GetSpecifications)
      {
      }
      actionref(Calculate_Promoted; Calculate)
      {
      }
      actionref(CreateSalesQuotes_Promoted; CreateSalesQuotes)
      {
      }
      actionref(CostSheet_Promoted; CostSheet)
      {
      }
    }
  }

  trigger OnOpenPage()
  begin
    CurrentWorksheetName := PackagingWkshMgt.GetWorksheetName(CurrentWorksheetName);
    SetWorksheetFilter();
  end;

  trigger OnNewRecord(BelowxRec: Boolean)
  begin
    Rec."Worksheet Name" := CurrentWorksheetName;
  end;

  var
    PackagingWkshMgt: Codeunit "CCO Packaging Wksh. Mgt.";
    CurrentWorksheetName: Code[10];
    SalesQuotesCreatedMsg: Label '%1 sales quote(s) created: %2', Comment = '%1 = Number of quotes, %2 = Comma-separated quote numbers';

  local procedure SetWorksheetFilter()
  begin
    Rec.FilterGroup(2);
    Rec.SetRange("Worksheet Name", CurrentWorksheetName);
    Rec.FilterGroup(0);
  end;

  local procedure FormatQuoteNos(SalesQuoteNos: List of [Code[20]]) QuoteNosText: Text
  var
    SalesQuoteNo: Code[20];
  begin
    foreach SalesQuoteNo in SalesQuoteNos do
      if QuoteNosText = '' then
        QuoteNosText := SalesQuoteNo
      else
        QuoteNosText += ', ' + SalesQuoteNo;
  end;
}
