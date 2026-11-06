pageextension 50157 "CCO Released Prod. Orders Ext." extends "Released Production Orders"
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
