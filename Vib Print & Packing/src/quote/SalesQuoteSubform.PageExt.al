pageextension 50132 "CCO Sales Quote Subform Ext." extends "Sales Quote Subform"
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
