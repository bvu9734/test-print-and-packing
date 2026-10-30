permissionset 50119 "PP_ADMIN"
{
  Assignable = true;
  Caption = 'Print and Packaging Administrator';
  IncludedPermissionSets = "PP_POWERUSER";

  Permissions =
    tabledata Item = RIMD,
    tabledata Customer = RIM,
    tabledata "No. Series" = RIM,
    tabledata "No. Series Line" = RIM,
    tabledata "Unit of Measure" = RI,
    tabledata "Item Templ." = RIM,
    tabledata "Work Center" = RIM,
    tabledata "Work Center Group" = RI,
    tabledata "Capacity Unit of Measure" = RI,
    tabledata "Shop Calendar" = R,
    codeunit "CCO Packaging Demo Data" = X;
}
