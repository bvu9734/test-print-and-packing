pageextension 50156 "CCO Firm Planned Prod Ords Ext" extends "Firm Planned Prod. Orders"
{
  layout
  {
    addafter("Source No.")
    {
      field("CCO Sales Order No."; Rec."CCO Sales Order No.")
      {
        ApplicationArea = All;
      }
      field("CCO Packaging Spec. No."; Rec."CCO Packaging Spec. No.")
      {
        ApplicationArea = All;
      }
    }
  }
}
