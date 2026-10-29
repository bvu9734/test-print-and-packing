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
          ToolTip = 'Specifies the unique code for the packaging specification. Leave blank to use the configured number series.';
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
          ToolTip = 'Specifies a description of the packaging specification.';
        }
        field("Customer No."; Rec."Customer No.")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the customer associated with the packaging specification.';
        }
        field(Status; Rec.Status)
        {
          ApplicationArea = All;
          ToolTip = 'Specifies whether the packaging specification is a draft or released. Released specifications remain editable.';
        }
      }
      group(Dimensions)
      {
        Caption = 'Dimensions';

        field("Width (mm)"; Rec."Width (mm)")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the packaging width in millimeters.';
        }
        field("Length (mm)"; Rec."Length (mm)")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the packaging length in millimeters.';
        }
        field("Height (mm)"; Rec."Height (mm)")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the packaging height in millimeters.';
        }
      }
      group(MaterialAndPrint)
      {
        Caption = 'Material and Print';

        field("Material Code"; Rec."Material Code")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the item used as the packaging material.';
        }
        field("Material GSM"; Rec."Material GSM")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the material weight in grams per square meter.';
        }
        field("Print Process"; Rec."Print Process")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the print process used for the packaging.';
        }
        field("No. of Colors"; Rec."No. of Colors")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the number of colors used in the print process.';
        }
        field(Lamination; Rec.Lamination)
        {
          ApplicationArea = All;
          ToolTip = 'Specifies whether the packaging uses lamination.';
        }
        field("Die Cut"; Rec."Die Cut")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies whether the packaging requires die cutting.';
        }
        field("Waste %"; Rec."Waste %")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the expected material waste percentage.';
        }
      }
    }
  }
}
