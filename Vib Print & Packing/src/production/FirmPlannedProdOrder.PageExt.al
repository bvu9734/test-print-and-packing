pageextension 50154 "CCO Firm Planned Prod. Ord Ext" extends "Firm Planned Prod. Order"
{
  layout
  {
    addafter("Source No.")
    {
      field("CCO Sales Order No."; Rec."CCO Sales Order No.")
      {
        ApplicationArea = All;
      }
      field("CCO Sales Order Line No."; Rec."CCO Sales Order Line No.")
      {
        ApplicationArea = All;
      }
      field("CCO Packaging Spec. No."; Rec."CCO Packaging Spec. No.")
      {
        ApplicationArea = All;
      }
      field("CCO Cost Sheet No."; Rec."CCO Cost Sheet No.")
      {
        ApplicationArea = All;
      }
    }
  }
}
