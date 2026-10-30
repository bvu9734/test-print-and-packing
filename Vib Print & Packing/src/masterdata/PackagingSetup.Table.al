table 50106 "CCO Packaging Setup"
{
  Caption = 'Packaging Setup';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "Primary Key"; Code[10])
    {
      Caption = 'Primary Key';
      ToolTip = 'Specifies the key of the packaging setup record.', Comment = 'hu-HU=Megadja a csomagolási beállítás rekord kulcsát.';
      DataClassification = SystemMetadata;
    }
    field(2; "Packaging Spec. Nos."; Code[20])
    {
      Caption = 'Packaging Spec. Nos.';
      ToolTip = 'Specifies the number series used to assign codes to packaging specifications.', Comment = 'hu-HU=Megadja a csomagolási specifikációk kódjainak kiosztására használt számsort.';
      DataClassification = CustomerContent;
      TableRelation = "No. Series";
    }
  }

  keys
  {
    key(PK; "Primary Key")
    {
      Clustered = true;
    }
  }
}
