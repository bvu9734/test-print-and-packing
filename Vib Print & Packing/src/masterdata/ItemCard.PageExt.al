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
        }
        field("CCO Material GSM"; Rec."CCO Material GSM")
        {
          ApplicationArea = All;
        }
        field("CCO Material Width (mm)"; Rec."CCO Material Width (mm)")
        {
          ApplicationArea = All;
        }
        field("CCO Material Length (mm)"; Rec."CCO Material Length (mm)")
        {
          ApplicationArea = All;
        }
        field("CCO Cost per m²"; Rec."CCO Cost per m²")
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
