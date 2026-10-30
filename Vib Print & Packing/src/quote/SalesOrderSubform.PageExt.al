pageextension 50133 "CCO Sales Order Subform Ext." extends "Sales Order Subform"
{
  layout
  {
    addafter(Description)
    {
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
