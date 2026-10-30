page 50131 "CCO Cost Sheet Ladder"
{
  Caption = 'Price Ladder';
  PageType = List;
  SourceTable = "CCO Packaging Cost Sheet Line";
  ApplicationArea = All;
  Editable = false;

  layout
  {
    area(Content)
    {
      repeater(General)
      {
        field(Quantity; Rec.Quantity)
        {
          ApplicationArea = All;
        }
        field("Unit Cost"; Rec."Unit Cost")
        {
          ApplicationArea = All;
        }
        field("Unit Price"; Rec."Unit Price")
        {
          ApplicationArea = All;
          Style = Strong;
        }
        field("Line Amount"; Rec."Line Amount")
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
