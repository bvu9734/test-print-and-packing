codeunit 50122 "CCO Spec. Item Mgt."
{
  /// <summary>
  /// Creates the finished item for a packaging specification and links it to the specification.
  /// </summary>
  /// <param name="PackagingSpecification">The specification to create the item for. Its Item No. is set but not saved.</param>
  procedure CreateItem(var PackagingSpecification: Record "CCO Packaging Specification")
  var
    PackagingSetup: Record "CCO Packaging Setup";
    Item: Record Item;
    NoSeries: Codeunit "No. Series";
  begin
    PackagingSetup.Get();
    PackagingSetup.TestField("Item Nos.");

    Item.Init();
    Item."No." := NoSeries.GetNextNo(PackagingSetup."Item Nos.");
    Item."No. Series" := PackagingSetup."Item Nos.";
    Item.Insert(true);

    ApplyItemTemplate(Item, PackagingSetup."Item Template Code");

    Item.Validate(Description, PackagingSpecification.Description);
    Item.Validate("Replenishment System", Item."Replenishment System"::"Prod. Order");
    Item.Validate("Manufacturing Policy", Item."Manufacturing Policy"::"Make-to-Order");
    Item."CCO Packaging Spec. No." := PackagingSpecification."No.";
    Item.Modify(true);

    PackagingSpecification."Item No." := Item."No.";
  end;

  local procedure ApplyItemTemplate(var Item: Record Item; ItemTemplateCode: Code[20])
  var
    ItemTempl: Record "Item Templ.";
    ItemTemplMgt: Codeunit "Item Templ. Mgt.";
  begin
    if ItemTemplateCode = '' then
      exit;

    ItemTempl.Get(ItemTemplateCode);
    ItemTemplMgt.ApplyItemTemplate(Item, ItemTempl);
    Item.Get(Item."No.");
  end;
}
