pageextension 50124 "CCO Customer Card Ext." extends "Customer Card"
{
  layout
  {
    addlast(Content)
    {
      group("CCO Packaging")
      {
        Caption = 'Packaging';

        field("CCO Packaging Margin %"; Rec."CCO Packaging Margin %")
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
