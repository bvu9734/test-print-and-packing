enum 50145 "CCO Operation Condition"
{
  Extensible = true;

  value(0; Always)
  {
    Caption = 'Always';
  }
  value(1; "Die Cut")
  {
    Caption = 'Only if Die Cut';
  }
  value(2; Lamination)
  {
    Caption = 'Only if Lamination';
  }
  value(3; Printing)
  {
    Caption = 'Only if Printed';
  }
}
