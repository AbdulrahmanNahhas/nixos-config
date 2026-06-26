# Home-manager hook — delegates to home/aqua/
{
  inputs,
  username,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";

    extraSpecialArgs = {
      inherit inputs username;
    };

    users.${username} = import ./home/aqua;
  };
}
