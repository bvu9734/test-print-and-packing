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
      field("CCO Prod. Order No."; Rec."CCO Prod. Order No.")
      {
        ApplicationArea = All;

        trigger OnDrillDown()
        var
          ProductionOrder: Record "Production Order";
          PackagingProductionMgt: Codeunit "CCO Packaging Production Mgt.";
        begin
          if PackagingProductionMgt.FindOpenProdOrder(Rec, ProductionOrder) then
            PackagingProductionMgt.ShowProductionOrder(ProductionOrder);
        end;
      }
    }
  }

  actions
  {
    addlast("&Line")
    {
      action(CCOCreatePackagingProduction)
      {
        ApplicationArea = All;
        Caption = 'Create Packaging Production';
        Enabled = HasPackagingSpec;
        Image = CreateDocument;
        ToolTip = 'Create a production order for the selected line from its packaging specification. The production BOM and routing are generated first if needed. No order is created if the line already has an open production order.', Comment = 'hu-HU=Gyártási rendelés létrehozása a kijelölt sorhoz a csomagolási specifikáció alapján. Szükség esetén előbb a gyártási anyagjegyzék és a műveleti terv generálódik. Nem jön létre rendelés, ha a sorhoz már tartozik nyitott gyártási rendelés.';

        trigger OnAction()
        var
          ProductionOrder: Record "Production Order";
          PackagingProductionMgt: Codeunit "CCO Packaging Production Mgt.";
        begin
          CurrPage.SaveRecord();
          if PackagingProductionMgt.CreatePackagingProduction(Rec, ProductionOrder) then begin
            CurrPage.Update(false);
            if Confirm(ProdOrderCreatedQst, true, ProductionOrder.Status, ProductionOrder."No.") then
              PackagingProductionMgt.ShowProductionOrder(ProductionOrder);
          end else
            Message(ProdOrderExistsMsg, Rec."Line No.", ProductionOrder.Status, ProductionOrder."No.");
        end;
      }
    }
  }

  trigger OnAfterGetCurrRecord()
  begin
    HasPackagingSpec := Rec."CCO Packaging Spec. No." <> '';
  end;

  var
    HasPackagingSpec: Boolean;
    ProdOrderCreatedQst: Label '%1 production order %2 was created. Do you want to open it?', Comment = '%1 = Production Order Status, %2 = Production Order No.';
    ProdOrderExistsMsg: Label 'Sales order line %1 already has %2 production order %3. No new production order was created.', Comment = '%1 = Line No., %2 = Production Order Status, %3 = Production Order No.';
}
