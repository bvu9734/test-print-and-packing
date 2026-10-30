page 50121 "CCO Print Cost Matrix"
{
  Caption = 'Print Cost Matrix';
  PageType = List;
  SourceTable = "CCO Print Cost Matrix";
  ApplicationArea = All;
  UsageCategory = Administration;

  layout
  {
    area(Content)
    {
      repeater(General)
      {
        field("Print Process"; Rec."Print Process")
        {
          ApplicationArea = All;
        }
        field("Print Cost per Piece"; Rec."Print Cost per Piece")
        {
          ApplicationArea = All;
        }
        field("Machine Setup Cost"; Rec."Machine Setup Cost")
        {
          ApplicationArea = All;
        }
        field("Labor Cost per Piece"; Rec."Labor Cost per Piece")
        {
          ApplicationArea = All;
        }
      }
    }
  }
}
