tableextension 50151 "CCO Production Order Ext." extends "Production Order"
{
  fields
  {
    field(50100; "CCO Sales Order No."; Code[20])
    {
      Caption = 'Sales Order No.';
      ToolTip = 'Specifies the sales order that the production order was created for.', Comment = 'hu-HU=Megadja az értékesítési rendelést, amelyhez a gyártási rendelés létrejött.';
      DataClassification = CustomerContent;
      TableRelation = "Sales Header"."No." where("Document Type" = const(Order));
      Editable = false;
    }
    field(50101; "CCO Sales Order Line No."; Integer)
    {
      Caption = 'Sales Order Line No.';
      ToolTip = 'Specifies the line of the sales order that the production order was created for.', Comment = 'hu-HU=Megadja az értékesítési rendelés sorát, amelyhez a gyártási rendelés létrejött.';
      DataClassification = CustomerContent;
      BlankZero = true;
      Editable = false;
    }
    field(50102; "CCO Packaging Spec. No."; Code[20])
    {
      Caption = 'Packaging Spec. No.';
      ToolTip = 'Specifies the packaging specification of the product that is produced.', Comment = 'hu-HU=Megadja a gyártott termék csomagolási specifikációját.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Specification";
      Editable = false;
    }
    field(50103; "CCO Cost Sheet No."; Code[20])
    {
      Caption = 'Packaging Cost Sheet No.';
      ToolTip = 'Specifies the packaging cost sheet that the sales price of the produced product was calculated on.', Comment = 'hu-HU=Megadja a csomagolási költséglapot, amelyen a gyártott termék eladási árát kiszámították.';
      DataClassification = CustomerContent;
      TableRelation = "CCO Packaging Cost Sheet";
      Editable = false;
    }
  }

  keys
  {
    key(CCOSalesOrderLine; "CCO Sales Order No.", "CCO Sales Order Line No.")
    {
    }
    key(CCOPackagingSpec; "CCO Packaging Spec. No.")
    {
    }
  }
}
