table 50100 "CCO Packaging Specification"
{
  Caption = 'Packaging Specification';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "No."; Code[20])
    {
      Caption = 'No.';
      DataClassification = CustomerContent;
    }
    field(2; Description; Text[100])
    {
      Caption = 'Description';
      DataClassification = CustomerContent;
    }
    field(3; "Customer No."; Code[20])
    {
      Caption = 'Customer No.';
      DataClassification = CustomerContent;
      TableRelation = Customer."No.";
    }
    field(4; "Width (mm)"; Decimal)
    {
      Caption = 'Width (mm)';
      DataClassification = CustomerContent;
    }
    field(5; "Length (mm)"; Decimal)
    {
      Caption = 'Length (mm)';
      DataClassification = CustomerContent;
    }
    field(6; "Height (mm)"; Decimal)
    {
      Caption = 'Height (mm)';
      DataClassification = CustomerContent;
    }
    field(7; "Material Code"; Code[20])
    {
      Caption = 'Material Code';
      DataClassification = CustomerContent;
      TableRelation = Item."No.";

      trigger OnValidate()
      var
        MaterialItem: Record Item;
        PackagingItemTypeErr: Label 'Item %1 must be assigned a packaging material type.';
      begin
        if "Material Code" = '' then
          exit;

        MaterialItem.Get("Material Code");
        if MaterialItem."CCO Packaging Material Type" = MaterialItem."CCO Packaging Material Type"::None then
          Error(PackagingItemTypeErr, MaterialItem."No.");
      end;
    }
    field(8; "Material GSM"; Decimal)
    {
      Caption = 'Material GSM';
      DataClassification = CustomerContent;
    }
    field(9; "Print Process"; Enum "CCO Print Process")
    {
      Caption = 'Print Process';
      DataClassification = CustomerContent;
    }
    field(10; "No. of Colors"; Integer)
    {
      Caption = 'No. of Colors';
      DataClassification = CustomerContent;
    }
    field(11; Lamination; Boolean)
    {
      Caption = 'Lamination';
      DataClassification = CustomerContent;
    }
    field(12; "Die Cut"; Boolean)
    {
      Caption = 'Die Cut';
      DataClassification = CustomerContent;
    }
    field(13; "Waste %"; Decimal)
    {
      Caption = 'Waste %';
      DataClassification = CustomerContent;
    }
    field(14; Status; Enum "CCO Spec. Status")
    {
      Caption = 'Status';
      DataClassification = CustomerContent;
    }
  }

  keys
  {
    key(PK; "No.")
    {
      Clustered = true;
    }
  }

  trigger OnInsert()
  var
    PackagingSetup: Record "CCO Packaging Setup";
    NoSeries: Codeunit "No. Series";
  begin
    if "No." <> '' then
      exit;

    if not PackagingSetup.Get('') then
      exit;

    if PackagingSetup."Packaging Spec. Nos." = '' then
      exit;

    "No." := NoSeries.GetNextNo(PackagingSetup."Packaging Spec. Nos.");
  end;
}
