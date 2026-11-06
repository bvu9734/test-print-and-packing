codeunit 50153 "CCO Packaging Production Subs."
{
  Access = Internal;

  [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Prod. Order from Sale", OnAfterCreateProdOrderFromSalesLine, '', false, false)]
  local procedure CopyLinksOnAfterCreateProdOrderFromSalesLine(var ProdOrder: Record "Production Order"; var SalesLine: Record "Sales Line")
  var
    PackagingProductionMgt: Codeunit "CCO Packaging Production Mgt.";
  begin
    PackagingProductionMgt.CopyLinksFromSalesLine(ProdOrder, SalesLine);
  end;

  [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, Quantity, false, false)]
  local procedure BlockQtyChangeOnBeforeValidateSalesLineQuantity(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
  var
    PackagingProductionMgt: Codeunit "CCO Packaging Production Mgt.";
  begin
    PackagingProductionMgt.CheckQuantityChangeBlocked(Rec, xRec);
  end;

  [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterValidateEvent, Quantity, false, false)]
  local procedure CheckProdOrderOnAfterValidateSalesLineQuantity(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
  var
    PackagingProductionMgt: Codeunit "CCO Packaging Production Mgt.";
  begin
    PackagingProductionMgt.CheckQuantityChange(Rec, xRec);
  end;
}
