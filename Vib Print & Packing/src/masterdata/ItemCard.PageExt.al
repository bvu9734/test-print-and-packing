pageextension 50116 "CCO Item Card Ext." extends "Item Card"
{
  layout
  {
    addlast(Content)
    {
      group("CCO Packaging")
      {
        Caption = 'Packaging';

        field("CCO Packaging Material Type"; Rec."CCO Packaging Material Type")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the packaging material type, such as paper, corrugated board, ink, glue, foil, or film.';
        }
        field("CCO Material GSM"; Rec."CCO Material GSM")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the material weight in grams per square meter.';
        }
        field("CCO Material Width (mm)"; Rec."CCO Material Width (mm)")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the material width in millimeters.';
        }
        field("CCO Material Length (mm)"; Rec."CCO Material Length (mm)")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the material length in millimeters.';
        }
        field("CCO Cost per m²"; Rec."CCO Cost per m²")
        {
          ApplicationArea = All;
          ToolTip = 'Specifies the material cost for one square meter.';
        }
      }
    }
  }
}
