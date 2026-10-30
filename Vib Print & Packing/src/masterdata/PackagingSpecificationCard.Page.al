page 50114 "CCO Packaging Spec. Card"
{
  Caption = 'Packaging Specification';
  PageType = Card;
  SourceTable = "CCO Packaging Specification";
  ApplicationArea = All;

  layout
  {
    area(Content)
    {
      group(General)
      {
        Caption = 'General';

        field("No."; Rec."No.")
        {
          ApplicationArea = All;
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
        }
        field("Customer No."; Rec."Customer No.")
        {
          ApplicationArea = All;
        }
        field(Status; Rec.Status)
        {
          ApplicationArea = All;
        }
        field("Item No."; Rec."Item No.")
        {
          ApplicationArea = All;
        }
      }
      group(Dimensions)
      {
        Caption = 'Dimensions';

        field("Width (mm)"; Rec."Width (mm)")
        {
          ApplicationArea = All;
        }
        field("Length (mm)"; Rec."Length (mm)")
        {
          ApplicationArea = All;
        }
        field("Height (mm)"; Rec."Height (mm)")
        {
          ApplicationArea = All;
        }
      }
      group(MaterialAndPrint)
      {
        Caption = 'Material and Print';

        field("Material Code"; Rec."Material Code")
        {
          ApplicationArea = All;
        }
        field("Material GSM"; Rec."Material GSM")
        {
          ApplicationArea = All;
        }
        field("Print Process"; Rec."Print Process")
        {
          ApplicationArea = All;
        }
        field("No. of Colors"; Rec."No. of Colors")
        {
          ApplicationArea = All;
        }
        field(Lamination; Rec.Lamination)
        {
          ApplicationArea = All;
        }
        field("Die Cut"; Rec."Die Cut")
        {
          ApplicationArea = All;
        }
        field("Die Cost"; Rec."Die Cost")
        {
          ApplicationArea = All;
        }
        field("Waste %"; Rec."Waste %")
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
      action(CreateCostSheet)
      {
        ApplicationArea = All;
        Caption = 'Create Cost Sheet';
        Image = CalculateCost;
        ToolTip = 'Calculate the cost and price ladder of this specification on a new cost sheet.', Comment = 'hu-HU=Kiszámítja a specifikáció költségét és ársávjait egy új költséglapon.';

        trigger OnAction()
        var
          CostSheet: Record "CCO Packaging Cost Sheet";
          CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";
        begin
          CurrPage.SaveRecord();
          CostEngineMgt.CreateCostSheet(Rec."No.", CostSheet);
          Page.Run(Page::"CCO Packaging Cost Sheet", CostSheet);
        end;
      }
      action(CreateSalesQuote)
      {
        ApplicationArea = All;
        Caption = 'Create Sales Quote';
        Image = NewSalesQuote;
        ToolTip = 'Open the quote wizard for this specification to calculate the price ladder and create a sales quote.', Comment = 'hu-HU=Megnyitja az árajánlat-varázslót ehhez a specifikációhoz az ársávok kiszámításához és az értékesítési árajánlat létrehozásához.';

        trigger OnAction()
        var
          PackagingQuoteWizard: Page "CCO Packaging Quote Wizard";
        begin
          CurrPage.SaveRecord();
          PackagingQuoteWizard.SetSpecification(Rec);
          PackagingQuoteWizard.Run();
        end;
      }
    }
    area(Navigation)
    {
      action(CostSheets)
      {
        ApplicationArea = All;
        Caption = 'Cost Sheets';
        Image = CostBudget;
        RunObject = page "CCO Packaging Cost Sheets";
        RunPageLink = "Specification No." = field("No.");
        ToolTip = 'View the cost sheets of this specification.', Comment = 'hu-HU=Megjeleníti a specifikáció költséglapjait.';
      }
    }
    area(Promoted)
    {
      actionref(CreateCostSheet_Promoted; CreateCostSheet)
      {
      }
      actionref(CreateSalesQuote_Promoted; CreateSalesQuote)
      {
      }
      actionref(CostSheets_Promoted; CostSheets)
      {
      }
    }
  }
}
