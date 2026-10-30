page 50125 "CCO Packaging Cost Sheet"
{
  Caption = 'Packaging Cost Sheet';
  PageType = Document;
  SourceTable = "CCO Packaging Cost Sheet";
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
        field("Specification No."; Rec."Specification No.")
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
        field("Margin %"; Rec."Margin %")
        {
          ApplicationArea = All;

          trigger OnValidate()
          begin
            CurrPage.Update(true);
          end;
        }
        field("Calculation Date"; Rec."Calculation Date")
        {
          ApplicationArea = All;
        }
        field("Sales Quote No."; Rec."Sales Quote No.")
        {
          ApplicationArea = All;
        }
      }
      part(Lines; "CCO Cost Sheet Subform")
      {
        ApplicationArea = All;
        Caption = 'Price Ladder';
        SubPageLink = "Cost Sheet No." = field("No.");
        UpdatePropagation = Both;
      }
      group(UnitCostBreakdown)
      {
        Caption = 'Unit Cost Breakdown';

        field("Base Area (m²)"; Rec."Base Area (m²)")
        {
          ApplicationArea = All;
        }
        field("Required Area (m²)"; Rec."Required Area (m²)")
        {
          ApplicationArea = All;
        }
        field("Material Cost"; Rec."Material Cost")
        {
          ApplicationArea = All;
        }
        field("Ink Cost"; Rec."Ink Cost")
        {
          ApplicationArea = All;
        }
        field("Glue Cost"; Rec."Glue Cost")
        {
          ApplicationArea = All;
        }
        field("Lamination Cost"; Rec."Lamination Cost")
        {
          ApplicationArea = All;
        }
        field("Printing Cost"; Rec."Printing Cost")
        {
          ApplicationArea = All;
        }
        field("Labor Cost"; Rec."Labor Cost")
        {
          ApplicationArea = All;
        }
        field("Variable Unit Cost"; Rec."Variable Unit Cost")
        {
          ApplicationArea = All;
          Style = Strong;
        }
        field("Machine Setup Cost"; Rec."Machine Setup Cost")
        {
          ApplicationArea = All;
        }
        field("Die Cost"; Rec."Die Cost")
        {
          ApplicationArea = All;
        }
        field("Fixed Cost"; Rec."Fixed Cost")
        {
          ApplicationArea = All;
          Style = Strong;
        }
      }
      group(CalculationBasis)
      {
        Caption = 'Calculation Basis';

        field("Width (mm)"; Rec."Width (mm)")
        {
          ApplicationArea = All;
        }
        field("Height (mm)"; Rec."Height (mm)")
        {
          ApplicationArea = All;
        }
        field("Waste %"; Rec."Waste %")
        {
          ApplicationArea = All;
        }
        field("Material Item No."; Rec."Material Item No.")
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
      }
    }
  }

  actions
  {
    area(Processing)
    {
      action(Calculate)
      {
        ApplicationArea = All;
        Caption = 'Calculate';
        Image = Calculate;
        ToolTip = 'Recalculate the cost components and the price ladder from the current specification and rates.', Comment = 'hu-HU=Újraszámítja a költségelemeket és az ársávokat az aktuális specifikáció és díjak alapján.';

        trigger OnAction()
        var
          CostEngineMgt: Codeunit "CCO Cost Engine Mgt.";
        begin
          CurrPage.SaveRecord();
          CostEngineMgt.Calculate(Rec);
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
        ToolTip = 'Open the packaging specification that is costed.', Comment = 'hu-HU=Megnyitja a kalkulált csomagolási specifikációt.';
      }
    }
    area(Promoted)
    {
      actionref(Calculate_Promoted; Calculate)
      {
      }
      actionref(Specification_Promoted; Specification)
      {
      }
    }
  }
}
