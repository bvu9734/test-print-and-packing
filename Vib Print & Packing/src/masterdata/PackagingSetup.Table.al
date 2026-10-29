table 50106 "CCO Packaging Setup"
{
  Caption = 'Packaging Setup';
  DataClassification = CustomerContent;

  fields
  {
    field(1; "Primary Key"; Code[10])
    {
      Caption = 'Primary Key';
      DataClassification = SystemMetadata;
    }
    field(2; "Packaging Spec. Nos."; Code[20])
    {
      Caption = 'Packaging Spec. Nos.';
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
