page 50147 "CCO Packaging BOM Subform"
{
  Caption = 'Components';
  PageType = ListPart;
  SourceTable = "CCO Packaging BOM Line";
  AutoSplitKey = true;
  DelayedInsert = true;

  layout
  {
    area(Content)
    {
      repeater(General)
      {
        field("Item No."; Rec."Item No.")
        {
          ApplicationArea = All;
        }
        field(Description; Rec.Description)
        {
          ApplicationArea = All;
        }
        field("Material Type"; Rec."Material Type")
        {
          ApplicationArea = All;
        }
        field("Quantity per"; Rec."Quantity per")
        {
          ApplicationArea = All;
        }
        field("Unit of Measure Code"; Rec."Unit of Measure Code")
        {
          ApplicationArea = All;
        }
        field("Scrap %"; Rec."Scrap %")
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
