codeunit 50108 "CCO BOM Generator Mgt."
{
  var
    BOMInUseErr: Label 'Production BOM %1 is used by an open production order and cannot be replaced. Finish or delete the production order, or create a new version of the production BOM manually.', Comment = '%1 = Production BOM No.';
    NoComponentsErr: Label 'Packaging BOM %1 has no components with a quantity.', Comment = '%1 = Packaging Specification No.';

  /// <summary>
  /// Calculates the components of the packaging BOM from the specification and the consumption settings,
  /// replacing existing lines. Quantities are per piece without waste; the waste percentage becomes the scrap percentage.
  /// </summary>
  /// <param name="PackagingSpecification">The specification to calculate the BOM for.</param>
  procedure CalculatePackagingBOM(PackagingSpecification: Record "CCO Packaging Specification")
  var
    PackagingBOM: Record "CCO Packaging BOM";
    PackagingBOMLine: Record "CCO Packaging BOM Line";
    PackagingSetup: Record "CCO Packaging Setup";
    BaseArea: Decimal;
    LineNo: Integer;
  begin
    PackagingSpecification.TestField("Material Code");
    PackagingSpecification.TestField("Width (mm)");
    PackagingSpecification.TestField("Height (mm)");
    if not PackagingSetup.Get() then
      PackagingSetup.Init();

    if not PackagingBOM.Get(PackagingSpecification."No.") then begin
      PackagingBOM.Init();
      PackagingBOM."Specification No." := PackagingSpecification."No.";
      PackagingBOM.Insert(true);
    end;
    PackagingBOM.Description := PackagingSpecification.Description;
    PackagingBOM."Calculation Date" := Today();
    PackagingBOM.Modify(true);

    PackagingBOMLine.SetRange("Specification No.", PackagingSpecification."No.");
    PackagingBOMLine.DeleteAll(true);

    BaseArea := PackagingSpecification."Height (mm)" * PackagingSpecification."Width (mm)" / 1000000;
    AddLine(PackagingSpecification."No.", LineNo, PackagingSpecification."Material Code", BaseArea, PackagingSpecification."Waste %");

    if (PackagingSpecification."No. of Colors" > 0) and (PackagingSetup."Ink Qty. per m² per Color" <> 0) then begin
      PackagingSetup.TestField("Ink Item No.");
      AddLine(PackagingSpecification."No.", LineNo, PackagingSetup."Ink Item No.",
        BaseArea * PackagingSetup."Ink Qty. per m² per Color" * PackagingSpecification."No. of Colors", PackagingSpecification."Waste %");
    end;

    if PackagingSetup."Glue Qty. per Piece" <> 0 then begin
      PackagingSetup.TestField("Glue Item No.");
      AddLine(PackagingSpecification."No.", LineNo, PackagingSetup."Glue Item No.", PackagingSetup."Glue Qty. per Piece", 0);
    end;

    if PackagingSpecification.Lamination then begin
      PackagingSetup.TestField("Lamination Film Item No.");
      AddLine(PackagingSpecification."No.", LineNo, PackagingSetup."Lamination Film Item No.", BaseArea, PackagingSpecification."Waste %");
    end;
  end;

  /// <summary>
  /// Creates or replaces the certified production BOM of the finished item from the packaging BOM, and assigns it to the item.
  /// The packaging BOM is calculated first if it does not exist yet. The production BOM has the number of the finished item.
  /// </summary>
  /// <param name="PackagingSpecification">The released specification.</param>
  /// <returns>The number of the production BOM.</returns>
  procedure GenerateProductionBOM(PackagingSpecification: Record "CCO Packaging Specification") ProductionBOMNo: Code[20]
  var
    PackagingBOM: Record "CCO Packaging BOM";
    PackagingBOMLine: Record "CCO Packaging BOM Line";
    ProductionBOMHeader: Record "Production BOM Header";
    Item: Record Item;
  begin
    PackagingSpecification.TestField("Item No.");
    Item.Get(PackagingSpecification."Item No.");
    Item.TestField("Base Unit of Measure");

    PackagingBOMLine.SetRange("Specification No.", PackagingSpecification."No.");
    if PackagingBOMLine.IsEmpty() then
      CalculatePackagingBOM(PackagingSpecification);
    PackagingBOMLine.SetFilter("Quantity per", '>0');
    if PackagingBOMLine.IsEmpty() then
      Error(NoComponentsErr, PackagingSpecification."No.");

    ProductionBOMNo := Item."No.";
    PrepareProductionBOMHeader(ProductionBOMHeader, ProductionBOMNo, PackagingSpecification.Description, Item."Base Unit of Measure");

    PackagingBOMLine.FindSet();
    repeat
      InsertProductionBOMLine(ProductionBOMNo, PackagingBOMLine);
    until PackagingBOMLine.Next() = 0;

    ProductionBOMHeader.Validate(Status, ProductionBOMHeader.Status::Certified);
    ProductionBOMHeader.Modify(true);

    if Item."Production BOM No." <> ProductionBOMNo then begin
      Item.Validate("Production BOM No.", ProductionBOMNo);
      Item.Modify(true);
    end;

    PackagingBOM.Get(PackagingSpecification."No.");
    PackagingBOM."Production BOM No." := ProductionBOMNo;
    PackagingBOM.Modify(true);
  end;

  local procedure AddLine(SpecificationNo: Code[20]; var LineNo: Integer; ItemNo: Code[20]; QuantityPer: Decimal; ScrapPercent: Decimal)
  var
    PackagingBOMLine: Record "CCO Packaging BOM Line";
  begin
    LineNo += 10000;
    PackagingBOMLine.Init();
    PackagingBOMLine."Specification No." := SpecificationNo;
    PackagingBOMLine."Line No." := LineNo;
    PackagingBOMLine.Validate("Item No.", ItemNo);
    PackagingBOMLine.Validate("Quantity per", QuantityPer);
    PackagingBOMLine.Validate("Scrap %", ScrapPercent);
    PackagingBOMLine.Insert(true);
  end;

  local procedure PrepareProductionBOMHeader(var ProductionBOMHeader: Record "Production BOM Header"; ProductionBOMNo: Code[20]; BOMDescription: Text[100]; UnitOfMeasureCode: Code[10])
  var
    ProductionBOMLine: Record "Production BOM Line";
  begin
    if ProductionBOMHeader.Get(ProductionBOMNo) then begin
      CheckNotUsedByOpenProdOrder(ProductionBOMNo);
      if ProductionBOMHeader.Status <> ProductionBOMHeader.Status::"Under Development" then begin
        ProductionBOMHeader.Validate(Status, ProductionBOMHeader.Status::"Under Development");
        ProductionBOMHeader.Modify(true);
      end;
      ProductionBOMLine.SetRange("Production BOM No.", ProductionBOMNo);
      ProductionBOMLine.SetRange("Version Code", '');
      ProductionBOMLine.DeleteAll(true);
    end else begin
      ProductionBOMHeader.Init();
      ProductionBOMHeader."No." := ProductionBOMNo;
      ProductionBOMHeader.Insert(true);
    end;

    ProductionBOMHeader.Validate(Description, BOMDescription);
    ProductionBOMHeader.Validate("Unit of Measure Code", UnitOfMeasureCode);
    ProductionBOMHeader.Modify(true);
  end;

  local procedure InsertProductionBOMLine(ProductionBOMNo: Code[20]; PackagingBOMLine: Record "CCO Packaging BOM Line")
  var
    ProductionBOMLine: Record "Production BOM Line";
  begin
    ProductionBOMLine.Init();
    ProductionBOMLine."Production BOM No." := ProductionBOMNo;
    ProductionBOMLine."Version Code" := '';
    ProductionBOMLine."Line No." := PackagingBOMLine."Line No.";
    ProductionBOMLine.Validate(Type, ProductionBOMLine.Type::Item);
    ProductionBOMLine.Validate("No.", PackagingBOMLine."Item No.");
    if PackagingBOMLine."Unit of Measure Code" <> '' then
      ProductionBOMLine.Validate("Unit of Measure Code", PackagingBOMLine."Unit of Measure Code");
    ProductionBOMLine.Validate("Quantity per", PackagingBOMLine."Quantity per");
    ProductionBOMLine.Validate("Scrap %", PackagingBOMLine."Scrap %");
    ProductionBOMLine.Insert(true);
  end;

  local procedure CheckNotUsedByOpenProdOrder(ProductionBOMNo: Code[20])
  var
    ProdOrderLine: Record "Prod. Order Line";
  begin
    ProdOrderLine.SetRange("Production BOM No.", ProductionBOMNo);
    ProdOrderLine.SetFilter(Status, '<>%1', ProdOrderLine.Status::Finished);
    if not ProdOrderLine.IsEmpty() then
      Error(BOMInUseErr, ProductionBOMNo);
  end;
}
