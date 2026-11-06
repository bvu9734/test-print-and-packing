tableextension 50130 "CCO Sales Line Ext." extends "Sales Line"
{
  fields
  {
    field(50100; "CCO Packaging Spec. No."; Code[20])
    {
      Caption = 'Packaging Spec. No.';
      ToolTip = 'Specifies the packaging specification that the line was quoted from.', Comment = 'hu-HU=Megadja a csomagolási specifikációt, amely alapján a sort árajánlatba adták.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Specification";
      Editable = false;
    }
    field(50101; "CCO Cost Sheet No."; Code[20])
    {
      Caption = 'Packaging Cost Sheet No.';
      ToolTip = 'Specifies the packaging cost sheet that the unit price of the line was calculated on.', Comment = 'hu-HU=Megadja a csomagolási költséglapot, amelyen a sor egységárát kiszámították.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Cost Sheet";
      Editable = false;
    }
    field(50102; "CCO Prod. Order No."; Code[20])
    {
      Caption = 'Prod. Order No.';
      ToolTip = 'Specifies the open firm planned or released production order that was created for the sales order line.', Comment = 'hu-HU=Megadja az értékesítési rendeléssorhoz létrehozott nyitott, véglegesen tervezett vagy kiadott gyártási rendelést.';
      FieldClass = FlowField;
      CalcFormula = lookup("Production Order"."No." where("CCO Sales Order No." = field("Document No."), "CCO Sales Order Line No." = field("Line No."), Status = filter("Firm Planned" | Released)));
      Editable = false;
    }
  }
}
