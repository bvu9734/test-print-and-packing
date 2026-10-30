permissionset 50118 "PP_POWERUSER"
{
  Assignable = true;
  Caption = 'Print and Packaging Power User';
  IncludedPermissionSets = "PP_USER";

  Permissions =
    tabledata "CCO Packaging Setup" = RIMD,
    tabledata "CCO Print Cost Matrix" = RIMD,
    tabledata Customer = RM,
    page "CCO Packaging Setup" = X,
    page "CCO Print Cost Matrix" = X,
    page "No. Series" = X,
    page "Customer Card" = X;
}
