pageextension 50155 "CCO Released Prod. Order Ext." extends "Released Production Order"
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
