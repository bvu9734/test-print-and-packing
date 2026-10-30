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
        field("Waste %"; Rec."Waste %")
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
