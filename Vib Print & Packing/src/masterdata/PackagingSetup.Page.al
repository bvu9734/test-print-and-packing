page 50115 "CCO Packaging Setup"
{
  Caption = 'Packaging Setup';
  PageType = Card;
  SourceTable = "CCO Packaging Setup";
  ApplicationArea = All;
  UsageCategory = Administration;

  layout
  {
    area(Content)
    {
      group(Numbering)
      {
        Caption = 'Numbering';

        field("Packaging Spec. Nos."; Rec."Packaging Spec. Nos.")
        {
          ApplicationArea = All;
        }
        field("Cost Sheet Nos."; Rec."Cost Sheet Nos.")
        {
          ApplicationArea = All;
        }
      }
      group(ItemCreation)
      {
        Caption = 'Item Creation';

        field("Item Nos."; Rec."Item Nos.")
        {
          ApplicationArea = All;
        }
        field("Item Template Code"; Rec."Item Template Code")
        {
          ApplicationArea = All;
        }
      }
      group(Consumption)
      {
        Caption = 'Consumption';

        field("Ink Item No."; Rec."Ink Item No.")
        {
          ApplicationArea = All;
        }
        field("Ink Qty. per m² per Color"; Rec."Ink Qty. per m² per Color")
        {
          ApplicationArea = All;
        }
        field("Glue Item No."; Rec."Glue Item No.")
        {
          ApplicationArea = All;
        }
        field("Glue Qty. per Piece"; Rec."Glue Qty. per Piece")
        {
          ApplicationArea = All;
        }
        field("Lamination Film Item No."; Rec."Lamination Film Item No.")
        {
          ApplicationArea = All;
        }
        field("Lamination Cost per Piece"; Rec."Lamination Cost per Piece")
        {
          ApplicationArea = All;
        }
      }
    }
  }

  actions
  {
    area(Navigation)
    {
      action(PrintCostMatrix)
      {
        ApplicationArea = All;
        Caption = 'Print Cost Matrix';
        Image = Price;
        RunObject = page "CCO Print Cost Matrix";
        ToolTip = 'Open the printing, machine setup, and labor rates per print process.', Comment = 'hu-HU=Megnyitja a nyomtatási eljárásonkénti nyomtatási, gépbeállítási és munkaerő-díjakat.';
      }
    }
    area(Promoted)
    {
      actionref(PrintCostMatrix_Promoted; PrintCostMatrix)
      {
      }
    }
  }

  trigger OnOpenPage()
  begin
    if not Rec.Get('') then begin
      Rec.Init();
      Rec.Insert();
    end;
  end;
}
