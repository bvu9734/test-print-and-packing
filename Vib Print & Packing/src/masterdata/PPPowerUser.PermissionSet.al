permissionset 50118 "PP_POWERUSER"
{
  Assignable = true;
  Caption = 'Print and Packaging Power User';
  IncludedPermissionSets = "PP_USER";

  Permissions =
    tabledata "CCO Packaging Setup" = RIMD,
    page "CCO Packaging Setup" = X,
    page "No. Series" = X;
}
