codeunit 50152 "CCO Packaging Production Mgt."
{
  var
    NotSalesOrderLineErr: Label 'Production orders can only be created from item lines of a sales order.';
    NoPackagingSpecErr: Label 'Sales order line %1 has no packaging specification.', Comment = '%1 = Line No.';
    SpecNotReleasedErr: Label 'Packaging specification %1 must be released before a production order can be created.', Comment = '%1 = Packaging Specification No.';
    ItemMismatchErr: Label 'Sales order line %1 is for item %2, but packaging specification %3 is for item %4.', Comment = '%1 = Line No., %2 = Item No. of the line, %3 = Packaging Specification No., %4 = Item No. of the specification';
    NothingToProduceErr: Label 'Sales order line %1 has no quantity left to ship.', Comment = '%1 = Line No.';
    ProdOrderNotCreatedErr: Label 'The production order for sales order line %1 could not be found after it was created.', Comment = '%1 = Line No.';
    QtyChangeBlockedErr: Label 'You cannot change the quantity of sales order line %1 because %2 production order %3 exists for it. Change or delete the production order first.', Comment = '%1 = Line No., %2 = Production Order Status, %3 = Production Order No.';
    QtyChangedMsg: Label 'The quantity of sales order line %1 was changed from %2 to %3, but %4 production order %5 is for %6. Update the production order.', Comment = '%1 = Line No., %2 = Old quantity, %3 = New quantity, %4 = Production Order Status, %5 = Production Order No., %6 = Production order quantity';
    OpenProdOrderActionLbl: Label 'Open Production Order';
    ProdOrderStatusTok: Label 'ProdOrderStatus', Locked = true;
    ProdOrderNoTok: Label 'ProdOrderNo', Locked = true;

  /// <summary>
  /// Creates a standard production order for a sales order line with a packaging specification. The production BOM and routing
  /// are generated first according to Packaging Setup, and the order gets the status from Packaging Setup. No order is created when
  /// an open (firm planned or released) production order already exists for the line.
  /// </summary>
  /// <param name="SalesLine">The sales order line.</param>
  /// <param name="ProductionOrder">Returns the created production order, or the existing open production order of the line.</param>
  /// <returns>True when a production order was created; false when an open production order already existed.</returns>
  procedure CreatePackagingProduction(SalesLine: Record "Sales Line"; var ProductionOrder: Record "Production Order") Created: Boolean
  var
    PackagingSetup: Record "CCO Packaging Setup";
    PackagingSpecification: Record "CCO Packaging Specification";
    CreateProdOrderFromSale: Codeunit "Create Prod. Order from Sale";
  begin
    CheckSalesLine(SalesLine, PackagingSpecification);
    if FindOpenProdOrder(SalesLine, ProductionOrder) then
      exit;

    if not PackagingSetup.Get() then
      PackagingSetup.Init();
    PrepareProductionData(PackagingSpecification, PackagingSetup."BOM/Routing Generation");

    CreateProdOrderFromSale.SetHideValidationDialog(true);
    CreateProdOrderFromSale.CreateProductionOrder(SalesLine, GetProductionOrderStatus(PackagingSetup."Prod. Order Status"), "Create Production Order Type"::ItemOrder);

    if not FindOpenProdOrder(SalesLine, ProductionOrder) then
      Error(ProdOrderNotCreatedErr, SalesLine."Line No.");
    Created := true;
  end;

  /// <summary>
  /// Finds the open (firm planned or released) production order that was created for a sales order line.
  /// </summary>
  /// <param name="SalesLine">The sales order line.</param>
  /// <param name="ProductionOrder">Returns the production order.</param>
  /// <returns>True when an open production order exists for the line.</returns>
  procedure FindOpenProdOrder(SalesLine: Record "Sales Line"; var ProductionOrder: Record "Production Order") Found: Boolean
  begin
    ProductionOrder.Reset();
    ProductionOrder.SetCurrentKey("CCO Sales Order No.", "CCO Sales Order Line No.");
    ProductionOrder.SetRange("CCO Sales Order No.", SalesLine."Document No.");
    ProductionOrder.SetRange("CCO Sales Order Line No.", SalesLine."Line No.");
    ProductionOrder.SetFilter(Status, '%1|%2', ProductionOrder.Status::"Firm Planned", ProductionOrder.Status::Released);
    Found := ProductionOrder.FindFirst();
  end;

  /// <summary>
  /// Opens the card of a production order according to its status.
  /// </summary>
  /// <param name="ProductionOrder">The production order.</param>
  procedure ShowProductionOrder(ProductionOrder: Record "Production Order")
  begin
    ProductionOrder.SetRecFilter();
    case ProductionOrder.Status of
      ProductionOrder.Status::"Firm Planned":
        Page.Run(Page::"Firm Planned Prod. Order", ProductionOrder);
      ProductionOrder.Status::Released:
        Page.Run(Page::"Released Production Order", ProductionOrder);
      else
        Page.Run(Page::"Production Order List", ProductionOrder);
    end;
  end;

  /// <summary>
  /// Copies the links to the sales order line, the packaging specification, and the cost sheet to a production order
  /// that is created for one item from a sales order line with a packaging specification.
  /// </summary>
  /// <param name="ProductionOrder">The production order that is being created.</param>
  /// <param name="SalesLine">The sales line that the production order is created from.</param>
  procedure CopyLinksFromSalesLine(var ProductionOrder: Record "Production Order"; SalesLine: Record "Sales Line")
  begin
    if SalesLine."Document Type" <> SalesLine."Document Type"::Order then
      exit;
    if SalesLine."CCO Packaging Spec. No." = '' then
      exit;
    if ProductionOrder."Source Type" <> ProductionOrder."Source Type"::Item then
      exit;

    ProductionOrder."CCO Sales Order No." := SalesLine."Document No.";
    ProductionOrder."CCO Sales Order Line No." := SalesLine."Line No.";
    ProductionOrder."CCO Packaging Spec. No." := SalesLine."CCO Packaging Spec. No.";
    ProductionOrder."CCO Cost Sheet No." := SalesLine."CCO Cost Sheet No.";
  end;

  /// <summary>
  /// Blocks a quantity change on a sales order line with a packaging specification that has an open production order,
  /// when Qty. Change after Prod. Order in Packaging Setup is Error. Runs during the quantity validation, just before the standard
  /// Business Central check of the production order status, so the change is blocked before the standard confirmation dialog.
  /// </summary>
  /// <param name="SalesLine">The sales line with the new quantity. It is compared with the stored line.</param>
  procedure CheckQuantityChangeBlocked(SalesLine: Record "Sales Line")
  var
    PackagingSetup: Record "CCO Packaging Setup";
    ProductionOrder: Record "Production Order";
    StoredSalesLine: Record "Sales Line";
  begin
    if not IsQuantityCheckRelevant(SalesLine) then
      exit;
    if not StoredSalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.") then
      exit;
    if SalesLine."Quantity (Base)" = StoredSalesLine."Quantity (Base)" then
      exit;
    if not PackagingSetup.Get() then
      exit;
    if PackagingSetup."Qty. Change after Prod. Order" <> PackagingSetup."Qty. Change after Prod. Order"::Error then
      exit;
    if FindOpenProdOrder(SalesLine, ProductionOrder) then
      Error(QtyChangeBlockedErr, SalesLine."Line No.", ProductionOrder.Status, ProductionOrder."No.");
  end;

  /// <summary>
  /// Warns about or blocks a quantity change on a sales order line with a packaging specification that has an open production order,
  /// according to the setting Qty. Change after Prod. Order in Packaging Setup. Also covers changes of the unit of measure.
  /// </summary>
  /// <param name="SalesLine">The sales line with the new quantity.</param>
  /// <param name="xSalesLine">The sales line before the change.</param>
  procedure CheckQuantityChange(SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
  var
    PackagingSetup: Record "CCO Packaging Setup";
    ProductionOrder: Record "Production Order";
  begin
    if SalesLine."Quantity (Base)" = xSalesLine."Quantity (Base)" then
      exit;
    if not IsQuantityCheckRelevant(SalesLine) then
      exit;
    if not FindOpenProdOrder(SalesLine, ProductionOrder) then
      exit;

    if not PackagingSetup.Get() then
      PackagingSetup.Init();
    case PackagingSetup."Qty. Change after Prod. Order" of
      PackagingSetup."Qty. Change after Prod. Order"::Error:
        Error(QtyChangeBlockedErr, SalesLine."Line No.", ProductionOrder.Status, ProductionOrder."No.");
      PackagingSetup."Qty. Change after Prod. Order"::Warning:
        SendQuantityChangedNotification(SalesLine, xSalesLine, ProductionOrder);
    end;
  end;

  /// <summary>
  /// Opens the production order of a quantity change notification.
  /// </summary>
  /// <param name="QtyChangedNotification">The notification that holds the status and number of the production order.</param>
  procedure OpenProductionOrderFromNotification(QtyChangedNotification: Notification)
  var
    ProductionOrder: Record "Production Order";
    ProdOrderStatus: Integer;
  begin
    Evaluate(ProdOrderStatus, QtyChangedNotification.GetData(ProdOrderStatusTok));
    ProductionOrder.Get("Production Order Status".FromInteger(ProdOrderStatus), QtyChangedNotification.GetData(ProdOrderNoTok));
    ShowProductionOrder(ProductionOrder);
  end;

  local procedure IsQuantityCheckRelevant(SalesLine: Record "Sales Line") Relevant: Boolean
  begin
    Relevant := (not SalesLine.IsTemporary()) and (SalesLine."Document Type" = SalesLine."Document Type"::Order) and (SalesLine."CCO Packaging Spec. No." <> '');
  end;

  local procedure CheckSalesLine(SalesLine: Record "Sales Line"; var PackagingSpecification: Record "CCO Packaging Specification")
  begin
    if (SalesLine."Document Type" <> SalesLine."Document Type"::Order) or (SalesLine.Type <> SalesLine.Type::Item) then
      Error(NotSalesOrderLineErr);
    if SalesLine."CCO Packaging Spec. No." = '' then
      Error(NoPackagingSpecErr, SalesLine."Line No.");

    PackagingSpecification.Get(SalesLine."CCO Packaging Spec. No.");
    if PackagingSpecification.Status <> PackagingSpecification.Status::Released then
      Error(SpecNotReleasedErr, PackagingSpecification."No.");
    if PackagingSpecification."Item No." <> SalesLine."No." then
      Error(ItemMismatchErr, SalesLine."Line No.", SalesLine."No.", PackagingSpecification."No.", PackagingSpecification."Item No.");

    if SalesLine."Outstanding Qty. (Base)" <= 0 then
      Error(NothingToProduceErr, SalesLine."Line No.");
    SalesLine.TestField("Shipment Date");
  end;

  local procedure PrepareProductionData(var PackagingSpecification: Record "CCO Packaging Specification"; GenerationMode: Enum "CCO BOM Routing Generation")
  var
    Item: Record Item;
    BOMGeneratorMgt: Codeunit "CCO BOM Generator Mgt.";
    RoutingGeneratorMgt: Codeunit "CCO Routing Generator Mgt.";
    Regenerate: Boolean;
  begin
    Item.Get(PackagingSpecification."Item No.");
    Regenerate := GenerationMode = GenerationMode::"Always Regenerate";

    if Regenerate or (Item."Production BOM No." = '') then
      BOMGeneratorMgt.GenerateProductionBOM(PackagingSpecification);
    if Regenerate or (Item."Routing No." = '') then
      RoutingGeneratorMgt.GenerateRouting(PackagingSpecification);
  end;

  local procedure GetProductionOrderStatus(PackProdOrderStatus: Enum "CCO Pack. Prod. Order Status") ProdOrderStatus: Enum "Production Order Status"
  begin
    case PackProdOrderStatus of
      PackProdOrderStatus::Released:
        ProdOrderStatus := ProdOrderStatus::Released;
      else
        ProdOrderStatus := ProdOrderStatus::"Firm Planned";
    end;
  end;

  local procedure SendQuantityChangedNotification(SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; ProductionOrder: Record "Production Order")
  var
    QtyChangedNotification: Notification;
  begin
    QtyChangedNotification.Id := CreateGuid();
    QtyChangedNotification.Scope := NotificationScope::LocalScope;
    QtyChangedNotification.Message :=
      StrSubstNo(QtyChangedMsg, SalesLine."Line No.", xSalesLine.Quantity, SalesLine.Quantity, ProductionOrder.Status, ProductionOrder."No.", ProductionOrder.Quantity);
    QtyChangedNotification.SetData(ProdOrderStatusTok, Format(ProductionOrder.Status.AsInteger()));
    QtyChangedNotification.SetData(ProdOrderNoTok, ProductionOrder."No.");
    QtyChangedNotification.AddAction(OpenProdOrderActionLbl, Codeunit::"CCO Packaging Production Mgt.", 'OpenProductionOrderFromNotification');
    QtyChangedNotification.Send();
  end;
}
