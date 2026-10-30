page 50126 "CCO Cost Sheet Subform"
{
  Caption = 'Price Ladder';
  PageType = ListPart;
  SourceTable = "CCO Packaging Cost Sheet Line";
  AutoSplitKey = true;
  DelayedInsert = true;

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
        field("Fixed Cost per Piece"; Rec."Fixed Cost per Piece")
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

  /// <summary>
  /// Shows the price ladder of one cost sheet. Used when the part is not linked to a cost sheet record.
  /// </summary>
  /// <param name="CostSheetNo">The cost sheet to show.</param>
  procedure SetCostSheet(CostSheetNo: Code[20])
  begin
    Rec.FilterGroup(2);
    Rec.SetRange("Cost Sheet No.", CostSheetNo);
    Rec.FilterGroup(0);
    CurrPage.Update(false);
  end;
}
